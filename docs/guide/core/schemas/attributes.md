---
order: 3
---

# Attributes

Attributes define which model fields are exposed in your API. Each attribute can be configured for reading, writing, filtering, and sorting.

## Basic Declaration

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title
  attribute :body
  attribute :published
  attribute :created_at
end
```

## Auto-Detection

Apiwork automatically detects from your database and model:

| Property | Source |
|----------|--------|
| `type` | Column type (string, integer, boolean, datetime, etc.) |
| `nullable` | Column NULL constraint |
| `optional` | Column allows NULL or has default value |
| `enum` | Rails enum definition |

```ruby
# These are equivalent:
attribute :title
attribute :title, type: :string, nullable: false

# Enum auto-detection
attribute :status  # Detects Rails enum values automatically
```

[Inference](./inference.md) explains how types, nullability, and enums are detected from your database and models.

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `writable` | `bool` / `hash` | `false` | Allow in create/update requests |
| `filterable` | `bool` | `false` | Enable filtering |
| `sortable` | `bool` | `false` | Enable sorting |
| `encode` | `callable` | `nil` | Transform on response |
| `decode` | `callable` | `nil` | Transform on request |
| `empty` | `bool` | `false` | Convert nil to empty string |
| `nullable` | `bool` | auto | Allow null values |
| `optional` | `bool` | auto | Optional in requests |
| `type` | `symbol` | auto | Data type |
| `format` | `symbol` | `nil` | Format hint (email, uuid, etc.) |
| `min` / `max` | `integer` | `nil` | Value/length constraints |
| `description` | `string` | `nil` | API documentation |
| `example` | `any` | `nil` | Example value |
| `deprecated` | `bool` | `false` | Mark as deprecated |

## Batch Configuration

Use `with_options` to apply options to multiple attributes:

```ruby
class ScheduleSchema < Apiwork::Schema::Base
  with_options filterable: true, sortable: true do
    attribute :id
    attribute :status
    attribute :created_at
    attribute :updated_at

    with_options writable: true do
      attribute :name
      attribute :starts_on
      attribute :ends_on
    end
  end

  attribute :archived_at
end
```

Nested blocks inherit and merge options. In the example above:
- `id`, `status`, `created_at`, `updated_at` are filterable + sortable
- `name`, `starts_on`, `ends_on` are filterable + sortable + writable
- `archived_at` has no options

::: tip Rails Feature
`with_options` is provided by [ActiveSupport](https://api.rubyonrails.org/classes/Object.html#method-i-with_options) and works with any method that accepts keyword arguments.
:::

## Computed Attributes

Attributes don't need to map to model columns. Define a method with the same name:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :full_title, type: :string

  def full_title
    "#{object.status.upcase}: #{object.title}"
  end
end
```

The `object` method returns the current model instance.

**Important:** Computed attributes require an explicit `type`. There's no model column to infer from.

---

## Writable

The `writable` option controls whether an attribute can be set during create or update requests.

::: warning Database Column Required
Only attributes backed by a database column can be writable. Virtual attributes (methods) cannot be written.
:::

### Basic Usage

```ruby
attribute :title, writable: true        # Writable on create AND update
attribute :title, writable: false       # Read-only (default)
```

### Context-Specific Writing

Control which actions allow writing:

```ruby
attribute :bio, writable: { on: [:create] }      # Only on create
attribute :verified, writable: { on: [:update] } # Only on update
attribute :name, writable: { on: [:create, :update] }  # Same as true
```

### Generated Payload Types

Apiwork generates separate types for create and update:

```ruby
class AuthorSchema < Apiwork::Schema::Base
  attribute :name, writable: true
  attribute :bio, writable: { on: [:create] }
  attribute :verified, writable: { on: [:update] }
end
```

**Create Payload** — only includes `name` and `bio`:

```typescript
export interface AuthorCreatePayload {
  name: string;
  bio?: string;
}
```

**Update Payload** — only includes `name` and `verified`:

```typescript
export interface AuthorUpdatePayload {
  name?: string;
  verified?: boolean;
}
```

### Request Format

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

---

## Filtering

The `filterable` option enables query filtering on an attribute.

::: warning Database Column Required
Only attributes backed by a database column can be filterable. Virtual attributes (methods) cannot be filtered.
:::

### Basic Usage

```ruby
attribute :title, filterable: true
attribute :status, filterable: true
attribute :created_at, filterable: true
```

### Query Format

Filters use nested hash syntax:

```http
GET /api/v1/posts?filter[title][eq]=Hello
GET /api/v1/posts?filter[status][in][]=draft&filter[status][in][]=published
GET /api/v1/posts?filter[created_at][gte]=2024-01-01
```

### Operators by Type

