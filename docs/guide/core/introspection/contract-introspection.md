---
order: 3
---

# Contract Introspection

During development, you may need to understand exactly what a contract exposes. This is especially useful because the adapter may generate types dynamically based on your schema — filters, pagination, sorting, payloads — that don't exist as explicit code.

Call `introspect` in the Rails console:

```ruby
InvoiceContract.introspect
```

This returns actions, request shapes, response types, and all types scoped to the contract.

---

## What's Included

- Actions defined on the contract
- Types and enums **scoped** to the contract

---

## Expand Mode

By default, referenced types are not included:

```ruby
InvoiceContract.introspect
# => { actions: {...}, types: { invoice_filter: {...} } }
```

Pass `expand: true` to resolve all referenced types:

```ruby
InvoiceContract.introspect(expand: true)
# => {
#   actions: {...},
#   types: {
#     invoice_filter: {...},
#     datetime_filter: {...},
#     string_filter: {...},
#     offset_pagination: {...}
#   }
# }
```

---

## Caching

Results are cached per contract, locale, and expand:

```ruby
InvoiceContract.introspect                   # cached
InvoiceContract.introspect(expand: true)     # separate cache entry
InvoiceContract.introspect(locale: :sv)      # separate cache entry
```

Call `reset_contracts!` to clear the cache:

```ruby
api = Apiwork::API.find('/api/v1')
api.reset_contracts!
```

::: tip
In development, Rails reloading clears caches automatically.
:::
