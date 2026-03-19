---
order: 3
---

# Writing

The standard adapter handles create, update, and delete through request bodies.

## Request Body

Writable attributes are sent under the resource root key:

```json
{
  "invoice": {
    "number": "INV-001",
    "issued_on": "2024-01-15"
  }
}
```

Which attributes are writable depends on the representation. See [writable attributes](../../representations/attributes/writable.md) and [writable associations](../../representations/associations/writable.md).

::: tip
To accept client-generated UUIDs on create, add `attribute :id, writable: true, optional: true` to the representation. The `id` field then appears as an optional parameter in the create payload.
:::

For HTTP methods, status codes, and contract shapes per action, see [Action Defaults](./action-defaults.md).

## Nested Associations

When associations are marked `writable: true`, the adapter accepts nested writes for create, update, and delete operations.

For association configuration, see [Associations](../../representations/associations/).

### Create

```json
{
  "invoice": {
    "number": "INV-001",
    "items": [
      { "OP": "create", "description": "Consulting" },
      { "OP": "create", "description": "Development" }
    ]
  }
}
```

### Update

```json
{
  "invoice": {
    "items": [
      { "OP": "update", "id": "5", "description": "Updated item" }
    ]
  }
}
```

### Delete

```json
{
  "invoice": {
    "items": [
      { "OP": "delete", "id": "5" }
    ]
  }
}
```

Requires `allow_destroy: true` on `accepts_nested_attributes_for` in the model.

### Mixed Operations

Combine operations in one request:

```json
{
  "invoice": {
    "items": [
      { "OP": "update", "id": "5", "description": "Updated" },
      { "OP": "create", "description": "New item" },
      { "OP": "delete", "id": "3" }
    ]
  }
}
```

### Deep Nesting

Nesting can go to any depth:

```json
{
  "invoice": {
    "items": [
      {
        "OP": "create",
        "description": "Consulting",
        "adjustments": [
          { "OP": "create", "amount": "10.00" }
        ]
      }
    ]
  }
}
```

## Generated Types

TypeScript payloads use a discriminated union with `OP` as the discriminator:

```typescript
interface ItemNestedCreatePayload {
  OP: 'create';
  description: string;
}

interface ItemNestedUpdatePayload {
  OP: 'update';
  id?: string;
  description?: string;
}

interface ItemNestedDeletePayload {
  OP: 'delete';
  id: string;
}

type ItemNestedPayload =
  | ItemNestedCreatePayload
  | ItemNestedUpdatePayload
  | ItemNestedDeletePayload;
```

`OP` is the discriminator for the union. The adapter uses it to determine the operation for each nested record.

## Single Table Inheritance

When a representation uses [single table inheritance](../../representations/single-table-inheritance.md), the adapter generates a discriminated union for create and update payloads. The inheritance column acts as the discriminator:

```typescript
type InvoiceCreatePayload =
  | { type: 'standard'; number: string }
  | { type: 'recurring'; number: string; interval: string };
```

Each subclass representation becomes a variant. The adapter imports the subclass contracts and combines them into a union.

## Validation Errors

Nested writes produce validation errors with full paths including array indexes. See [nested write validation](./validation.md#nested-writes).

#### See also

- [Writable Associations](../../representations/associations/writable.md) — configuring writable associations
- [Writable Attributes](../../representations/attributes/writable.md) — configuring writable attributes
- [Action Defaults](./action-defaults.md) — HTTP methods and status codes per action
- [Validation](./validation.md) — error shape for nested writes
