---
order: 6
---

# Merging

Objects are open for extension. Multiple declarations of the same object merge together.

## How It Works

```ruby
object :address do
  param :street, type: :string
  param :city, type: :string
end

object :address, description: "A physical address"

object :address do
  param :country_code, type: :string
end
```

The result is a single `:address` object with three params and a description.

## Merge Behavior

For metadata fields like `description`, `example`, `format`, and `deprecated` — the last declaration wins. If you declare the same object twice with different descriptions, the second one is used.

```ruby
object :user, description: "First"
object :user, description: "Second"  # This wins
```

For params, new params are added and existing params are extended:

```ruby
object :user do
  param :name, type: :string
end

object :user do
  param :name, description: "Full name"  # Adds description to existing param
  param :email, type: :string            # Adds new param
end
```

For enums, metadata merges but values replace entirely:

```ruby
enum :status, values: %w[pending active]
enum :status, description: "Account status"  # Adds description, keeps values

enum :status, values: %w[pending active archived]  # Replaces all values
```

## TypeScript Analogy

If you know TypeScript, think of it like interface merging:

```typescript
interface Address {
  street: string;
  city: string;
}

interface Address {
  country: string;
}

// Result: merged interface with all three fields
```

## Extending Generated Types

When using [`schema!`](../schemas/introduction.md), types are generated that you don't control directly — filter types, sort types, pagination types. Merging makes it possible to add metadata like descriptions to these types.

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  # Add description to the auto-generated filter object
  object :filter, description: "Filter invoices by date, status, or customer"

  # Add a custom param to the filter
  object :filter do
    param :search, type: :string, description: "Full-text search"
  end

  # Add description to an existing param
  object :filter do
    param :status, description: "Filter by one or more statuses"
  end
end
```

The same works for enums:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  enum :status, description: "Invoice lifecycle status"
end
```

## i18n Alternative

You can also use [i18n](/guide/advanced/i18n) for descriptions:

```yaml
# config/locales/apiwork.en.yml
en:
  apiwork:
    types:
      invoice_filter:
        description: "Filter invoices by date, status, or customer"
```

Merging takes precedence over i18n.

#### See also

- [Contract::Base reference](../../../reference/contract-base.md) — type definition methods
