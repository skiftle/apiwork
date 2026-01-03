---
order: 3
---

# Contract Introspection

Returns a single contract's structure as an [Introspection::Contract](../../../reference/introspection-contract.md) object. Useful during development to understand what a contract exposes, including dynamically generated types.

```ruby
contract = InvoiceContract.introspect
```

---

## Accessors

| Method | Returns |
|--------|---------|
| `actions` | Hash of [Action](../../../reference/introspection-action.md) objects |
| `types` | Hash of [Type](../../../reference/introspection-type.md) objects |
| `enums` | Hash of [Enum](../../../reference/introspection-enum.md) objects |

---

## Actions

```ruby
action = contract.actions[:create]

action.method      # => :post
action.path        # => "/"
action.raises      # => [:unprocessable_entity]
action.deprecated? # => false
```

---

## Request and Response

```ruby
request = action.request
request.query?  # => false
request.body?   # => true

request.body.each do |name, param|
  puts "#{name}: #{param.type}"
end
```

```ruby
response = action.response
response.no_content?  # => false

body = response.body
body.object?          # => true
body.shape[:invoice]  # => Param for the invoice
```

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

Results are cached per contract, locale, and expand. In development, Rails reloading clears caches automatically.
