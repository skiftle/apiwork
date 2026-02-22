---
order: 3
---

# Contract Introspection

Returns a single contract's structure as an [Introspection::Contract](../../../reference/apiwork/introspection/contract.md) object.

```ruby
contract = InvoiceContract.introspect
```

---

## Accessors

| Method | Returns |
|--------|---------|
| `actions` | Hash of [Action](../../../reference/apiwork/introspection/action/) objects |
| `types` | Hash of [Type](../../../reference/apiwork/introspection/type.md) objects |
| `enums` | Hash of [Enum](../../../reference/apiwork/introspection/enum.md) objects |

---

## Actions

```ruby
action = contract.actions[:create]

action.method      # => :post
action.path        # => "/invoices"
action.raises      # => [:bad_request, :not_found, :unprocessable_entity]
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

By default, only types defined in the contract are included. Pass `expand: true` to include referenced types (useful for debugging or export generation):

```ruby
InvoiceContract.introspect
# types: { invoice_filter: {...} }
```

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

Translations come from your I18n files.

---

## Caching

Results are cached per contract, locale, and expand. In development, Rails reloading clears caches automatically.

#### See also

- [Introspection::Contract reference](../../../reference/apiwork/introspection/contract.md) — all introspection methods
