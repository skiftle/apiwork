---
order: 2
---

# Actions

Actions define the request and response structure for each endpoint.

```ruby
# app/contracts/api/v1/post_contract.rb
action :create do
  request do
    body do
      string :title
    end
  end

  response do
    body do
      integer :id
      string :title
    end
  end
end
```

```ruby
# app/controllers/api/v1/posts_controller.rb
def create
  post = Post.create(contract.body) # { title: }
  expose post # { id:, title: }
end
```

## Request

### query

For GET parameters:

```ruby
action :search do
  request do
    query do
      string :q
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
      object :post do
        string :title
        string :body
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
      integer :id
      string :title
      datetime :created_at
    end
  end
end
```

### meta

Shorthand for `object :meta do ... end`. Use for response data that doesn't belong to the resource itself:

```ruby
action :index do
  response do
    body do
      meta do
        datetime :generated_at
        string :api_version
      end
    end
  end
end
```

For optional meta, pass `optional: true`:

```ruby
meta optional: true do
  uuid :request_id
end
```

In your controller, pass values via the `meta:` keyword:

```ruby
def index
  posts = Post.all
  expose posts, meta: {
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

### no_content!

For actions that return HTTP 204 No Content:

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

::: info Default for destroy
The adapter uses `no_content!` by default for destroy actions. Override with `replace: true` if you need to return data.
:::

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

These appear in generated [OpenAPI exports](../exports/openapi.md) as possible error responses. You can also declare raises at the [API level](../api-definitions/configuration.md#raises) for errors common to all endpoints.

## Declaration Merging

Actions support declaration merging. When you define an action that already exists, the definitions combine rather than replace.

::: info Same pattern for types
This is the same merge behavior used for [types](../types/declaration-merging.md). The concept applies consistently across Apiwork.
:::

### The Concept

```typescript
// TypeScript interface merging
interface CreateRequest {
  body: { title: string };
}

interface CreateRequest {
  body: { priority: string };
}

// Result: { title: string; priority: string }
```

Apiwork works the same way:

```ruby
# Representation-generated (via adapter)
action :create do
  request do
    body do
      string :title
      decimal :amount
      string :status
    end
  end
end

# Your definition (in contract)
action :create do
  request do
    body { string :priority }
  end
end

# Result: body has ALL params (title, amount, status, priority)
```

### Deep Merge

Merging happens at every level of the hierarchy:

| Level                  | Merge behavior                           |
| ---------------------- | ---------------------------------------- |
| `action`               | Same action name merges request/response |
| `request` / `response` | Merge query/body definitions             |
| `query` / `body`       | Merge params                             |
| Nested `param`         | Merge nested shapes recursively          |

Example of deep merge:

```ruby
# First definition
action :create do
  request do
    body do
      object :invoice do
        string :title
      end
    end
  end
end

# Second definition (merges)
action :create do
  request do
    body do
      object :invoice do
        string :priority  # Added to existing :invoice
      end
    end
  end
end

# Result: :invoice has BOTH :title AND :priority
```

### With representation

When using `representation`, the adapter auto-generates request and response definitions from your representation attributes. Your custom definitions merge with these:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation  # Generates: body { string :title; decimal :amount; ... }

  action :create do
    request do
      body do
        object :invoice do
          string :priority  # Added to representation params
        end
      end
    end
  end
end
```

### Opting Out with replace

Use `replace: true` when you want **only** your params, not merged with auto-generated:

```ruby
action :create do
  request replace: true do
    body do
      object :invoice do
        string :title  # ONLY this, no representation params
      end
    end
  end
end
```

`replace: true` can be used on:

- `request replace: true` — replace entire request
- `response replace: true` — replace entire response

::: tip When to use replace

- **Destroy actions** that return metadata instead of the resource
- **Custom endpoints** with completely different shapes
- **Minimal requests** that only accept specific fields
  :::

::: info raises always merges
`raises` has no `replace:` option. You cannot opt out of errors the adapter may throw (like `:unprocessable_entity`).
:::

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
  deprecated!
  operation_id "createPost"

  raises :unprocessable_entity

  request do
    body do
      string :title
    end
  end
end
```

### Metadata Fields

| Field          | Description                                   |
| -------------- | --------------------------------------------- |
| `summary`      | One-line description, shows in endpoint lists |
| `description`  | Longer description, supports markdown         |
| `tags`         | Action-specific tags for grouping             |
| `deprecated`   | Marks the action as deprecated                |
| `operation_id` | Explicit operation ID for OpenAPI             |

### Translations

Summaries and descriptions can be translated. Define them in locale files instead of inline, and they'll change with `I18n.locale`.

#### See also

- [Contract::Action reference](../../../reference/contract-action.md) — all action methods and options
