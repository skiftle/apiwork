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

::: warning Explicit Type Required
Computed attributes require an explicit `type`. There's no model column to infer from.
:::

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
Only attributes backed by a database column can be filterable.
:::

```ruby
attribute :title, filterable: true
attribute :status, filterable: true
```

For query syntax, operators, and logical combinators, see [Filtering](../execution-engine/filtering.md).

---

## Sorting

The `sortable` option enables ordering results by an attribute.

::: warning Database Column Required
Only attributes backed by a database column can be sortable.
:::

```ruby
attribute :created_at, sortable: true
```

For query syntax and multi-field sorting, see [Sorting](../execution-engine/sorting.md).

---

## Encode & Decode

Transform values during serialization (`encode`) and deserialization (`decode`). Use for simple presentation transforms — case changes, formatting, normalization.

| Option | When | Direction |
|--------|------|-----------|
| `encode` | Response (output) | Database to API |
| `decode` | Request (input) | API to Database |

::: info Serialization-only
These transformations must preserve the attribute's type. They operate at the serialization layer and are not passed to adapters — invisible to generated TypeScript, Zod, and OpenAPI exports.
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

Your database stores `NULL` for missing values, but your frontend expects empty strings. `empty: true` handles the conversion.

---

## Metadata

Documentation options for API exports and client generation.

### description

Human-readable description for API documentation:

```ruby
attribute :status, description: "Current publication status of the post"
```

### example

Example value shown in generated exports:

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
attribute :website, format: :url
attribute :uuid, format: :uuid
attribute :ip_address, format: :ipv4
```

| Format | OpenAPI | Zod |
|--------|---------|-----|
| `:email` | `format: email` | `z.email()` |
| `:uuid` | `format: uuid` | `z.uuid()` |
| `:url` | `format: uri` | `z.url()` |
| `:date` | `format: date` | `z.iso.date()` |
| `:datetime` | `format: date-time` | `z.iso.datetime()` |
| `:ipv4` | `format: ipv4` | `z.ipv4()` |
| `:ipv6` | `format: ipv6` | `z.ipv6()` |
| `:password` | `format: password` | `z.string()` |
| `:hostname` | `format: hostname` | `z.string()` |

---

## Inline Type Definitions

Two types support structured data with blocks:

| Type | Use case | Auto-detected |
|------|----------|---------------|
| `:object` | Virtual attributes returning hashes | No |
| `:array` | Virtual attributes returning arrays | No |

Use a block to define the shape. Without a block, exports use `Record<string, unknown>` or `unknown[]`.

JSON/JSONB columns are auto-detected as `:unknown`. Use a block to define their shape:

```ruby
# JSON column — auto-detected as :unknown, block defines shape
attribute :settings do
  object do
    string :theme
    string :language
  end
end

# Virtual object attribute
attribute :stats do
  object do
    integer :views
    integer :likes
  end
end

def stats
  {
    views: object.view_count,
    likes: object.likes.count,
  }
end

# Virtual array attribute
attribute :recent_activity do
  array do
    object do
      string :action
      datetime :timestamp
    end
  end
end

def recent_activity
  object.activities.last(10).map do |activity|
    {
      action: activity.name,
      timestamp: activity.created_at,
    }
  end
end
```

Primitives (`string`, `integer`, `boolean`, etc.) do not support blocks.

### Object Shape

Define an object structure:

```ruby
class UserSchema < Apiwork::Schema::Base
  attribute :settings, writable: true do
    object do
      string :theme
      boolean :notifications
      string :language
    end
  end
end
```

Generated TypeScript:

```typescript
export interface User {
  settings: {
    language: string;
    notifications: boolean;
    theme: string;
  };
}
```

### Array of Primitives

Define arrays with a single element type:

```ruby
attribute :tags, writable: true do
  array do
    string
  end
