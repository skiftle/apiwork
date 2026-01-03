---
order: 3
---

# Contract Introspection

Returns a single contract's structure as an [Introspection::Contract](../../reference/introspection-contract.md) object. Useful during development to understand what a contract exposes, including dynamically generated types.

```ruby
data = InvoiceContract.introspect
```

---

## Accessing Data

```ruby
data.actions.each do |name, action|
  puts "#{action.method.upcase} #{action.path}"
end

data.types.each do |name, type|
  puts "#{name}: #{type.object? ? 'object' : 'union'}"
end
```

---

## What's Included

- Actions defined on the contract
- Types and enums **scoped** to the contract

---

## Expand Mode

By default, referenced types are not included:

```ruby
InvoiceContract.introspect
# types: { invoice_filter: {...} }
```

Pass `expand: true` to resolve all referenced types:

```ruby
InvoiceContract.introspect(expand: true)
# types: { invoice_filter: {...}, datetime_filter: {...}, ... }
```

---

## Locale

Pass `locale:` for translated descriptions:

```ruby
InvoiceContract.introspect(locale: :sv)
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
api_class = Apiwork::API.find('/api/v1')
api_class.reset_contracts!
```

::: tip
In development, Rails reloading clears caches automatically.
:::
