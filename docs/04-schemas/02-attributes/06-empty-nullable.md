# Empty & Nullable

Two options for handling null and empty values: `nullable` and `empty`.

## Quick Comparison

| Option | Accepts `null` | Accepts `""` | Stores | Returns |
|--------|----------------|--------------|--------|---------|
| Default | No | Yes | As-is | As-is |
| `nullable: true` | Yes | Yes | As-is | As-is |
| `empty: true` | No | Yes | `nil` | `""` |

## nullable: true

Allow null values in requests and responses:

```ruby
attribute :bio, nullable: true, writable: true
```

```json
// Request - both valid:
{ "user": { "bio": "Hello" } }
{ "user": { "bio": null } }

// Response - returns as stored:
{ "user": { "bio": null } }
```

### Auto-Detection

`nullable` is auto-detected from database columns:

```ruby
# If bio column allows NULL:
attribute :bio  # nullable: true is inferred
```

Override explicitly:

```ruby
attribute :bio, nullable: false  # Reject null even if DB allows it
```

## empty: true

Convert between `nil` (database) and `""` (API):

```ruby
attribute :name, empty: true, writable: true
```

```json
// Request with empty string:
{ "user": { "name": "" } }
// Stored as: nil

// Database has nil:
// Response returns:
{ "user": { "name": "" } }
```

### Why Use empty?

**Problem**: Your database stores `NULL` for missing values, but your frontend expects empty strings.

**Solution**: `empty: true` bridges the gap:

```ruby
class UserSchema < Apiwork::Schema::Base
  # Frontend always works with strings, never null
  attribute :nickname, empty: true, writable: true
  attribute :bio, empty: true, writable: true
end
```

Frontend code becomes simpler:

```typescript
// Without empty: true
const name = user.nickname ?? '';  // Must handle null

// With empty: true
const name = user.nickname;  // Always a string
```

### How It Works

`empty: true` automatically adds transformers:

```ruby
# These are equivalent:
attribute :name, empty: true

attribute :name,
  encode: :nil_to_empty,   # nil → "" on response
  decode: :blank_to_nil    # "" → nil on request
```

### empty vs nullable

| | `nullable: true` | `empty: true` |
|---|---|---|
| **Use when** | Null has meaning | Null = no value |
| **Frontend sees** | `null` or value | `""` or value |
| **Database stores** | `null` or value | `null` or value |
| **TypeScript type** | `string \| null` | `string` |

### Validation with empty

`empty: true` still respects `min`/`max` constraints:

```ruby
attribute :name, empty: true, min: 2, max: 50, writable: true
```

```json
// Valid:
{ "user": { "name": "" } }      // Empty allowed, stored as nil
{ "user": { "name": "Jo" } }    // Min 2 satisfied

// Invalid:
{ "user": { "name": "J" } }     // Too short (min: 2)
{ "user": { "name": null } }    // null rejected (empty ≠ nullable)
```

## Generated Types

### nullable: true

```typescript
// TypeScript
interface User {
  bio?: string | null;
}

// Zod
const UserSchema = z.object({
  bio: z.string().nullable().optional()
});
```

### empty: true

```typescript
// TypeScript
interface User {
  name?: string;  // Never null
}

// Zod
const UserSchema = z.object({
  name: z.string().optional()
});
```

## Combining Options

You cannot combine `empty` and `nullable` - they're mutually exclusive:

```ruby
# empty: true forces nullable: false internally
attribute :name, empty: true, nullable: true  # nullable ignored
```

If you need both null and empty string as valid inputs, use `nullable: true` and handle conversion in your application logic.
