---
order: 2
---

# Actions

Actions define the request and response structure for its endpoint.

```ruby
action :create do
  request do
    body do
      param :title, type: :string
    end
  end

  response do
    body do
      param :id, type: :integer
      param :title, type: :string
    end
  end
end
```

## Request

### query

For GET parameters:

```ruby
action :search do
  request do
    query do
      param :q, type: :string
    end
  end
end
```

### body

For POST/PATCH request body:

```ruby
action :create do
  request do
    body do
      param :post, type: :object do
        param :title, type: :string
        param :body, type: :string
      end
    end
  end
end
```

## Response

### body

Define the response structure:

```ruby
action :show do
  response do
    body do
      param :id, type: :integer
      param :title, type: :string
      param :created_at, type: :datetime
    end
  end
end
```

### replace

By default, contract requests and responses are merged with schema definitions. Use `replace: true` to completely override:

```ruby
action :destroy do
  # Replace the response entirely
  response replace: true do
    body do
      param :deleted_id, type: :uuid
    end
  end
end

action :create do
  # Replace the request entirely
  request replace: true do
    body do
      param :title, type: :string, required: true
    end
  end
end
```

## Raises

Declare which errors an action can raise:

```ruby
action :show do
  raises :not_found, :forbidden
end

action :create do
  raises :unprocessable_entity
end
```

These appear in generated OpenAPI specs as possible error responses.

## Metadata

Document actions with metadata fields:

```ruby
action :index do
  summary "List all posts"
  description "Returns a paginated list of posts"
  tags :posts, :public
end

action :create do
  summary "Create a post"
  deprecated true
  operation_id "createPost"

  raises :unprocessable_entity

  request do
    body do
      param :title, type: :string
    end
  end
end
```

### Metadata Fields

| Field | Description |
|-------|-------------|
| `summary` | One-line description. Shows in endpoint lists. |
| `description` | Longer description. Supports markdown. |
| `tags` | Action-specific tags for grouping. |
| `deprecated` | Marks the action as deprecated. |
| `operation_id` | Explicit operation ID for OpenAPI. |

### Translations

Summaries and descriptions can be translated. Define them in locale files instead of inline, and they'll change with `I18n.locale`.

See [i18n: Action Metadata](../../advanced/i18n.md#action-metadata) for the full guide.
