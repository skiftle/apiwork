---
order: 3
---

# Associations

Associations define relationships between resources. They control how related data is included, filtered, and written.

## Association Types

| Type         | Cardinality | API Response |
| ------------ | ----------- | ------------ |
| `has_one`    | Single      | Object       |
| `has_many`   | Multiple    | Array        |
| `belongs_to` | Single      | Object       |

## Basic Declaration

```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :author
  has_many :comments
  has_one :image
end
```

## Options Reference

| Option        | Type            | Default     | Description                              |
| ------------- | --------------- | ----------- | ---------------------------------------- |
| `schema`      | Class           | auto        | Associated schema class                  |
| `include`     | Symbol          | `:optional` | `:always` or `:optional`                 |
| `writable`    | `bool` / `hash` | `false`     | Allow nested attributes                  |
| `filterable`  | `bool`          | `false`     | Enable filtering by association          |
| `sortable`    | `bool`          | `false`     | Enable sorting by association            |
| `nullable`    | `bool`          | auto        | Allow null (auto-detected from DB)       |
| `polymorphic` | Hash            | `nil`       | Polymorphic type mapping                 |
| `description` | `string`        | `nil`       | API documentation                        |
| `example`     | `any`           | `nil`       | Example value                            |
| `deprecated`  | `bool`          | `false`     | Mark as deprecated                       |

## Auto-Detection

Schema and nullable are inferred. See [Inference](./inference.md) for details.

```ruby
# These are equivalent:
has_many :comments
has_many :comments, schema: CommentSchema
```

For non-standard names, specify explicitly:

```ruby
has_many :recent_posts, schema: PostSchema
```

## Response Structure

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title
  belongs_to :author
  has_many :comments
end
```

```json
{
  "post": {
    "title": "Hello World",
    "author": {
      "id": "1",
      "name": "Jane"
    },
    "comments": [
      { "id": "1", "content": "Great post!" },
      { "id": "2", "content": "Thanks for sharing" }
    ]
  }
}
```

---

## Include Modes

Control when associations are loaded in responses.

| Mode | Behavior |
|------|----------|
| `include: :optional` | Only included if requested (default) |
| `include: :always` | Always included in responses |

### Optional Include (Default)

```ruby
has_many :comments, schema: CommentSchema, include: :optional
```

Clients request inclusion explicitly:

```
GET /api/v1/posts/1?include[comments]=true
```

Without the parameter, `comments` is omitted from the response.

### Always Include

```ruby
belongs_to :author, schema: AuthorSchema, include: :always
```

The association is included in every response automatically.

### Type Guarantees

The `include` option directly affects generated types:

**Optional:**

```typescript
interface Post {
  title?: string;
  comments?: Comment[];  // May not be present
}
```

**Always:**

```typescript
interface Post {
  title?: string;
  author: Author;  // Always present (no ?)
}
```

### nullable vs optional

`nullable` and `include` are independent:

- **optional** (`?`) — field may not exist in response
- **nullable** (`| null`) — field exists but value can be null

```ruby
# Always present, never null
belongs_to :author, include: :always
# → author: Author

# Always present, can be null
belongs_to :reviewer, include: :always, nullable: true
# → reviewer: Author | null

# May not be present, if present then not null
has_many :comments, include: :optional
# → comments?: Comment[]
```

### Request Format

**Single Association:**

```
GET /api/v1/posts/1?include[comments]=true
```

**Multiple Associations:**

```
GET /api/v1/posts/1?include[comments]=true&include[author]=true
```

**Nested Associations:**

```
GET /api/v1/posts/1?include[comments][author]=true
```

**Depth limit**: Maximum 3 levels of nesting to prevent circular references.

### N+1 Prevention

Apiwork automatically preloads included associations using `ActiveRecord::Associations::Preloader`.

---

## Writable Associations

Create and update associated records through nested attributes.

### Basic Usage

```ruby
has_many :comments, schema: CommentSchema, writable: true
```

### Rails Requirement

Your model must accept nested attributes:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

### Context-Specific Writing

```ruby
has_many :comments, writable: { on: [:create] }     # Only on create
has_many :comments, writable: { on: [:update] }     # Only on update
has_many :comments, writable: true                   # Both
```

### Request Format

Apiwork transforms association names to Rails' `_attributes` format:

```json
// POST /api/v1/posts
{
  "post": {
    "title": "New Post",
    "comments": [
      { "content": "First comment", "author": "Alice" },
      { "content": "Second comment", "author": "Bob" }
    ]
  }
}
```

Internally becomes:

```ruby
{
  title: "New Post",
  comments_attributes: [
    { content: "First comment", author: "Alice" },
    { content: "Second comment", author: "Bob" }
  ]
}
```

### Updating Existing Records

Include `id` to update existing associated records:

```json
// PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": "5", "content": "Updated comment" }
    ]
  }
}
```

### Deleting Records

Use `_destroy: true` to delete associated records:

```json
{
  "post": {
    "comments": [
      { "id": "5", "_destroy": true }
    ]
  }
}
```

Requires `allow_destroy: true` in Rails model.

---

## Filtering & Sorting on Associations

Query by fields on associated records.

### Filtering

Enable with `filterable: true`:

```ruby
has_many :comments, schema: CommentSchema, filterable: true
belongs_to :author, schema: AuthorSchema, filterable: true
```

**Query Format:**

```
# Posts where author name is "Jane"
GET /api/v1/posts?filter[author][name][eq]=Jane

# Posts with comments containing "rails"
GET /api/v1/posts?filter[comments][content][contains]=rails

# Posts by author created after 2024
GET /api/v1/posts?filter[author][created_at][gt]=2024-01-01
```

### Sorting

Enable with `sortable: true`:

```ruby
belongs_to :author, schema: AuthorSchema, sortable: true
```

**Query Format:**

```
# Posts sorted by author name
GET /api/v1/posts?sort[author][name]=asc

# Posts sorted by author creation date
GET /api/v1/posts?sort[author][created_at]=desc
```

### Auto-Include

When filtering or sorting by an association, it's automatically included for the query.

---

## Polymorphic Associations

Handle associations that can belong to multiple model types.

### Definition

Map each type to its schema:

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :commentable, polymorphic: {
    post: PostSchema,
    video: VideoSchema,
    article: ArticleSchema
  }
end
```

### Rails Setup

Your model needs standard Rails polymorphic configuration:

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end
```

Database columns required: `commentable_id` and `commentable_type`.

### Generated Types

Polymorphic associations generate discriminated unions:

```typescript
type CommentablePolymorphic =
  | { commentable_type: 'post' } & Post
  | { commentable_type: 'video' } & Video;

interface Comment {
  content?: string;
  commentable?: CommentablePolymorphic;
}
```

### Restrictions

Polymorphic associations have limitations:

| Feature | Supported | Reason |
|---------|-----------|--------|
| `include` | Yes | |
| `writable` | No | Rails doesn't support nested attributes for polymorphic |
| `filterable` | No | Cannot filter across multiple tables |
| `sortable` | No | Cannot sort across multiple tables |
