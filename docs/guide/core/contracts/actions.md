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

Define the structure of response metadata:

```ruby
action :index do
  response do
    meta do
      param :generated_at, type: :datetime
      param :api_version, type: :string
    end
  end
end
```

This is shorthand for `param :meta, type: :object do ... end`.

In your controller, pass the values:

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

The `meta` block documents the shape. The controller provides the values.

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
      param :title, type: :string
    end
  end
end
```

### no_content!

For actions that return HTTP 204 No Content (no response body):

```ruby
action :soft_delete do
  response { no_content! }
end
```

This is the **default for DELETE method actions** (including `destroy`).

**Generated output:**

- OpenAPI: `204 No Content` (no `content` key)
- TypeScript: `never`
- Zod: `z.never()`

To return data instead:

```ruby
action :destroy do
  response do
    body do
      param :deleted_at, type: :datetime
    end
  end
end
```

**Important:** `meta` cannot be used with `no_content!` since 204 has no body.
If you need `meta`, use an empty response instead:

```ruby
action :destroy do
  response {}  # 200 OK with { meta?: object }
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
