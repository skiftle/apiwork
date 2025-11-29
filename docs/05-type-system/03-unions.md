# Unions

Unions allow a value to be one of several types.

## Simple Union

```ruby
union :filter_value do
  variant type: :string
  variant type: :integer
end
```

Introspection:

```json
{
  "filter_value": {
    "type": "union",
    "variants": [
      { "type": "string" },
      { "type": "integer" }
    ]
  }
}
```

```typescript
// TypeScript
type FilterValue = number | string;

// Zod
const FilterValueSchema = z.union([z.number().int(), z.string()]);
```

Usage:

```ruby
param :filter, type: :union do
  variant type: :string
  variant type: :integer
end
```

## Discriminated Union

A discriminated union uses a field to determine the variant:

```ruby
param :filter, type: :union, discriminator: :kind do
  variant tag: 'string', type: :object do
    param :value, type: :string
  end

  variant tag: 'range', type: :object do
    param :gte, type: :integer
    param :lte, type: :integer, required: false
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
      { "tag": "string", "type": "object", "shape": { "value": { "type": "string" } } },
      { "tag": "range", "type": "object", "shape": { "gte": { "type": "integer" }, "lte": { "type": "integer", "required": false } } }
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
const FilterSchema = z.discriminatedUnion('kind', [
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
variant type: :string                        # Primitive type
variant type: :my_custom_type                # Reference to custom type
variant type: :array, of: :string            # Array type
variant type: :object do ... end             # Inline object
variant tag: 'text', type: :object do ... end  # For discriminated unions
variant type: :my_type, partial: true        # Makes all fields optional
```

### partial

The `partial: true` option makes all fields in the variant optional:

```ruby
union :user_update do
  variant type: :full_user
  variant type: :full_user, partial: true, tag: 'patch'  # All fields optional
end
```

## Contract-Scoped Union

```ruby
class PostContract < Apiwork::Contract::Base
  union :content_block do
    variant type: :object do
      param :type, type: :literal, value: 'text'
      param :content, type: :string
    end

    variant type: :object do
      param :type, type: :literal, value: 'image'
      param :url, type: :string
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
type FilterValue = number | string;

type Filter = StringFilter | RangeFilter;
```

### Zod

```typescript
// Simple union
const FilterValueSchema = z.union([z.number().int(), z.string()]);

// Discriminated union
const FilterSchema = z.discriminatedUnion('kind', [
  z.object({ kind: z.literal('string'), value: z.string() }),
  z.object({ kind: z.literal('range'), gte: z.number().int(), lte: z.number().int().optional() })
]);
```
