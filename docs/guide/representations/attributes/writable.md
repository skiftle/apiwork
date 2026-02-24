---
order: 4
---

# Writable

The `writable` option controls whether an attribute can be set during create or update requests.

::: warning
Only attributes backed by a database column can be writable. Virtual attributes (methods) cannot be written.
:::

## Basic Usage

```ruby
attribute :title, writable: true        # Writable on create AND update
attribute :title, writable: false       # Read-only (default)
```

## Context-Specific Writing

Control which actions allow writing:

```ruby
attribute :bio, writable: :create       # Only on create
attribute :verified, writable: :update  # Only on update
attribute :name, writable: true         # Both create and update
```

## Generated Payload Types

Apiwork generates separate types for create and update based on writable declarations:

```ruby
class AuthorRepresentation < Apiwork::Representation::Base
  attribute :name, writable: true
  attribute :bio, writable: :create
  attribute :verified, writable: :update
end
```

**Create payload** — includes `name` and `bio`:

```typescript
export interface AuthorCreatePayload {
  name: string;
  bio?: string;
}
```

**Update payload** — includes `name` and `verified`:

```typescript
export interface AuthorUpdatePayload {
  name?: string;
  verified?: boolean;
}
```

The actual request shape (how payloads are shaped) depends on the adapter. See the adapter documentation for details.

::: tip
The [Standard Adapter](../../adapters/standard-adapter/writing.md) wraps writable attributes under the resource key in the request body.
:::

## Examples

- [Value Transforms](/examples/value-transforms) — Transform values during serialization and handle nil/empty conversion
