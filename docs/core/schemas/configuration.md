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

Schemas inherit adapter settings from the API definition. Override per-schema when needed:

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

1. Schema `adapter` block
2. API definition `adapter` block
3. Adapter defaults
