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

Type-specific format hints for validation and documentation:

### String Formats

```ruby
attribute :email, format: :email
attribute :website, format: :uri
attribute :uuid, format: :uuid
attribute :ip_address, format: :ipv4
attribute :created_date, type: :string, format: :date
attribute :password, format: :password
```

| Format | Description |
|--------|-------------|
| `:email` | Email address |
| `:uuid` | UUID string |
| `:uri` / `:url` | URL |
| `:date` | Date (YYYY-MM-DD) |
| `:date_time` | ISO 8601 datetime |
| `:ipv4` / `:ipv6` | IP address |
| `:hostname` | Hostname |
| `:password` | Password (hidden in docs) |

### Numeric Formats

```ruby
attribute :count, type: :integer, format: :int32
attribute :big_count, type: :integer, format: :int64
attribute :price, type: :float, format: :double
```

| Format | Description |
|--------|-------------|
| `:int32` | 32-bit integer |
| `:int64` | 64-bit integer |
| `:float` | 32-bit float |
| `:double` | 64-bit float |

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
