---
order: 6
---

# Single Table Inheritance

Apiwork represents Rails Single Table Inheritance (STI) hierarchies as [discriminated unions](../types/unions.md#discriminated-unions). The base class becomes a union type, each subclass becomes a variant, and a discriminator field identifies which variant a record belongs to. This enables type-safe serialization where each variant includes only its own attributes.

## Setup

### Base Representation

Mark a representation as discriminated:

```ruby
class VehicleRepresentation < Apiwork::Representation::Base
  discriminated!

  attribute :brand
  attribute :model
end
```

### Variant Representations

Register subclasses with `variant`:

```ruby
class CarRepresentation < VehicleRepresentation
  variant

  attribute :doors
end

class MotorcycleRepresentation < VehicleRepresentation
  variant

  attribute :sidecar
end
```

## Customization

Apiwork infers defaults from Rails:

- Discriminator column: `inheritance_column` (typically `:type`)
- Discriminator key: same as column name
- Variant tag: model's `sti_name` (e.g., `"Car"`)

Override when these don't fit:

```ruby
class VehicleRepresentation < Apiwork::Representation::Base
  discriminated! as: :kind # key "kind" instead of "type"
end

class CarRepresentation < VehicleRepresentation
  variant as: :car # tag "car" instead of "Car"
end
```

Use `by:` to change the database column:

```ruby
discriminated! as: :kind, by: :category  # column "category", key "kind"
```

## Serialization

Records serialize with their variant's attributes:

```ruby
Car.create!(brand: "Volvo", model: "EX30", doors: 4)
```

```json
{
  "type": "Car",
  "brand": "Volvo",
  "model": "EX30",
  "doors": 4
}
```

## Exports

[Exports](../exports/introduction.md) represent discriminated unions natively in each format.

### OpenAPI

```yaml
vehicle:
  oneOf:
    - $ref: '#/components/representations/car'
    - $ref: '#/components/representations/motorcycle'
  discriminator:
    mapping:
      Car: '#/components/representations/car'
      Motorcycle: '#/components/representations/motorcycle'
    propertyName: type
```

### TypeScript

```typescript
export interface Car {
  type: 'Car';
  brand: string;
  model: string;
  doors: null | number;
}

export interface Motorcycle {
  type: 'Motorcycle';
  brand: string;
  model: string;
  sidecar: boolean;
}

export type Vehicle = Car | Motorcycle;
```

### Zod

```typescript
export const CarRepresentation = z.object({
  type: z.literal('Car'),
  brand: z.string(),
  model: z.string(),
  doors: z.number().int().nullable()
});

export const MotorcycleRepresentation = z.object({
  type: z.literal('Motorcycle'),
  brand: z.string(),
  model: z.string(),
  sidecar: z.boolean()
});

export const VehicleRepresentation = z.discriminatedUnion('type', [
  CarRepresentation,
  MotorcycleRepresentation
]);
```

## See Also

- [Single Table Inheritance example](/examples/single-table-inheritance-sti.md) — complete working example
- [Representation::Base reference](/reference/representation-base.md) — `discriminated!` and `variant` methods
