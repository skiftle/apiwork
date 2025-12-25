---
order: 2
---

# API Introspection

Returns the complete API structure:

```ruby
Apiwork::API.introspect('/api/v1')
Apiwork::API.introspect('/api/v1', locale: :sv)
```

---

## What's Included

- All resources and nested resources
- All actions with request and response definitions
- All types and enums (global and resource-scoped)
- Error codes that actions can raise
- API metadata

---

## Locale

Pass `locale:` for translated descriptions:

```ruby
Apiwork::API.introspect('/api/v1', locale: :sv)
```

Translations come from your I18n files. See [i18n](../../advanced/i18n.md) for configuration.

---

## Caching

Results are cached per locale:

```ruby
Apiwork::API.introspect('/api/v1')              # cached
Apiwork::API.introspect('/api/v1')              # returns cached
Apiwork::API.introspect('/api/v1', locale: :sv) # separate cache entry
```

Call `reset_contracts!` to clear the cache:

```ruby
api = Apiwork::API.find('/api/v1')
api.reset_contracts!
```

::: tip
In development, Rails reloading clears caches automatically.
:::
