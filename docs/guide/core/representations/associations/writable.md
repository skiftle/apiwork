---
order: 4
---

# Writable

Create and update associated records through nested attributes.

## Basic Usage

```ruby
has_many :items, writable: true
```

## Rails Requirement

Your model must declare `accepts_nested_attributes_for` on the association:

```ruby
class Invoice < ApplicationRecord
  has_many :items
  accepts_nested_attributes_for :items, allow_destroy: true
end
```

::: warning
Without `accepts_nested_attributes_for`, Apiwork raises a `ConfigurationError` when the representation loads.
:::

## Context-Specific Writing

```ruby
has_many :items, writable: :create     # Only on create
has_many :items, writable: :update     # Only on update
has_many :items, writable: true        # Both
```

## Request Format

The request format for nested operations depends on your adapter. Each adapter defines how to express create, update, and delete operations.

::: tip Standard Adapter
The [Standard Adapter](../../adapters/standard-adapter/writing.md#nested-associations) uses an `OP` discriminator field to specify operations. See the writing guide for the complete request format.
:::

## Deep Nesting

Nested attributes work at multiple levels. For example, Invoices with Items with Adjustments:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number
  has_many :items, writable: true
end

class ItemRepresentation < Apiwork::Representation::Base
  attribute :description
  has_many :adjustments, writable: true
end

class AdjustmentRepresentation < Apiwork::Representation::Base
  attribute :amount
end
```

With corresponding Rails models:

```ruby
class Invoice < ApplicationRecord
  has_many :items
  accepts_nested_attributes_for :items, allow_destroy: true
end

class Item < ApplicationRecord
  has_many :adjustments
  accepts_nested_attributes_for :adjustments, allow_destroy: true
end
```

This enables creating an invoice with items and adjustments in a single request. All standard operations (create, update, delete) work at each level. The request format depends on your adapter.

## Generated Types

Generated payload types depend on your adapter. See your adapter's documentation for the TypeScript/Zod types it generates.

::: tip Standard Adapter
The [Standard Adapter](../../adapters/standard-adapter/writing.md#generated-types) generates discriminated union types with an `OP` field for create, update, and delete operations.
:::

## Examples

- [Nested Saves](/examples/nested-saves.md) — Create/update/delete nested records in a single request