**String:**

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[title][eq]=Hello` |
| `in` | In array | `filter[title][in][]=A&filter[title][in][]=B` |
| `contains` | Contains substring | `filter[title][contains]=ruby` |
| `starts_with` | Starts with | `filter[title][starts_with]=How` |
| `ends_with` | Ends with | `filter[title][ends_with]=?` |

**Integer / Float / Decimal:**

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[price][eq]=100` |
| `gt` | Greater than | `filter[price][gt]=50` |
| `gte` | Greater or equal | `filter[price][gte]=50` |
| `lt` | Less than | `filter[price][lt]=100` |
| `lte` | Less or equal | `filter[price][lte]=100` |
| `between` | Range (inclusive) | `filter[price][between][from]=10&filter[price][between][to]=50` |
| `in` | In array | `filter[price][in][]=10&filter[price][in][]=20` |

**Datetime / Date:**

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[created_at][eq]=2024-01-15` |
| `gt` | After | `filter[created_at][gt]=2024-01-01` |
| `gte` | On or after | `filter[created_at][gte]=2024-01-01` |
| `lt` | Before | `filter[created_at][lt]=2024-12-31` |
| `lte` | On or before | `filter[created_at][lte]=2024-12-31` |
| `between` | Range | `filter[created_at][between][from]=2024-01-01&filter[created_at][between][to]=2024-12-31` |

**Boolean:**

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `filter[published][eq]=true` |

**Nullable Fields:**

Nullable attributes get an additional `null` operator:

```http
GET /api/v1/posts?filter[deleted_at][null]=true   # WHERE deleted_at IS NULL
GET /api/v1/posts?filter[deleted_at][null]=false  # WHERE deleted_at IS NOT NULL
```

### Logical Operators

Combine filters with `_and`, `_or`, and `_not`:

```text
# Posts that are published AND created after 2024
GET /api/v1/posts?filter[_and][0][published][eq]=true&filter[_and][1][created_at][gt]=2024-01-01

# Posts that are draft OR archived
GET /api/v1/posts?filter[_or][0][status][eq]=draft&filter[_or][1][status][eq]=archived

# Posts that are NOT published
GET /api/v1/posts?filter[_not][published][eq]=true
```

---

## Sorting

The `sortable` option enables ordering results by an attribute.

::: warning Database Column Required
Only attributes backed by a database column can be sortable. Virtual attributes (methods) cannot be sorted.
:::

### Basic Usage

```ruby
attribute :title, sortable: true
attribute :created_at, sortable: true
```

### Query Format

```http
GET /api/v1/posts?sort[created_at]=desc
GET /api/v1/posts?sort[title]=asc
```

### Sort Direction

| Value | Description |
|-------|-------------|
| `asc` | Ascending (A-Z, 0-9, oldest first) |
| `desc` | Descending (Z-A, 9-0, newest first) |

### Multiple Sort Fields

Sort by multiple fields in order of precedence:

```http
GET /api/v1/posts?sort[published]=desc&sort[created_at]=desc
```

This sorts by `published` first, then by `created_at` within each group.

---

## Encode & Decode

Transform values during serialization (`encode`) and deserialization (`decode`). Use for simple presentation transforms — case changes, formatting, normalization.

| Option | When | Direction |
|--------|------|-----------|
| `encode` | Response (output) | Database to API |
| `decode` | Request (input) | API to Database |

::: info Serialization-only
These transformations must preserve the attribute's type. They operate at the serialization layer and are not passed to adapters — invisible to generated TypeScript, Zod, and OpenAPI specs.
:::

```ruby
# Case normalization: "Invoice" becomes "invoice"
attribute :subjectable_type, encode: ->(v) { v&.underscore }

# Consistent enum format: "pending" ↔ "PENDING"
attribute :status,
  encode: ->(v) { v&.upcase },
  decode: ->(v) { v&.downcase }
```

For null/empty string conversion, use [`empty: true`](#empty-true) instead — it affects generated types.

### Prefer ActiveRecord Normalizes

For data integrity, use Rails' built-in `normalizes` instead — it applies everywhere, not just through the API:

```ruby
class User < ApplicationRecord
  normalizes :email, with: ->(v) { v&.strip&.downcase }
end
```

---

## Empty & Nullable

Two options for handling null and empty values.

| Option           | Accepts `null` | Accepts `""` | Stores | Returns |
| ---------------- | -------------- | ------------ | ------ | ------- |
| Default          | No             | Yes          | As-is  | As-is   |
| `nullable: true` | Yes            | Yes          | As-is  | As-is   |
| `empty: true`    | No             | Yes          | `nil`  | `""`    |

### nullable: true

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

### empty: true

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

**Why Use empty?**

Your database stores `NULL` for missing values, but your frontend expects empty strings. `empty: true` bridges the gap.

---

## Metadata

Documentation options for API specs and client generation.

### description

Human-readable description for API documentation:

```ruby
attribute :status, description: "Current publication status of the post"
```

### example

Example value shown in generated specs:

```ruby
attribute :email, example: "user@example.com"
attribute :created_at, example: "2024-01-15T10:30:00Z"
```

### deprecated

Mark an attribute as deprecated:

```ruby
attribute :legacy_id, deprecated: true
```

### format

Type-specific format hints for validation and client generation:

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
| `:password` | `format: password` | `z.string()` |
| `:hostname` | `format: hostname` | `z.string()` |

---

## Examples

- [Encode/Decode/Empty](/examples/encode-decode-empty.md) — Transform values during serialization and handle nil/empty conversion
