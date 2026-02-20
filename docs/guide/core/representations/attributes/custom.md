---
order: 3
---

# Custom

Attributes don't need to map to model columns. Define a method with the same name to create a virtual attribute.

## Basic Usage

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :full_title, type: :string

  def full_title
    "#{record.status.upcase}: #{record.number}"
  end
end
```

The `record` method returns the current record.

::: warning Explicit Type Required
Custom attributes require an explicit `type`. There's no model column to infer from.
:::

## Preloading

Custom attributes that access associations cause N+1 queries:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :item_count, type: :integer

  def item_count
    record.items.size  # N+1: one query per invoice
  end
end
```

Use `preload:` to eager load associations:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :item_count, type: :integer, preload: :items

  def item_count
    record.items.size  # Items already loaded
  end
end
```

The format matches Rails `includes`:

```ruby
# Single association
preload: :items

# Multiple associations
preload: [:items, :customer]

# Nested associations
preload: { items: :adjustments }
```

Apiwork combines preloads with other includes (such as sideloaded associations) into a single query.
