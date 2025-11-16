# respond_with

The `respond_with` method builds and sends JSON responses. It handles serialization, validation, and proper HTTP status codes automatically.

## Basic usage

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def show
    post = Post.find(params[:id])
    respond_with post
  end

  def index
    posts = query(Post.all)
    respond_with posts
  end

  def create
    post = Post.new(action_params)
    post.save
    respond_with post, status: :created
  end
end
```

## What it does

`respond_with` handles the entire response pipeline:

1. **Determines response type** - Single resource, collection, or error
2. **Serializes data** - Uses your schema to convert ActiveRecord to JSON
3. **Builds response structure** - Adds `ok`, root keys, `meta`
4. **Validates output** - Checks response matches contract (dev/test only)
5. **Sets HTTP status** - 200, 201, 422, etc.
6. **Sends JSON** - Renders final response

## Single resource responses

```ruby
def show
  post = Post.find(params[:id])
  respond_with post
end
```

Response:
```json
{
  "ok": true,
  "post": {
    "id": 1,
    "title": "My Post",
    "body": "Content here",
    "published": true,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

Status: `200 OK`

## Collection responses

```ruby
def index
  posts = query(Post.all)
  respond_with posts
end
```

Response:
```json
{
  "ok": true,
  "posts": [
    { "id": 1, "title": "First Post", ... },
    { "id": 2, "title": "Second Post", ... }
  ],
  "meta": {
    "page": {
      "current": 1,
      "next": 2,
      "prev": null,
      "total": 10,
      "items": 100
    }
  }
}
```

Status: `200 OK`

The `meta.page` object is automatically included when you use `query()` with pagination params.

## Create responses

```ruby
def create
  post = Post.new(action_params)
  post.save
  respond_with post, status: :created
end
```

Success response:
```json
{
  "ok": true,
  "post": {
    "id": 1,
    "title": "New Post",
    ...
  }
}
```

Status: `201 Created`

## Error responses

When a resource has Active Record validation errors:

```ruby
def create
  post = Post.new(action_params)
  post.save  # Fails validation
  respond_with post, status: :created
end
```

Response:
```json
{
  "ok": false,
  "issues": [
    {
      "code": "invalid",
      "path": "/post/title",
      "message": "can't be blank"
    },
    {
      "code": "invalid",
      "path": "/post/body",
      "message": "is too short (minimum is 10 characters)"
    }
  ]
}
```

Status: `422 Unprocessable Content`

Apiwork automatically detects `resource.errors.any?` and builds error responses.

## Delete responses

```ruby
def destroy
  post = Post.find(params[:id])
  post.destroy
  respond_with post
end
```

Response:
```json
{
  "ok": true,
  "meta": {}
}
```

Status: `200 OK`

For DELETE requests, only `ok` and `meta` are included (no resource data).

## Adding metadata

Include custom metadata in responses:

```ruby
def show
  post = Post.find(params[:id])
  respond_with post, meta: { views: post.views_count }
end
```

Response:
```json
{
  "ok": true,
  "post": { "id": 1, ... },
  "meta": {
    "views": 1234
  }
}
```

For collections with pagination, meta is merged:

```ruby
def index
  posts = query(Post.all)
  respond_with posts, meta: { total_published: Post.published.count }
end
```

Response:
```json
{
  "ok": true,
  "posts": [...],
  "meta": {
    "page": { "current": 1, ... },
    "total_published": 42
  }
}
```

## Status codes

`respond_with` sets HTTP status automatically:

```ruby
# GET request → 200 OK
respond_with post

# POST request (success) → 201 Created
respond_with post, status: :created

# POST request (errors) → 422 Unprocessable Content
respond_with post  # (when post.errors.any?)

# DELETE request → 200 OK
respond_with post
```

Override status explicitly:

```ruby
def create
  post = Post.new(action_params)
  post.save
  respond_with post, status: :created
end
```

## Including associations

Use the `include` parameter to include associations:

```ruby
# GET /api/v1/posts/1?include[comments]=true

def show
  post = Post.find(params[:id])
  respond_with post  # Apiwork handles includes automatically
end
```

Response:
```json
{
  "ok": true,
  "post": {
    "id": 1,
    "title": "My Post",
    "comments": [
      { "id": 1, "body": "Great post!" },
      { "id": 2, "body": "Thanks for sharing" }
    ]
  }
}
```

**Important:** The association must be defined in your schema:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title

  # Association available for optional inclusion
  has_many :comments,
    schema: Api::V1::CommentSchema,
    serializable: false  # Not included by default
end
```

See [Schemas → Associations](../schemas/associations.md) for details.

## Output validation

In development and test environments, `respond_with` validates the response against your contract:

```ruby
# If contract expects :published but you forgot to include it:
respond_with post  # Raises ValidationError in dev/test

# Production: No validation (performance)
```

This catches serialization bugs early.

## Response structure

All responses follow this structure:

**Success (single resource):**
```json
{
  "ok": true,
  "[resource_name]": { ... },
  "meta": { ... }  // Optional
}
```

**Success (collection):**
```json
{
  "ok": true,
  "[resource_name_plural]": [ ... ],
  "meta": {
    "page": { ... },
    ...  // Optional additional meta
  }
}
```

**Error:**
```json
{
  "ok": false,
  "issues": [
    { "code": "...", "path": "...", "message": "..." }
  ]
}
```

**Delete:**
```json
{
  "ok": true,
  "meta": {}
}
```

The `ok` field is always present. Root keys (`post`, `posts`) come from your schema's `model` declaration.

## Key transformation

Response keys are transformed based on your schema configuration:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  output_key_format :camel  # snake_case → camelCase

  model Post

  attribute :created_at
end
```

Response:
```json
{
  "ok": true,
  "post": {
    "id": 1,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

See [Schemas → Introduction](../schemas/introduction.md) for key transformation options.

## What respond_with does NOT do

These features are **not supported**:

- ❌ Custom root keys per-action - Root key comes from schema
- ❌ Multiple response formats (XML, CSV) - JSON only
- ❌ Partial responses - Use schema serialization control
- ❌ JSONAPI format - Apiwork has its own response format
- ❌ HAL or other hypermedia formats - Not supported

For custom response formats, build responses manually with `render json:`.

## Next steps

- **[action_params](./action_params.md)** - Accessing validated parameters
- **[query](./query.md)** - Filtering, sorting, and pagination
- **[Introduction](./introduction.md)** - Back to controllers overview
