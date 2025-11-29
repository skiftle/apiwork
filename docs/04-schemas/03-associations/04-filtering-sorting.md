# Filtering & Sorting on Associations

Query by fields on associated records.

## Filtering

Enable with `filterable: true`:

```ruby
has_many :comments, schema: CommentSchema, filterable: true
belongs_to :author, schema: AuthorSchema, filterable: true
```

### Query Format

Filter by association fields using nested syntax:

```
# Posts where author name is "Jane"
GET /api/v1/posts?filter[author][name][eq]=Jane

# Posts with comments containing "rails"
GET /api/v1/posts?filter[comments][content][contains]=rails

# Posts by author created after 2024
GET /api/v1/posts?filter[author][created_at][gt]=2024-01-01
```

### Auto-Include

When filtering by an association, it's automatically included for the query:

```
GET /api/v1/posts?filter[comments][author][eq]=Alice
```

This joins `comments` to execute the filter, even without `include[comments]=true`.

### Nested Association Filters

Filter through multiple levels:

```
# Posts where comment author is verified
GET /api/v1/posts?filter[comments][author][verified][eq]=true
```

### Generated Filter Type

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true
  has_many :comments, schema: CommentSchema, filterable: true
end

class CommentSchema < Apiwork::Schema::Base
  attribute :content, filterable: true
  attribute :author, filterable: true
end
```

```typescript
// TypeScript
interface PostFilter {
  title?: StringFilter;
  comments?: CommentFilter;
  _and?: PostFilter[];
  _or?: PostFilter[];
  _not?: PostFilter;
}

interface CommentFilter {
  content?: StringFilter;
  author?: StringFilter;
}

// Zod
const PostFilterSchema = z.object({
  title: StringFilterSchema.optional(),
  comments: CommentFilterSchema.optional(),
  _and: z.lazy(() => z.array(PostFilterSchema)).optional(),
  _or: z.lazy(() => z.array(PostFilterSchema)).optional(),
  _not: z.lazy(() => PostFilterSchema).optional()
});
```

## Sorting

Enable with `sortable: true`:

```ruby
belongs_to :author, schema: AuthorSchema, sortable: true
```

### Query Format

Sort by association fields:

```
# Posts sorted by author name
GET /api/v1/posts?sort[author][name]=asc

# Posts sorted by author creation date
GET /api/v1/posts?sort[author][created_at]=desc
```

### Auto-Include

Like filtering, sorting by an association auto-includes it for the query.

### Generated Sort Type

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, sortable: true
  belongs_to :author, schema: AuthorSchema, sortable: true
end

class AuthorSchema < Apiwork::Schema::Base
  attribute :name, sortable: true
  attribute :created_at, sortable: true
end
```

```typescript
// TypeScript
interface PostSort {
  title?: 'asc' | 'desc';
  author?: AuthorSort;
}

interface AuthorSort {
  name?: 'asc' | 'desc';
  created_at?: 'asc' | 'desc';
}

// Zod
const PostSortSchema = z.object({
  title: z.enum(['asc', 'desc']).optional(),
  author: AuthorSortSchema.optional()
});
```

## Combined Filtering and Sorting

```
# Posts by Jane, sorted by comment count
GET /api/v1/posts?filter[author][name][eq]=Jane&sort[created_at]=desc
```

## has_many Considerations

### Filtering

Filtering by `has_many` matches posts that have **any** matching comment:

```
# Returns posts that have at least one comment with "rails"
GET /api/v1/posts?filter[comments][content][contains]=rails
```

### Sorting

Sorting by `has_many` uses aggregate functions. Results are deduplicated with `DISTINCT`.

## Polymorphic Associations

Polymorphic associations **cannot** be filterable or sortable:

```ruby
# This raises ConfigurationError:
belongs_to :commentable, polymorphic: { ... }, filterable: true
```

The ambiguity of multiple possible types makes filtering/sorting undefined.
