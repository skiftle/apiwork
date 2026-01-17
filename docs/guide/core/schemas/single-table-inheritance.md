---
order: 6
---

# Single Table Inheritance

Apiwork represents Rails Single Table Inheritance (STI) hierarchies as [discriminated unions](../types/unions.md#discriminated-unions). The base class becomes a union type, each subclass becomes a variant, and a discriminator field identifies which variant a record belongs to. This enables type-safe serialization where each variant includes only its own attributes.

## Setup

### Base Schema

Mark a schema as discriminated:

```ruby
class VehicleSchema < Apiwork::Schema::Base
  discriminated!

  attribute :brand
  attribute :model
end
```

### Variant Schemas

Register subclasses with `variant`:

```ruby
class CarSchema < VehicleSchema
  variant

  attribute :doors
end

class MotorcycleSchema < VehicleSchema
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
class VehicleSchema < Apiwork::Schema::Base
  discriminated! as: :kind # key "kind" instead of "type"
end

class CarSchema < VehicleSchema
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
    - $ref: '#/components/schemas/car'
    - $ref: '#/components/schemas/motorcycle'
  discriminator:
    mapping:
      Car: '#/components/schemas/car'
      Motorcycle: '#/components/schemas/motorcycle'
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
export const CarSchema = z.object({
  type: z.literal('Car'),
  brand: z.string(),
  model: z.string(),
  doors: z.number().int().nullable()
});

export const MotorcycleSchema = z.object({
  type: z.literal('Motorcycle'),
  brand: z.string(),
  model: z.string(),
  sidecar: z.boolean()
});

export const VehicleSchema = z.discriminatedUnion('type', [
  CarSchema,
  MotorcycleSchema
]);
```

## See Also

- [Single Table Inheritance example](/examples/single-table-inheritance-sti.md) — complete working example
- [Schema::Base reference](/reference/schema-base.md) — `discriminated!` and `variant` methods
