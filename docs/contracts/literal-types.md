# Literal Types

Sometimes you need a parameter that must be exactly one specific value. Not just a string, but *this specific string*. Not just a number, but *this exact number*.

That's what literal types are for.

## Why literal types?

Say you're building an API endpoint that archives posts. The status after archiving should always be `"archived"` - nothing else. Or maybe you're implementing a discriminated union where one field determines the shape of the rest, and that field needs to be an exact value.

Without literal types, you might reach for an enum with one value:

```ruby
param :status, type: :string, enum: ['archived']
```

That works, but it's awkward. The intent isn't clear. A literal type says exactly what you mean:

```ruby
param :status, type: :literal, value: 'archived'
```

## Basic usage

The syntax is simple - specify `type: :literal` and provide a `value`:

```ruby
action :archive do
  output do
    param :status, type: :literal, value: 'archived'
    param :archived_at, type: :string
  end
end
```

This validates that `status` must be exactly `"archived"`. Any other value will fail validation.

## What can be a literal?

Literal types work with any JSON-serializable value:

```ruby
# String literals
param :kind, type: :literal, value: 'user'

# Number literals
param :version, type: :literal, value: 1

# Boolean literals
param :ok, type: :literal, value: true

# Even null/nil
param :deleted_at, type: :literal, value: nil
```

## Required and optional literals

Like any parameter, literals can be optional:

```ruby
param :debug_mode, type: :literal, value: true, required: false
```

If the parameter is present, it must be `true`. If it's absent, validation passes.

## Real-world example: API response status

One common pattern is using literal booleans to indicate success or failure:

```ruby
action :create do
  output do
    # This discriminates between success and error variants
    param :ok, type: :boolean, required: true

    # When ok is true, these are present:
    param :post, type: :post_schema, required: false

    # When ok is false, these are present:
    param :errors, type: :array, of: :error, required: false
  end
end
```

Actually, Apiwork does this automatically for you! When you define a schema-based resource action, the output is a discriminated union with `ok: true` (literal) for success and `ok: false` (literal) for errors.

See [Discriminated Unions](discriminated-unions.md) for the full story.

## Literal types in discriminated unions

This is where literal types really shine. They're the foundation of discriminated unions:

```ruby
param :result, type: :union, discriminator: :status do
  variant tag: 'success' do
    param :status, type: :literal, value: 'success'
    param :data, type: :object do
      param :id, type: :integer
      param :name, type: :string
    end
  end

  variant tag: 'error' do
    param :status, type: :literal, value: 'error'
    param :error, type: :string
  end
end
```

The discriminator field (`status`) must be a literal in each variant. This is what makes discriminated unions type-safe - the exact value of one field determines the entire shape.

## When to use literal types

**Use literal types when:**
- A field must be a specific constant value
- You're building discriminated unions
- You want to enforce exact values in responses
- You need compile-time guarantees about specific values

**Don't use literal types when:**
- You have multiple allowed values (use `enum` instead)
- The value can vary (use regular types like `:string`, `:integer`)
- You just want a default value (use `default:` option)

## Literal types vs defaults

A common confusion: what's the difference between a literal and a default?

```ruby
# Literal: value MUST be 'pending', always
param :status, type: :literal, value: 'pending'

# Default: value CAN be anything (valid string), defaults to 'pending' if not provided
param :status, type: :string, default: 'pending'
```

Literals are about validation - enforcing that a value is exactly what you expect. Defaults are about convenience - providing a value when none is given.

## Schema generation: The real superpower

Here's why literal types matter: they don't just validate at runtime - they generate precise schemas for your frontend.

### From contract to schemas

When you define a literal type:

```ruby
action :archive do
  output do
    param :status, type: :literal, value: 'archived'
    param :archived_at, type: :string
  end
end
```

Apiwork generates schemas that preserve that exact value.

### OpenAPI 3.1

```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["archived"]
    },
    "archived_at": {
      "type": "string"
    }
  },
  "required": ["status", "archived_at"]
}
```

### TypeScript

```typescript
type ArchiveOutput = {
  status: "archived";  // Not string, but the literal "archived"
  archived_at: string;
}
```

This is huge. Your editor now knows `status` can only be `"archived"`. Autocomplete works. Type errors are caught before you even save the file.

### Zod (runtime validation)

```typescript
import { z } from 'zod';

const ArchiveOutput = z.object({
  status: z.literal("archived"),
  archived_at: z.string()
});

// Usage
const result = ArchiveOutput.parse(response);
// result.status is typed as "archived", not string
```

### The full picture

Here's the complete flow:

1. **Backend** - Contract with literal type validates output:
```ruby
action :archive do
  output do
    param :status, type: :literal, value: 'archived'
  end
end
```

2. **API schema endpoint** - Exposes the contract as JSON:
```bash
GET /api/v1/.schema/openapi
```

3. **Code generator** - Creates TypeScript from schema:
```typescript
type ArchiveOutput = {
  status: "archived";
}
```

4. **Frontend** - Gets compile-time safety:
```typescript
const response = await api.posts.archive(id);

// TypeScript KNOWS status is "archived"
if (response.status === "archived") {
  console.log("Post archived!");
}

// This won't even compile:
if (response.status === "deleted") {  // ❌ Type error!
  // "deleted" is not assignable to "archived"
}
```

### Real example: Success/error responses

When Apiwork auto-generates CRUD actions, it uses literal types for the `ok` field:

```ruby
# What Apiwork generates internally
output do
  # Success variant: ok is literally true
  param :ok, type: :literal, value: true, required: false
  param :post, type: :post_schema, required: false

  # Error variant: ok is literally false
  param :ok, type: :literal, value: false, required: false
  param :errors, type: :array, of: :error, required: false
end
```

This becomes a discriminated union in TypeScript:

```typescript
type CreatePostResponse =
  | { ok: true; post: Post }
  | { ok: false; errors: Error[] }

// Now the compiler enforces correct handling:
const response = await api.posts.create(data);

if (response.ok) {
  // TypeScript knows: response.post exists
  console.log(response.post.id);
  // TypeScript knows: response.errors does NOT exist here
  console.log(response.errors);  // ❌ Compile error!
} else {
  // TypeScript knows: response.errors exists
  console.log(response.errors[0].message);
  // TypeScript knows: response.post does NOT exist here
  console.log(response.post);  // ❌ Compile error!
}
```

And in Zod:

```typescript
const CreatePostResponse = z.discriminatedUnion("ok", [
  z.object({
    ok: z.literal(true),
    post: PostSchema
  }),
  z.object({
    ok: z.literal(false),
    errors: z.array(ErrorSchema)
  })
]);
```

### Why this matters

Without literal types, your TypeScript would be:

```typescript
type Response = {
  ok: boolean;      // Could be true OR false, who knows?
  post?: Post;      // Maybe exists?
  errors?: Error[]; // Maybe exists?
}

// Runtime checks everywhere:
if (response.ok && response.post) {
  console.log(response.post.id);
}
```

With literal types, the compiler knows the exact relationship:

```typescript
type Response =
  | { ok: true; post: Post }
  | { ok: false; errors: Error[] }

// Compiler enforces correctness:
if (response.ok) {
  console.log(response.post.id); // ✅ Post definitely exists
}
```

**Same contract, validated at runtime in Ruby, enforced at compile-time in TypeScript.** That's the whole point.

## Next steps

- Learn about [Discriminated Unions](discriminated-unions.md) - the killer feature that literal types enable
- Understand how [Auto-generated Contracts](introduction.md#auto-generated-contracts) use literals for `ok: true`/`ok: false` responses
- Explore [Enums](enums.md) for when you have multiple allowed values
