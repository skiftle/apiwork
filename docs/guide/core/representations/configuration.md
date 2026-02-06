---
order: 7
---

# Configuration

Override representation-level settings for root keys and adapter options.

## Root Key

By default, representations derive the JSON root key from the model name:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  model Post
end

# Response: { "post": {...} } or { "posts": [...] }
```

Override with custom keys:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  root :article
  # Response: { "article": {...} } or { "articles": [...] }
end
```

Specify both singular and plural:

```ruby
class PersonRepresentation < Apiwork::Representation::Base
  root :person, :people
end
```

## Adapter Configuration

Adapters may provide configuration options that can be set at the API or representation level. Representations can override API-level adapter settings.

```ruby
class ActivityRepresentation < Apiwork::Representation::Base
  adapter do
    # Adapter-specific options
  end
end
```

Settings resolve in this order (first defined wins):

1. **Representation** `adapter` block — most specific
2. **API definition** `adapter` block — API-wide defaults
3. **Adapter defaults** — built-in fallbacks

For standard adapter options like pagination strategies, see [Standard Adapter: Pagination](../adapters/standard-adapter/pagination.md).

#### See also

- [Representation::Base reference](../../../reference/representation/base.md) — `root` and `adapter` methods
