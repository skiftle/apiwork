---
order: 8
---

# Declaration Merging

Types are open for extension. Multiple declarations of the same type merge together.

## How It Works

```ruby
object :address do
  string :street
  string :city
end

object :address, description: "A physical address"

object :address do
  string :country_code
end
```

The result is a single `:address` object with three params and a description.

## Merge Behavior

For metadata fields like `description`, `example`, `format`, and `deprecated` — the last declaration wins. If the same object is declared twice with different descriptions, the second one is used.

```ruby
object :user, description: "First"
object :user, description: "Second"  # This wins
```

For params, new params are added and existing params are extended:

```ruby
object :user do
  string :name
end

object :user do
  string :name, description: "Full name"  # Adds description to existing param
  string :email                           # Adds new param
end
```

For enums, metadata merges but values replace entirely:

```ruby
enum :status, values: %w[pending active]
enum :status, description: "Account status"  # Adds description, keeps values

enum :status, values: %w[pending active archived]  # Replaces all values
```

## TypeScript Analogy

In TypeScript terms, think of it like interface merging:

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

When using [`representation`](../representations/), types are generated that are not directly controlled — filter types, sort types, pagination types. Declaration merging makes it possible to add metadata like descriptions to these types.

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation

  # Add description to the auto-generated filter object
  object :filter, description: "Filter invoices by date, status, or customer"

  # Add a custom param to the filter
  object :filter do
    string :search, description: "Full-text search"
  end

  # Add description to an existing param
  object :filter do
    string :status, description: "Filter by one or more statuses"
  end
end
```

The same works for enums:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation

  enum :status, description: "Invoice lifecycle status"
end
```

#### See also

- [Type Reuse](./type-reuse.md) — inheritance and composition with `extends` and `merge`
- [Contract::Base reference](../../reference/contract/base.md) — type definition methods
