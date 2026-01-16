---
order: 5
---

# Unions

Unions allow a value to be one of several types.

## Simple Union

```ruby
union :filter_value do
  variant { string }
  variant { integer }
end
```

Introspection:

```json
{
  "filter_value": {
    "type": "union",
    "variants": [
      {
        "type": "string"
      },
      {
        "type": "integer"
      }
    ]
  }
}
```

```typescript
// TypeScript
export type FilterValue = number | string;

// Zod
export const FilterValueSchema = z.union([z.number().int(), z.string()]);
```

Usage:

```ruby
union :filter do
  variant { string }
  variant { integer }
end
```

## Discriminated Union

A discriminated union uses a field to determine the variant:

```ruby
union :filter, discriminator: :kind do
  variant tag: 'string' do
    object do
      string :value
    end
  end

  variant tag: 'range' do
    object do
      integer :gte
      integer? :lte
    end
  end
end
```

Input:

```json
{ "kind": "string", "value": "hello" }
{ "kind": "range", "gte": 10, "lte": 20 }
```

The `discriminator` field identifies which variant to use.

Introspection:

```json
{
  "filter": {
    "type": "union",
    "discriminator": "kind",
    "variants": [
      {
        "tag": "string",
        "type": "object",
        "shape": {
          "value": {
            "type": "string"
          }
        }
      },
      {
        "tag": "range",
        "type": "object",
        "shape": {
          "gte": {
            "type": "integer"
          },
          "lte": {
            "type": "integer",
            "optional": true
          }
        }
      }
    ]
  }
}
```

```typescript
// TypeScript
interface StringFilter {
  kind: 'string';
  value: string;
}

interface RangeFilter {
  kind: 'range';
  gte: number;
  lte?: number;
}

type Filter = StringFilter | RangeFilter;

// Zod
export const FilterSchema = z.discriminatedUnion('kind', [
  z.object({
    kind: z.literal('string'),
    value: z.string()
  }),
  z.object({
    kind: z.literal('range'),
    gte: z.number().int(),
    lte: z.number().int().optional()
  })
]);
```

## Variant Options

```ruby
variant { string }                           # Primitive type
variant { reference :my_custom_type }        # Reference to custom type
variant { array { string } }                 # Array type
variant { object { string :name } }          # Inline object
variant tag: 'text' do                       # For discriminated unions
  object { string :content }
end
variant partial: true do                     # Makes all fields optional
  reference :my_type
end
```

### `partial`

The `partial: true` option makes all fields in the variant optional:

```ruby
union :user_update do
  variant { reference :full_user }
  variant tag: 'patch', partial: true do  # All fields optional
    reference :full_user
  end
end
```

## Contract-Scoped Union

```ruby
class PostContract < Apiwork::Contract::Base
  union :content_block do
    variant do
      object do
        literal :type, value: 'text'
        string :content
      end
    end

    variant do
      object do
        literal :type, value: 'image'
        string :url
      end
    end
  end
end
```

## Generated Output

### OpenAPI 3.1

Simple unions use `oneOf`:

```yaml
FilterValue:
  oneOf:
    - type: string
    - type: integer
```

Discriminated unions add a `discriminator` object with `propertyName` and `mapping`:

```yaml
Filter:
  oneOf:
    - $ref: '#/components/schemas/StringFilter'
    - $ref: '#/components/schemas/RangeFilter'
  discriminator:
    propertyName: kind
    mapping:
      string: '#/components/schemas/StringFilter'
      range: '#/components/schemas/RangeFilter'

StringFilter:
  type: object
  required: [kind, value]
  properties:
    kind:
      type: string
      enum: [string]
    value:
      type: string

RangeFilter:
  type: object
  required: [kind, gte]
  properties:
    kind:
      type: string
      enum: [range]
    gte:
      type: integer
    lte:
      type: integer
```

The `discriminator.mapping` tells OpenAPI clients exactly which schema to use based on the `kind` value. This enables proper validation and code generation in tools that support OpenAPI 3.1.

### TypeScript

```typescript
export type FilterValue = number | string;

export type Filter = StringFilter | RangeFilter;
```

### Zod

```typescript
// Simple union
export const FilterValueSchema = z.union([z.number().int(), z.string()]);

// Discriminated union
export const FilterSchema = z.discriminatedUnion('kind', [
  z.object({ kind: z.literal('string'), value: z.string() }),
  z.object({ kind: z.literal('range'), gte: z.number().int(), lte: z.number().int().optional() })
]);
```

#### See also

- [Contract::Base reference](../../../reference/contract-base.md) — `union` method
