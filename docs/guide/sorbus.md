---
order: 1
---

# Sorbus (TypeScript)

[Sorbus](https://sorbus.dev) is the typed TypeScript client, purpose-built for Apiwork. It reads the generated contract and gives you typed API calls — filtering, sorting, pagination, nested writes, and error handling — with zero configuration.

You describe your domain in Ruby. Apiwork generates a contract. Sorbus turns it into a typed client. The database is the source of truth, and every change flows from Rails to TypeScript automatically.

## Setup

Generate the contract:

```ruby
Apiwork::API.define '/api/v1' do
  export :sorbus do
    key_format :camel
  end
end
```

Create the client:

```typescript
import { createClient } from 'sorbus';
import { contract } from './contract';

const api = createClient(contract, '/api/v1', {
  headers: () => ({
    Authorization: `Bearer ${getToken()}`,
  }),
  serializeKey: 'snake',
  normalizeKey: 'camel',
});
```

That's it. Every endpoint in the contract is now a typed function on `api`.

## Queries

```typescript
const { invoices, meta } = await api.invoices.index({
  filter: {
    status: {
      eq: 'paid',
    },
    issuedOn: {
      gte: '2024-01-01',
    },
  },
  sort: {
    issuedOn: 'desc',
  },
  page: {
    number: 1,
    size: 20,
  },
});
```

Every filter operator, enum value, and sort field is typed. Invalid filters fail at compile time — not in production.

### Logical Operators

Combine filters with `AND`, `OR`, and `NOT`:

```typescript
const { invoices } = await api.invoices.index({
  filter: {
    OR: [
      {
        status: {
          eq: 'draft',
        },
      },
      {
        status: {
          eq: 'overdue',
        },
      },
    ],
  },
});
```

### Includes

Load associations with typed `include`:

```typescript
const { invoice } = await api.invoices.show({
  id: '123',
  include: {
    customer: true,
    items: true,
  },
});

// invoice.customer and invoice.items are typed
```

## Mutations

### Create

```typescript
const { invoice } = await api.invoices.create({
  invoice: {
    number: 'INV-001',
    issuedOn: '2024-06-01',
    items: [
      {
        description: 'Consulting',
        quantity: 10,
        rate: 150,
      },
    ],
  },
});
```

### Update with Nested Writes

Create, update, and delete related records in a single request:

```typescript
const { invoice } = await api.invoices.update({
  id: '123',
  invoice: {
    items: [
      {
        id: '5',
        description: 'Updated item',
      },
      {
        description: 'New item',
        quantity: 1,
        rate: 100,
      },
      {
        OP: 'delete',
        id: '3',
      },
    ],
  },
});
```

No `id` means create. With `id` means update. `OP: 'delete'` with `id` means delete. All in one request, all typed.

## Error Handling

Sorbus throws on non-OK responses by default. Catch specific status codes to get typed error data instead:

```typescript
const result = await api.invoices.create(
  {
    invoice: {
      number: 'INV-001',
    },
  },
  {
    catch: [422],
  },
);

if (!result.ok) {
  result.data.errors;
  // { number?: string[], issuedOn?: string[] }
  return;
}

result.data.invoice; // fully typed
```

The error shape is generated from the contract. Rails validation errors map directly to typed fields.

## The Workflow

```
1. Change your Rails code (add column, change type, add enum value)
2. Regenerate the contract
3. TypeScript tells you what broke
```

The database is the source of truth. Apiwork reads it. Sorbus types it. Nothing drifts.

#### See also

- [Sorbus documentation](https://sorbus.dev) — full client reference
- [Sorbus export](./exports/sorbus.md) — export configuration and output format
