# Writable

The `writable` option controls whether an attribute can be set during create or update requests.

## Basic Usage

```ruby
attribute :title, writable: true        # Writable on create AND update
attribute :title, writable: false       # Read-only (default)
```

## Context-Specific Writing

Control which actions allow writing:

```ruby
attribute :bio, writable: { on: [:create] }      # Only on create
attribute :verified, writable: { on: [:update] } # Only on update
attribute :name, writable: { on: [:create, :update] }  # Same as true
```

## Generated Payload Types

Apiwork generates separate types for create and update:

```ruby
class AuthorSchema < Apiwork::Schema::Base
  attribute :name, writable: true
  attribute :bio, writable: { on: [:create] }
  attribute :verified, writable: { on: [:update] }
end
```

### Create Payload

Only includes `name` and `bio`:

```typescript
// TypeScript
interface AuthorCreatePayload {
  name?: string;
  bio?: string;
}

// Zod
const AuthorCreatePayloadSchema = z.object({
  name: z.string().optional(),
  bio: z.string().optional()
});
```

### Update Payload

Only includes `name` and `verified`:

```typescript
// TypeScript
interface AuthorUpdatePayload {
  name?: string;
  verified?: boolean;
}

// Zod
const AuthorUpdatePayloadSchema = z.object({
  name: z.string().optional(),
  verified: z.boolean().optional()
});
```

## Request Format

Writable attributes are sent in the request body under the resource key:

```json
// POST /api/v1/authors
{
  "author": {
    "name": "Jane Doe",
    "bio": "Writer and developer"
  }
}

// PATCH /api/v1/authors/1
{
  "author": {
    "name": "Jane Smith",
    "verified": true
  }
}
```

## Practical Example

A user profile where email is set once, but display name can always change:

```ruby
class UserSchema < Apiwork::Schema::Base
  attribute :email, writable: { on: [:create] }
  attribute :display_name, writable: true
  attribute :created_at  # Read-only
end
```

## Validation

If a non-writable attribute is sent in a request, a validation error is raised. The contract rejects unknown fields by default.

## With Associations

See [Writable Associations](../03-associations/03-writable.md) for nested attribute handling.
