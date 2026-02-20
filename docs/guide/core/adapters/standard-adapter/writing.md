---
order: 3
---

# Writing

How the standard adapter handles create, update, and delete operations.

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

Which attributes are writable depends on your representation. See [Attributes: Writable](../../representations/attributes/writable.md) and [Associations: Writable](../../representations/associations/writable.md).

::: tip Client-Generated IDs
To accept client-generated UUIDs on create, add `attribute :id, writable: true, optional: true` to your representation. The `id` field then appears as an optional parameter in the create payload.
:::

For HTTP methods, status codes, and contract shapes per action, see [Action Defaults](./action-defaults.md).

## Nested Associations

When associations are marked `writable: true`, the adapter accepts nested data for create, update, and delete operations.

For association configuration, see [Associations](../../representations/associations/introduction.md).

### Create

New records have no `id`:

```json
{
  "invoice": {
    "number": "INV-001",
    "items": [
      { "description": "Consulting" },
      { "description": "Development" }
    ]
  }
}
```

### Update

Existing records include `id`:

```json
{
  "invoice": {
    "items": [
      { "id": "5", "description": "Updated item" }
    ]
  }
}
```

### Delete

Include `id` and `OP: "delete"`:

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
      { "id": "5", "description": "Updated" },
      { "description": "New item" },
      { "OP": "delete", "id": "3" }
    ]
  }
}
```

### Deep Nesting

Nest arbitrarily deep:

```json
{
  "invoice": {
    "items": [
      {
        "description": "Consulting",
        "adjustments": [
          { "amount": "10.00" }
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
  OP?: 'create';
  description: string;
}

interface ItemNestedUpdatePayload {
  OP?: 'update';
  id?: string;
  description?: string;
}

interface ItemNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

type ItemNestedPayload =
  | ItemNestedCreatePayload
  | ItemNestedUpdatePayload
  | ItemNestedDeletePayload;
```

`OP` is optional on all variants. When omitted, the adapter infers the operation: records without `id` are created, records with `id` are updated.

## Validation Errors

Nested writes produce validation errors with full paths including array indexes. See [Validation: Nested Records](./validation.md#nested-records).

#### See also

- [Associations: Writable](../../representations/associations/writable.md) — configuring writable associations
- [Attributes: Writable](../../representations/attributes/writable.md) — configuring writable attributes
- [Action Defaults](./action-defaults.md) — HTTP methods and status codes per action
- [Validation](./validation.md) — error format for nested records