end
```

Generated TypeScript:

```typescript
export interface User {
  tags: string[];
}
```

### Array of Objects

Combine `array` with `object` for typed arrays:

```ruby
attribute :addresses, writable: true do
  array do
    object do
      string :street
      string :city
      string :zip
      boolean :primary
    end
  end
end
```

Generated TypeScript:

```typescript
export interface User {
  addresses: {
    city: string;
    primary: boolean;
    street: string;
    zip: string;
  }[];
}
```

### Nested Objects

Objects can nest to any depth using named fields:

```ruby
attribute :preferences, writable: true do
  object do
    object :ui do
      string :theme
      boolean :sidebar_collapsed
    end
    object :notifications do
      boolean :email
      boolean :push
    end
  end
end
```

Generated TypeScript:

```typescript
export interface User {
  preferences: {
    notifications: {
      email: boolean;
      push: boolean;
    };
    ui: {
      sidebarCollapsed: boolean;
      theme: string;
    };
  };
}
```

### Union Types

Define polymorphic data with a discriminator field. Useful for content blocks, payment methods, notification channels, or any field that can hold different shapes:

```ruby
attribute :content, writable: true do
  union discriminator: :kind do
    variant tag: 'text' do
      object do
        string :body
        string :format, enum: %w[plain markdown html]
      end
    end
    variant tag: 'image' do
      object do
        string :url, format: :uri
        string :alt
        integer :width
        integer :height
      end
    end
    variant tag: 'code' do
      object do
        string :source
        string :language
        boolean :line_numbers
      end
    end
  end
end
```

Generated TypeScript:

```typescript
export interface Post {
  content:
    | {
        kind: 'code';
        language: string;
        lineNumbers: boolean;
        source: string;
      }
    | {
        kind: 'image';
        alt: string;
        height: number;
        url: string;
        width: number;
      }
    | {
        kind: 'text';
        body: string;
        format: 'html' | 'markdown' | 'plain';
      };
}
```

The discriminator field (`kind`) is automatically included in each variant, enabling type narrowing in TypeScript:

```typescript
if (post.content.kind === 'image') {
  console.log(post.content.width); // TypeScript knows this exists
}
```

### Type Override

When using a block, the type becomes whatever you define at the top level:

| Block | Resulting type | TypeScript | Zod |
|-------|----------------|------------|-----|
| `object do ... end` | `:object` | `{ ... }` | `z.object({ ... })` |
| `array do ... end` | `:array` | `Type[]` | `z.array(...)` |
| `union do ... end` | `:union` | `A \| B \| C` | `z.discriminatedUnion(...)` |

The inferred type is overridden by whatever you define in the block.

```ruby
# Type becomes :array (regardless of column type)
attribute :tags do
  array do
    string
  end
end

# Type becomes :object (regardless of column type)
attribute :settings do
  object do
    string :theme
  end
end
```

### Field Types

Inside `object` blocks, all [scalar and structure types](../type-system/types.md) are available: `string`, `integer`, `boolean`, `datetime`, `object`, `array`, etc.

Each field accepts options: `optional`, `nullable`, `description`, `example`, `enum`, `min`, `max`.

```ruby
object do
  string :status, enum: %w[active inactive]
  integer :count, min: 0, max: 100
  string :notes, optional: true, nullable: true
end
```

### With Rails `store`

For `store` on TEXT columns:

```ruby
# Model
class User < ApplicationRecord
  store :settings, accessors: [:theme, :language], coder: JSON
end

# Schema
class UserSchema < Apiwork::Schema::Base
  attribute :settings, writable: true do
    object do
      string :theme
      string :language
    end
  end
end
```

#### See also

- [Schema::Element](/reference/schema-element.md) — block context reference

---

## Examples

- [Encode/Decode/Empty](/examples/encode-decode-empty.md) — Transform values during serialization and handle nil/empty conversion
- [Inline Type Definitions](/examples/inline-type-definitions.md) — Define shapes for JSON columns with full TypeScript typing
