---
order: 3
---

# Include Modes

Include modes control when associations are loaded in responses.

| Mode | Behavior |
|------|----------|
| `include: :optional` | Only included if requested (default) |
| `include: :always` | Always included in responses |

## Optional Include (Default)

```ruby
has_many :items, include: :optional
```

Clients request inclusion through the adapter's query interface. Without the request, `items` is omitted from the response.

::: tip
The [Standard Adapter](../../adapters/standard-adapter/includes.md) uses query parameters like `?include[items]=true` with support for nested includes.
:::

## Always Include

```ruby
belongs_to :customer, include: :always
```

The association is included in every response automatically.

## Type Guarantees

The `include` option directly affects generated types:

**Optional:**

```typescript
interface Invoice {
  number: string;
  items?: Item[];  // May not be present
}
```

**Always:**

```typescript
interface Invoice {
  number: string;
  customer: Customer;  // Always present (no ?)
}
```

## nullable vs optional

`nullable` and `include` are independent:

- **optional** (`?`) — field may not exist in response
- **nullable** (`| null`) — field exists but value can be null

```ruby
# Always present, never null
belongs_to :customer, include: :always
# TypeScript: customer: Customer

# Always present, can be null
belongs_to :reviewer, include: :always, nullable: true
# TypeScript: reviewer: Customer | null

# May not be present, if present then not null
has_many :items, include: :optional
# TypeScript: items?: Item[]
```
