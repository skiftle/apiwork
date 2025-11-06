# Types

Every attribute has a type. It controls validation, serialization, and filter operators.

## Type inference

Apiwork infers types from your database columns:

```ruby
# db/migrate/xxx_create_posts.rb
create_table :posts do |t|
  t.string :title                # → type: :string
  t.text :body                   # → type: :string
  t.integer :view_count          # → type: :integer
  t.bigint :large_number         # → type: :integer
  t.float :rating                # → type: :float
  t.decimal :price               # → type: :float
  t.boolean :published           # → type: :boolean
  t.date :publish_date           # → type: :date
  t.datetime :published_at       # → type: :datetime
  t.timestamp :processed_at      # → type: :datetime
  t.json :metadata               # → type: :object
  t.jsonb :settings              # → type: :object
end
```

You usually don't need to specify types explicitly.

## Available types

### :string

Text data.

```ruby
attribute :title, type: :string
```

**Serialization:**
```json
{ "title": "Hello World" }
```

**Validation (when writable):**
- Must be a string
- Optional: `min_length`, `max_length`
- Optional: `pattern` (regex)

**Filter operators:**
- `equal`, `not_equal`
- `contains`, `not_contains`
- `starts_with`, `ends_with`
- `in`, `not_in`

**Examples:**
```ruby
# With validation
attribute :title,
  writable: true,
  min_length: 3,
  max_length: 100

# With pattern
attribute :slug,
  writable: true,
  pattern: /^[a-z0-9-]+$/
```

### :integer

Whole numbers.

```ruby
attribute :view_count, type: :integer
```

**Serialization:**
```json
{ "viewCount": 42 }
```

**Validation (when writable):**
- Must be an integer
- Optional: `minimum`, `maximum`

**Filter operators:**
- `equal`, `not_equal`
- `greater_than`, `greater_than_or_equal`
- `less_than`, `less_than_or_equal`
- `between`
- `in`, `not_in`

**Examples:**
```ruby
# With validation
attribute :view_count,
  writable: true,
  minimum: 0,
  maximum: 1_000_000

# Age
attribute :age,
  writable: true,
  minimum: 0,
  maximum: 120
```

### :float

Decimal numbers.

```ruby
attribute :rating, type: :float
```

**Serialization:**
```json
{ "rating": 4.5 }
```

**Validation (when writable):**
- Must be a number (integer or float accepted)
- Optional: `minimum`, `maximum`

**Filter operators:**
- Same as `:integer`

**Examples:**
```ruby
attribute :rating,
  writable: true,
  minimum: 0.0,
  maximum: 5.0

attribute :price,
  writable: true,
  minimum: 0.0
```

### :boolean

True or false.

```ruby
attribute :published, type: :boolean
```

**Serialization:**
```json
{ "published": true }
```

**Validation (when writable):**
- Must be `true` or `false`
- Accepts: `true`, `false`, `"true"`, `"false"`, `1`, `0`

**Filter operators:**
- `equal` only

**Examples:**
```ruby
attribute :published, writable: true

attribute :featured,
  writable: true,
  default: false
```

### :date

Date without time.

```ruby
attribute :publish_date, type: :date
```

**Serialization:**
```json
{ "publishDate": "2024-01-15" }
```

ISO 8601 format: `YYYY-MM-DD`

**Validation (when writable):**
- Must be a valid date string
- Accepts: `"2024-01-15"`, `"2024-1-15"`, ISO 8601 formats

**Filter operators:**
- `equal`, `not_equal`
- `greater_than`, `greater_than_or_equal`
- `less_than`, `less_than_or_equal`
- `between`

**Examples:**
```ruby
attribute :birth_date, writable: true

attribute :publish_date,
  writable: true,
  minimum: -> { Date.today }  # Can't publish in the past
```

### :datetime

Date with time and timezone.

```ruby
attribute :published_at, type: :datetime
```

**Serialization:**
```json
{ "publishedAt": "2024-01-15T10:30:00.000Z" }
```

ISO 8601 format with timezone.

**Validation (when writable):**
- Must be a valid datetime string
- Accepts: ISO 8601 formats

**Filter operators:**
- Same as `:date`

**Examples:**
```ruby
attribute :published_at, writable: true

attribute :scheduled_for,
  writable: true,
  minimum: -> { Time.current }  # Can't schedule in the past
```

### :object

JSON objects (hashes).

```ruby
attribute :metadata, type: :object
```

**Serialization:**
```json
{
  "metadata": {
    "author": "Alice",
    "tags": ["ruby", "rails"]
  }
}
```

**Validation (when writable):**
- Must be a hash/object
- Optional: define structure with `properties`

