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

### meta

For response data that doesn't belong to the resource itself:

```ruby
action :index do
  response do
    body do
      meta do
        param :generated_at, type: :datetime
        param :api_version, type: :string
      end
    end
  end
end
```

This is shorthand for `param :meta, type: :object do ... end`.

For optional meta, pass `optional: true`:

```ruby
meta optional: true do
  param :request_id, type: :uuid
end
```

In your controller, pass values via the `meta:` keyword:

```ruby
def index
  posts = Post.all
  respond posts, meta: {
    generated_at: Time.current,
    api_version: 'v1'
  }
end
```

Response:

```json
{
  "posts": [...],
  "meta": {
    "generated_at": "2024-01-15T10:30:00Z",
    "api_version": "v1"
  }
}
```

### replace

When using `schema!`, the adapter auto-generates request and response definitions from your schema attributes. By default, your custom definitions are merged with these auto-generated ones.

Use `replace: true` to reset the auto-generated definition and start fresh:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!  # Auto-generates request/response from schema

  action :destroy do
    # Reset auto-generated response, define custom
    response replace: true do
      body do
        param :deleted_id, type: :uuid
      end
    end
  end

  action :create do
    # Reset auto-generated request body, define custom
    request replace: true do
      body do
        param :title, type: :string
      end
    end
  end
end
```

Without `replace: true`, your params would be added to the schema-generated ones. With `replace: true`, only your explicitly defined params are used.

### no_content!

For actions that return HTTP 204 No Content (no response body):

```ruby
action :destroy do
  response do
    no_content!
  end
end
```

**Generated output:**

- OpenAPI: `204 No Content` (no `content` key)
- TypeScript: `never`
- Zod: `z.never()`

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

| Field          | Description                                    |
| -------------- | ---------------------------------------------- |
| `summary`      | One-line description. Shows in endpoint lists. |
| `description`  | Longer description. Supports markdown.         |
| `tags`         | Action-specific tags for grouping.             |
| `deprecated`   | Marks the action as deprecated.                |
| `operation_id` | Explicit operation ID for OpenAPI.             |

### Translations

Summaries and descriptions can be translated. Define them in locale files instead of inline, and they'll change with `I18n.locale`.

[i18n: Action Metadata](../../advanced/i18n.md#action-metadata) shows how to set up locale files for multilingual documentation.
