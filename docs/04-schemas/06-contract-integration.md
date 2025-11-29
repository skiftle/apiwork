# Contract Integration

When a schema is connected to a contract via `schema!`, Apiwork automatically generates request and response structures for all defined actions.

## How It Works

```ruby
class PostContract < Apiwork::Contract::Base
  schema!  # Auto-generates everything from PostSchema

  action :index
  action :show
  action :create
  action :update
  action :destroy
end
```

The `schema!` call:
1. Links the contract to its corresponding schema (e.g., `PostSchema`)
2. Generates request/response structures for each action
3. Creates types for filtering, sorting, pagination, and payloads

## Naming Convention

Apiwork expects the schema class to match the contract name with `Schema` suffix instead of `Contract`:

| Contract | Expected Schema |
|----------|-----------------|
| `PostContract` | `PostSchema` |
| `UserContract` | `UserSchema` |
| `Api::V2::InvoiceContract` | `Api::V2::InvoiceSchema` |

If the schema doesn't exist, Apiwork raises an `ArgumentError` with a clear message about the expected convention.

## Default Action Behaviors

Each action type has default request and response structures:

| Action | Type | Request Query | Request Body | Response Body |
|--------|------|---------------|--------------|---------------|
| `index` | collection | filter, sort, page, include | — | `{ posts: [...], pagination: {...} }` |
| `show` | member | include | — | `{ post: {...} }` |
| `create` | member | include | `{ post: {...} }` | `{ post: {...} }` |
| `update` | member | include | `{ post: {...} }` | `{ post: {...} }` |
| `destroy` | member | — | — | `{}` |
| custom member | member | include | — | `{ post: {...} }` |
| custom collection | collection | — | — | `{}` |

### Index (Collection)

Returns a paginated list with optional filtering and sorting:

```json
// GET /api/v1/posts?filter[published][eq]=true&sort[created_at]=desc&page[size]=10

{
  "posts": [
    { "id": "1", "title": "First Post", "published": true },
    { "id": "2", "title": "Second Post", "published": true }
  ],
  "pagination": {
    "total": 42,
    "size": 10,
    "offset": 0
  }
}
```

### Show (Member)

Returns a single resource:

```json
// GET /api/v1/posts/1

{
  "post": {
    "id": "1",
    "title": "First Post",
    "body": "Content here...",
    "published": true
  }
}
```

### Create (Member)

Accepts writable attributes, returns the created resource:

```json
// POST /api/v1/posts
// Request:
{
  "post": {
    "title": "New Post",
    "body": "Content..."
  }
}

// Response:
{
  "post": {
    "id": "3",
    "title": "New Post",
    "body": "Content...",
    "published": false,
    "created_at": "2024-01-15T10:00:00Z"
  }
}
```

### Update (Member)

Accepts writable attributes, returns the updated resource:

```json
// PATCH /api/v1/posts/1
// Request:
{
  "post": {
    "title": "Updated Title"
  }
}

// Response:
{
  "post": {
    "id": "1",
    "title": "Updated Title",
    "body": "Content...",
    "published": false
  }
}
```

### Destroy (Member)

Returns an empty response:

```json
// DELETE /api/v1/posts/1

{}
```

## Generated Types

From a schema, Apiwork generates these types:

| Type | Purpose | Generated From |
|------|---------|----------------|
| `post` | Resource representation | All attributes + associations |
| `post_filter` | Filter operators | Attributes with `filterable: true` |
| `post_sort` | Sort directions | Attributes with `sortable: true` |
| `post_include` | Association inclusion | Associations |
| `create_payload` | Create request body | Attributes with `writable: true` |
| `update_payload` | Update request body | Attributes with `writable: true` |
| `page_pagination` | Pagination metadata | Automatic |

```typescript
// TypeScript output for PostSchema

export interface Post {
  id?: string;
  title?: string;
  body?: string;
  published?: boolean;
  created_at?: string;
  comments?: Comment[];
}

export interface PostFilter {
  title?: StringFilter;
  published?: BooleanFilter;
  created_at?: DatetimeFilter;
  _and?: PostFilter[];
  _or?: PostFilter[];
  _not?: PostFilter;
}

export interface PostSort {
  title?: 'asc' | 'desc';
  created_at?: 'asc' | 'desc';
}

export interface CreatePayload {
  title: string;
  body?: string;
  published?: boolean;
}

export interface UpdatePayload {
  title?: string;
  body?: string;
  published?: boolean;
}
```

## Custom Actions

Custom actions inherit default structures based on their type:

### Member Actions

```ruby
member do
  post :archive
  get :preview
end
```

Member actions return a single resource:

```json
// POST /api/v1/posts/1/archive
{
  "post": { "id": "1", "title": "...", "archived": true }
}
```

### Collection Actions

```ruby
collection do
  get :search
  post :import
end
```

Collection actions return a paginated list:

```json
// GET /api/v1/posts/search?q=ruby
{
  "posts": [...],
  "pagination": {...}
}
```

## Overriding Defaults

Use `replace: true` to completely replace the default structure.

### Replace Response

```ruby
action :destroy do
  response replace: true do
    body do
      param :deleted_id, type: :uuid, required: true
      param :deleted_at, type: :datetime, required: true
    end
  end
end
```

```json
// DELETE /api/v1/posts/1
{
  "deleted_id": "abc-123",
  "deleted_at": "2024-01-15T10:00:00Z"
}
```

### Replace Request

```ruby
collection do
  post :bulk_create do
    request replace: true do
      body do
        param :posts, type: :array, of: :create_payload, required: true
      end
    end
  end
end
```

```json
// POST /api/v1/posts/bulk_create
{
  "posts": [
    { "title": "First" },
    { "title": "Second" }
  ]
}
```

### Add to Defaults (Without Replace)

Without `replace: true`, your params are added to the defaults:

```ruby
action :create do
  request do
    body do
      param :notify_subscribers, type: :boolean, default: false
    end
  end
end
```

This adds `notify_subscribers` alongside the default `post` payload.

## Response Structure Options

### Meta Field

All responses can include optional metadata:

```json
{
  "post": {...},
  "meta": {
    "cache_hit": true,
    "generated_at": "2024-01-15T10:00:00Z"
  }
}
```

### Issues Field

Validation warnings (non-fatal) can be included:

```json
{
  "post": {...},
  "issues": [
    {
      "code": "deprecated_field",
      "detail": "The 'legacy_id' field will be removed in v2"
    }
  ]
}
```

## Without schema!

If you don't use `schema!`, you must define everything manually:

```ruby
class CustomContract < Apiwork::Contract::Base
  # No schema! - manual definition required

  action :index do
    response do
      body do
        param :items, type: :array, of: :object do
          param :id, type: :string
          param :name, type: :string
        end
      end
    end
  end
end
```

This is useful for non-resource endpoints like authentication or webhooks.
