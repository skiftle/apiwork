---
order: 6
---

# Single Table Inheritance

Apiwork automatically detects Rails STI hierarchies. Subclass representations register themselves when defined.

## Basic Setup

### Base Representation

The base representation defines attributes shared by all variants:

```ruby
class VehicleRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :brand
  attribute :model
end
```

### Subclass Representations

Subclass representations inherit from the base and add variant-specific attributes:

```ruby
class CarRepresentation < VehicleRepresentation
  attribute :doors
end

class MotorcycleRepresentation < VehicleRepresentation
  attribute :engine_cc
end
```

Apiwork detects the STI relationship from the Rails models and registers the subclasses automatically.

## Custom Type Names

By default, the discriminator value is the model's `sti_name` (e.g., `"Car"`). Use `type_name` for custom API names:

```ruby
class CarRepresentation < VehicleRepresentation
  type_name :car  # API shows "car" instead of "Car"

  attribute :doors
end
```

## How It Works

When Apiwork detects an STI model:

1. An `Inheritance` instance is created on the base representation
2. Subclass representations auto-register when defined
3. The base representation becomes abstract

STI metadata is accessible through the base representation:

```ruby
VehicleRepresentation.inheritance.column      # => :type (from Rails)
VehicleRepresentation.inheritance.subclasses  # => [CarRepresentation, ...]
```

## Serialization

The adapter handles serialization. The [standard adapter](../adapters/standard-adapter/):

- Resolves each record to its correct subclass representation
- Adds the discriminator field to the output
- Serializes variant-specific attributes

```json
{
  "type": "car",
  "brand": "Volvo",
  "model": "EX30",
  "doors": 4
}
```

## Generated Types

The adapter generates types from STI metadata. The standard adapter creates discriminated unions.

### TypeScript

```typescript
export interface Car {
  type: 'car';
  brand: string;
  model: string;
  doors: number | null;
}

export interface Motorcycle {
  type: 'motorcycle';
  brand: string;
  model: string;
  engine_cc: number | null;
}

export type Vehicle = Car | Motorcycle;
```

### OpenAPI

```yaml
Vehicle:
  oneOf:
    - $ref: '#/components/schemas/Car'
    - $ref: '#/components/schemas/Motorcycle'
  discriminator:
    propertyName: type
    mapping:
      car: '#/components/schemas/Car'
      motorcycle: '#/components/schemas/Motorcycle'
```

## Requirements

STI requires:

- Rails model with STI configured (`inheritance_column`)
- `type` column in database (or custom `inheritance_column`)
- Subclass representations that inherit from base representation

#### See also

- [Representation::Base reference](../../reference/representation/base.md) — `type_name`, `sti_name`, `inheritance`
- [Representation::Inheritance reference](../../reference/representation/inheritance.md) — inheritance metadata
