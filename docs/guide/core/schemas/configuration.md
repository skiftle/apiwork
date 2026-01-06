---
order: 7
---

# Configuration

Override schema-level settings for root keys and adapter options.

## Root Key

By default, schemas derive the JSON root key from the model name:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post
end

# Response: { "post": {...} } or { "posts": [...] }
```

Override with custom keys:

```ruby
class PostSchema < Apiwork::Schema::Base
  root :article
  # Response: { "article": {...} } or { "articles": [...] }
end
```

Specify both singular and plural:

```ruby
class PersonSchema < Apiwork::Schema::Base
  root :person, :people
end
```

## Adapter Configuration

Schemas inherit adapter settings from the [API definition](/guide/core/api-definitions/introduction). Override per-schema when needed:

```ruby
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
      max_size 150
    end
  end
end
```

### Pagination Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `strategy` | `:offset`, `:cursor` | `:offset` | Pagination style |
| `default_size` | Integer | 20 | Items per page when not specified |
| `max_size` | Integer | 100 | Maximum allowed page size |

### Resolution Order

Settings resolve in this order (first defined wins):

1. **Schema** `adapter` block — most specific
2. **[API definition](/guide/core/api-definitions/introduction)** `adapter` block — API-wide defaults
3. **Adapter defaults** — built-in fallbacks

Example:

```ruby
# API definition: all resources default to 25 items per page
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      default_size 25
      max_size 100
    end
  end

  resources :posts
  resources :activities
end

# ActivitySchema overrides with cursor pagination and larger page size
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end
```

In this example:
- `GET /posts` uses offset pagination with 25 items (from API)
- `GET /activities` uses cursor pagination with 50 items (from Schema)
- Both respect the API-level `max_size: 100` since ActivitySchema didn't override it

#### See also

- [Schema::Base reference](../../../reference/schema-base.md) — `root` and `adapter` methods