**Filter operators:**
- None (objects aren't filterable by default)

**Examples:**
```ruby
# Simple object
attribute :metadata, writable: true

# Structured object
attribute :settings,
  writable: true,
  properties: {
    theme: { type: :string },
    notifications: { type: :boolean }
  }
```

See [Object Types](#object-types) below for details.

### :array

Arrays of values.

```ruby
attribute :tags, type: :array
```

**Serialization:**
```json
{ "tags": ["ruby", "rails", "api"] }
```

**Validation (when writable):**
- Must be an array
- Optional: `of` (item type), `min_items`, `max_items`

**Filter operators:**
- `contains` (array contains value)
- `overlaps` (array overlaps with another array)

**Examples:**
```ruby
# Array of strings
attribute :tags,
  writable: true,
  of: :string,
  min_items: 1,
  max_items: 10

# Array of integers
attribute :category_ids,
  writable: true,
  of: :integer

# Array of objects
attribute :authors,
  writable: true,
  of: :object,
  properties: {
    name: { type: :string },
    email: { type: :string }
  }
```

See [Array Types](#array-types) below for details.

## Complex types

### Object types

Define structured objects:

```ruby
attribute :settings,
  type: :object,
  writable: true,
  properties: {
    theme: {
      type: :string,
      enum: ['light', 'dark']
    },
    notifications: {
      type: :boolean,
      default: true
    },
    language: {
      type: :string,
      default: 'en'
    }
  }
```

Input validation:
```json
POST /api/v1/users
{
  "user": {
    "settings": {
      "theme": "dark",
      "notifications": false,
      "language": "sv"
    }
  }
}
```

### Array types

Define arrays with item types:

```ruby
# Array of strings
attribute :tags,
  type: :array,
  of: :string,
  min_items: 1,
  max_items: 10

# Array of integers
attribute :category_ids,
  type: :array,
  of: :integer

# Array of objects
attribute :authors,
  type: :array,
  of: :object,
  properties: {
    name: { type: :string, required: true },
    email: { type: :string }
  }
```

Input validation:
```json
{
  "post": {
    "tags": ["ruby", "rails"],
    "categoryIds": [1, 2, 3],
    "authors": [
      { "name": "Alice", "email": "alice@example.com" },
      { "name": "Bob" }
    ]
  }
}
```

## Enum types

Restrict values to a specific set:

```ruby
attribute :status,
  writable: true,
  type: :string,
  enum: ['draft', 'published', 'archived']
```

Validation ensures the value is one of the allowed values.

Works with ActiveRecord enums:

```ruby
# Model
class Post < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }
end

# Schema
attribute :status,
  filterable: true,
  writable: true,
  type: :string,
  enum: Post.statuses.keys  # ['draft', 'published', 'archived']
```

Apiwork serializes enums as strings:
```json
{ "status": "published" }
```

And accepts them as strings:
```json
{ "post": { "status": "draft" } }
```

## Type coercion

Apiwork coerces input types when possible:

**Integer:**
- `"42"` → `42`
- `42.0` → `42`
- `"invalid"` → validation error

**Float:**
- `"3.14"` → `3.14`
- `42` → `42.0`
- `"invalid"` → validation error

**Boolean:**
- `"true"`, `1`, `"1"` → `true`
- `"false"`, `0`, `"0"` → `false`
- Anything else → validation error

**Date:**
- `"2024-01-15"` → `Date.parse("2024-01-15")`
- `"invalid"` → validation error

**DateTime:**
- `"2024-01-15T10:30:00Z"` → `Time.parse(...)`
- `"invalid"` → validation error

**String:**
- Most types can coerce to string
- `42` → `"42"`
- `true` → `"true"`

## Nullable types

By default, nullable is inferred from your database:

```ruby
# Migration
t.string :title, null: false  # Not nullable
t.string :subtitle            # Nullable (null: true is default)
```

Schema:
```ruby
attribute :title      # nullable: false
attribute :subtitle   # nullable: true
```

Override if needed:
```ruby
attribute :subtitle, nullable: false  # Reject null even if DB allows it
```

When nullable is true, `null` is accepted:
```json
{ "post": { "subtitle": null } }
```

When false, `null` causes a validation error.

## Custom types

Define custom types for reuse:

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.custom_types[:email] = {
    type: :string,
    format: :email,
    pattern: /\A[^@\s]+@[^@\s]+\z/
  }

  config.custom_types[:url] = {
    type: :string,
    format: :uri,
    pattern: %r{\Ahttps?://}
  }
end
```

Use them:
```ruby
attribute :email, type: :email, writable: true
attribute :website, type: :url, writable: true
```

Or define in schemas:
```ruby
class BaseSchema < Apiwork::Schema::Base
  type :email, base: :string, pattern: /\A[^@\s]+@[^@\s]+\z/
end

class UserSchema < BaseSchema
  attribute :email, type: :email, writable: true
end
```

## Type and filters

The attribute type determines which filter operators are available:

| Type | Filter Operators |
|------|-----------------|
| `:string` | equal, not_equal, contains, starts_with, ends_with, in, not_in |
| `:integer` | equal, not_equal, greater_than, less_than, between, in, not_in |
| `:float` | Same as integer |
| `:boolean` | equal |
| `:date` | equal, not_equal, greater_than, less_than, between |
| `:datetime` | Same as date |
| `:object` | None (not filterable) |
| `:array` | contains, overlaps |

See [Querying: Filtering](../querying/filtering.md) for filter details.

## Database column mapping

How database types map to schema types:

```ruby
# PostgreSQL / MySQL / SQLite
t.string         → :string
t.text           → :string
t.integer        → :integer
t.bigint         → :integer
t.float          → :float
t.decimal        → :float  # Becomes float in JSON
t.boolean        → :boolean
t.date           → :date
t.datetime       → :datetime
t.timestamp      → :datetime
t.time           → :string  # "HH:MM:SS"
t.binary         → :string  # Base64 encoded
t.json           → :object  # PostgreSQL
t.jsonb          → :object  # PostgreSQL
t.array          → :array   # PostgreSQL array type
```

Override when needed:
```ruby
# Database: text (unlimited)
# API: enforce max length
attribute :body, type: :string, max_length: 10_000
```

## Next steps

- **[Associations](./associations.md)** - belongs_to, has_many, has_one
- **[Virtual Attributes](./virtual-attributes.md)** - Computed fields
- **[Querying: Filtering](../querying/filtering.md)** - All filter operators
