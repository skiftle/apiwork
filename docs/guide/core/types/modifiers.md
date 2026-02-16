---
order: 3
---

# Modifiers

Modifiers control how fields behave: whether they're required, can be null, have defaults, or must meet constraints.

## Required vs Optional vs Nullable

Three options control field presence:

| Option           | Field omitted | Field is `null` | Use case         |
| ---------------- | ------------- | --------------- | ---------------- |
| (default)        | Error         | Error           | Required fields  |
| `optional: true` | OK            | Error           | Optional fields  |
| `nullable: true` | Error         | OK              | Clearable fields |
| Both             | OK            | OK              | Fully optional   |

::: info
For strings, `""` is a valid value. To require content, use `presence: true` in your model or `min: 1` in your contract.
:::

```ruby
string :title                                     # required
string :notes, optional: true                     # can omit
datetime :deleted_at, nullable: true              # can be null
object :metadata, optional: true, nullable: true  # can omit or null
```

When validation fails, Apiwork returns a [contract error](../errors/contract-errors.md) with codes like `field_missing` or `value_null`.

## Shorthand

Every type has a `?` variant that sets `optional: true`:

```ruby
string? :notes                    # same as: string :notes, optional: true
integer? :count
array? :tags do
  string
end
```

All other options work the same:

```ruby
string? :bio, max: 500, nullable: true
```

## Defaults

When a field is omitted, use a default value:

```ruby
string :status, default: 'draft'
integer :count, default: 0
array :tags, default: []
```

## Constraints

### min & max

Set boundaries on values:

```ruby
# Numeric bounds
integer :age, min: 0, max: 150
decimal :price, min: 0.01

# String length
string :title, min: 1, max: 255

# Array size
array :tags, min: 1, max: 10 do
  string
end
```

See [contract errors](../errors/contract-errors.md) for validation error codes (`string_too_short`, `array_too_large`, etc.).

## Alias

When the API name differs from your internal name:

```ruby
object :lines_attributes, as: :lines
```

Clients send `lines`, your code receives `lines_attributes`.

## Generated Output

### Introspection

```json
{
  "title": { "type": "string", "min": 1, "max": 255 },
  "count": { "type": "integer", "optional": true, "min": 0 },
  "notes": { "type": "string", "optional": true, "nullable": true }
}
```

### TypeScript

```typescript
interface Example {
  title: string;
  count?: number;
  notes?: string | null;
}
```

### Zod

```typescript
const ExampleSchema = z.object({
  title: z.string().min(1).max(255),
  count: z.number().int().min(0).optional(),
  notes: z.string().nullable().optional(),
});
```

#### See also

- [Contract::Object reference](../../../reference/contract/object.md) — all field options
