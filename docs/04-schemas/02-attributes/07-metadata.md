# Metadata

Documentation options for API specs and client generation.

## description

Human-readable description for API documentation:

```ruby
attribute :status, description: "Current publication status of the post"
```

## example

Example value shown in generated specs:

```ruby
attribute :email, example: "user@example.com"
attribute :created_at, example: "2024-01-15T10:30:00Z"
```

## deprecated

Mark an attribute as deprecated:

```ruby
attribute :legacy_id, deprecated: true
```

Deprecated attributes still work but are marked in generated specs to signal clients should migrate.

## format

Type-specific format hints for validation and client generation.

**Format overrides type in Zod output.** When you specify a format, Zod uses format-specific validators instead of the base type.

### Allowed Formats by Type

| Type | Allowed Formats |
|------|-----------------|
| `:string` | `email`, `uuid`, `uri`, `url`, `date`, `date_time`, `ipv4`, `ipv6`, `password`, `hostname` |
| `:integer` | `int32`, `int64` |
| `:float` | `float`, `double` |
| `:decimal` | `float`, `double` |
| `:number` | `float`, `double` |

Using a format not allowed for the type raises a `ConfigurationError`.

### String Formats

```ruby
attribute :email, format: :email
attribute :website, format: :uri
attribute :uuid, format: :uuid
attribute :ip_address, format: :ipv4
```

| Format | OpenAPI | Zod |
|--------|---------|-----|
| `:email` | `format: email` | `z.email()` |
| `:uuid` | `format: uuid` | `z.uuid()` |
| `:uri` / `:url` | `format: uri` | `z.url()` |
| `:date` | `format: date` | `z.iso.date()` |
| `:date_time` | `format: date-time` | `z.iso.datetime()` |
| `:ipv4` | `format: ipv4` | `z.ipv4()` |
| `:ipv6` | `format: ipv6` | `z.ipv6()` |
| `:hostname` | `format: hostname` | `z.string()` |
| `:password` | `format: password` | `z.string()` |

### Numeric Formats

```ruby
attribute :count, type: :integer, format: :int32
attribute :big_count, type: :integer, format: :int64
attribute :price, type: :float, format: :double
```

| Format | OpenAPI | Zod |
|--------|---------|-----|
| `:int32` | `format: int32` | `z.number().int()` |
| `:int64` | `format: int64` | `z.number().int()` |
| `:float` | `format: float` | `z.number()` |
| `:double` | `format: double` | `z.number()` |

## Generated Output

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title,
    description: "The post title",
    example: "Hello World"

  attribute :email,
    format: :email,
    example: "author@example.com"

  attribute :legacy_slug,
    deprecated: true,
    description: "Use 'slug' instead"
end
```

### Introspection

```json
{
  "title": {
    "type": "string",
    "description": "The post title",
    "example": "Hello World"
  },
  "email": {
    "type": "string",
    "format": "email",
    "example": "author@example.com"
  },
  "legacy_slug": {
    "type": "string",
    "deprecated": true,
    "description": "Use 'slug' instead"
  }
}
```

### OpenAPI

```yaml
components:
  schemas:
    Post:
      type: object
      properties:
        title:
          type: string
          description: The post title
          example: Hello World
        email:
          type: string
          format: email
          example: author@example.com
        legacy_slug:
          type: string
          deprecated: true
          description: Use 'slug' instead
```

### TypeScript

```typescript
interface Post {
  /** The post title */
  title?: string;
  /** @format email */
  email?: string;
  /** @deprecated Use 'slug' instead */
  legacy_slug?: string;
}
```

### Zod

```typescript
const PostSchema = z.object({
  title: z.string().describe("The post title").optional(),
  email: z.string().email().optional(),
  legacy_slug: z.string().optional()
});
```

## Combining Options

```ruby
attribute :email,
  writable: true,
  format: :email,
  description: "User's primary email address",
  example: "user@example.com"
```

Metadata options work alongside behavioral options (`writable`, `filterable`, etc.).
