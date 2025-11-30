---
order: 5
---

# Action Conventions

When a schema is connected to a contract via `schema!`, Apiwork generates default request and response structures based on the action type.

## Default Behaviors

| Action | Request Query | Request Body | Response Body |
|--------|---------------|--------------|---------------|
| `index` | filter, sort, page, include | — | `{ posts: [...], pagination, meta }` |
| `show` | include | — | `{ post: {...}, meta }` |
| `create` | include | `{ post: {...} }` | `{ post: {...}, meta }` |
| `update` | include | `{ post: {...} }` | `{ post: {...}, meta }` |
| `destroy` | — | — | `{}` |
| custom member | include | — | `{ post: {...}, meta }` |
| custom collection | — | — | `{}` |

## Standard Actions

### Index

Returns a paginated collection with query capabilities:

```ruby
# Auto-generated request query
param :filter, type: :union do
  variant type: :post_filter
  variant type: :array, of: :post_filter
end
param :sort, type: :union do
  variant type: :post_sort
  variant type: :array, of: :post_sort
end
param :page, type: :page
param :include, type: :post_include

# Auto-generated response
param :posts, type: :array, of: :post
param :pagination, type: :page_pagination
param :meta, type: :object
```

### Show

Returns a single resource:

```ruby
# Auto-generated request query
param :include, type: :post_include

# Auto-generated response
param :post, type: :post
param :meta, type: :object
```

### Create & Update

Accept writable attributes, return the resource:

```ruby
# Auto-generated request body (create)
param :post, type: :create_payload, required: true

# Auto-generated request body (update)
param :post, type: :update_payload, required: true

# Auto-generated response (same for both)
param :post, type: :post
param :meta, type: :object
```

### Destroy

Returns an empty response:

```ruby
# No request body
# Empty response body
```

## Custom Actions

### Member Actions

Member actions (routes like `/posts/:id/archive`) default to returning a single resource:

```ruby
member do
  post :archive
  get :preview
end
```

```ruby
# Auto-generated response
param :post, type: :post
param :meta, type: :object
```

No request body is generated because custom member actions vary too much to assume a default structure.

### Collection Actions

Collection actions (routes like `/posts/search`) default to empty request and response:

```ruby
collection do
  get :search
  post :import
end
```

```ruby
# No auto-generated request or response
```

This is by design. Collection actions vary significantly — a search endpoint needs query params, an import endpoint needs a file upload, a stats endpoint returns aggregates. Rather than guess wrong, Apiwork requires explicit definition.

## Design Rationale

The defaults follow common REST patterns:

- **CRUD actions** have predictable structures, so Apiwork generates them
- **Custom member actions** typically modify a resource and return it, so Apiwork generates the response
- **Custom collection actions** have no common pattern, so Apiwork generates nothing

This approach minimizes boilerplate for standard operations while requiring explicit definitions for non-standard ones.

## Overriding Defaults

### Adding Fields (Deep Merge)

Without `replace: true`, your definitions merge with the defaults:

```ruby
action :show do
  response do
    body do
      param :view_count, type: :integer
    end
  end
end
```

Result: `{ post: {...}, meta: {...}, view_count: 123 }`

### Typed Meta

The default `meta` is untyped (`type: :object`). Use the `meta` helper to define its structure:

```ruby
action :index do
  response do
    body do
      meta do
        param :total_value, type: :decimal
        param :generated_at, type: :datetime
      end
    end
  end
end
```

```json
{
  "posts": [...],
  "pagination": {...},
  "meta": {
    "total_value": "1234.56",
    "generated_at": "2024-01-15T10:00:00Z"
  }
}
```

### Replacing Defaults

Use `replace: true` to completely override the default structure:

```ruby
action :destroy do
  response replace: true do
    body do
      param :deleted_id, type: :uuid
      param :deleted_at, type: :datetime
    end
  end
end
```

```json
{
  "deleted_id": "abc-123",
  "deleted_at": "2024-01-15T10:00:00Z"
}
```

### Custom Collection Action with Full Definition

```ruby
collection do
  get :search
end

action :search do
  request do
    query do
      param :q, type: :string, required: true
      param :category, type: :string
    end
  end

  response do
    body do
      param :posts, type: :array, of: :post
      param :pagination, type: :page_pagination

      meta do
        param :query, type: :string
        param :result_count, type: :integer
      end
    end
  end
end
```

### Custom Member Action with Request Body

```ruby
member do
  post :archive
end

action :archive do
  request do
    body do
      param :reason, type: :string
      param :notify_subscribers, type: :boolean, default: false
    end
  end

  # Response uses default (returns post)
end
```

## Summary

| Scenario | What Happens |
|----------|--------------|
| Standard CRUD | Fully generated |
| Custom member | Response generated, no request body |
| Custom collection | Nothing generated |
| Adding params | Deep merged with defaults |
| `replace: true` | Completely replaces defaults |
| `meta do` | Defines typed meta structure |
