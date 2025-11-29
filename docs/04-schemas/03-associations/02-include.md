# Include

Control when associations are loaded in responses.

## Include Modes

| Mode | Behavior |
|------|----------|
| `include: :optional` | Only included if requested (default) |
| `include: :always` | Always included in responses |

## Optional Include (Default)

```ruby
has_many :comments, schema: CommentSchema, include: :optional
```

Clients request inclusion explicitly:

```
GET /api/v1/posts/1?include[comments]=true
```

Without the parameter, `comments` is omitted from the response.

## Always Include

```ruby
belongs_to :author, schema: AuthorSchema, include: :always
```

The association is included in every response automatically:

```
GET /api/v1/posts/1
```

```json
{
  "post": {
    "title": "Hello",
    "author": { "id": "1", "name": "Jane" }
  }
}
```

## Request Format

### Single Association

```
GET /api/v1/posts/1?include[comments]=true
```

### Multiple Associations

```
GET /api/v1/posts/1?include[comments]=true&include[author]=true
```

### Nested Associations

Include comments and each comment's author:

```
GET /api/v1/posts/1?include[comments][author]=true
```

```json
{
  "post": {
    "title": "Hello",
    "comments": [
      {
        "id": "1",
        "content": "Great!",
        "author": { "id": "2", "name": "Bob" }
      }
    ]
  }
}
```

### Deep Nesting

```
GET /api/v1/posts/1?include[comments][author][posts]=true
```

**Depth limit**: Maximum 3 levels of nesting to prevent circular references.

## N+1 Prevention

Apiwork automatically preloads included associations:

```ruby
# Without include param: 1 query
# With include[comments]=true: 2 queries (posts + comments)
# With include[comments][author]=true: 3 queries (posts + comments + authors)
```

Uses `ActiveRecord::Associations::Preloader` for efficient loading.

## Generated Include Type

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema
  belongs_to :author, schema: AuthorSchema
end
```

```typescript
// TypeScript
interface PostInclude {
  comments?: boolean | CommentInclude;
  author?: boolean | AuthorInclude;
}

// Zod
const PostIncludeSchema = z.object({
  comments: z.union([z.boolean(), CommentIncludeSchema]).optional(),
  author: z.union([z.boolean(), AuthorIncludeSchema]).optional()
});
```

## Practical Example

A blog API where author is always needed, but comments are optional:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title
  attribute :body

  belongs_to :author, schema: AuthorSchema, include: :always
  has_many :comments, schema: CommentSchema, include: :optional
  has_many :tags, schema: TagSchema, include: :optional
end
```

```
# Post list - lightweight, author always present
GET /api/v1/posts

# Post detail - with comments
GET /api/v1/posts/1?include[comments]=true

# Post detail - with everything
GET /api/v1/posts/1?include[comments][author]=true&include[tags]=true
```
