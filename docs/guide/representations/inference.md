---
order: 2
---

# Inference

Apiwork detects configuration from the database schema and ActiveRecord models. This reduces repetition and keeps the API in sync with the data.

Apiwork pulls structural details that are safe to reuse: column types, enums, associations, nullability. Application-specific behavior is not detected.

Everything detected can be overridden when needed.

## Overview

| What                      | Detected From            | Override                |
| ------------------------- | ------------------------ | ----------------------- |
| Model class               | Representation class name | `model YourModel`       |
| Attribute type            | Database column type     | `type: :string`         |
| Nullable                  | Column NULL constraint   | `nullable: true`        |
| Optional                  | NULL allowed or has default | `optional: true`     |
| Default                   | Column default or implicit null | `default: 'pending'`    |
| Enum values               | Rails enum definition    | `enum: [:a, :b]`        |
| String max length         | Column character limit   | `max: 50`               |
| Decimal bounds            | Column precision + scale | `min: 0, max: 1000`    |
| Integer bounds            | Column byte limit        | `min: 0, max: 100`     |
| Association representation        | Association name         | `representation: CommentRepresentation` |
| Association nullable      | Foreign key constraint   | `nullable: true`        |
| Foreign key column        | Rails reflection         | (automatic)             |
| Polymorphic discriminator | Rails reflection         | `discriminator: :type`  |
| STI column                | `inheritance_column`     | (automatic)             |
| STI variant tag           | `sti_name`               | `type_name 'custom'`    |
| Allow destroy             | `nested_attributes_options` | (automatic)           |
| Root key                  | `model_name.element`     | `root :item, :items`    |

## Model Detection

Representation class names map to model classes automatically:

```ruby
class UserRepresentation < Apiwork::Representation::Base
  # Auto-detects: User model
end

class Api::V1::PostRepresentation < Apiwork::Representation::Base
  # Tries: Api::V1::Post, then Post
end
```

When names do not match, the model is set explicitly:

```ruby
class AccountRepresentation < Apiwork::Representation::Base
  model Organization  # Use Organization model instead
end
```

## Attribute Inference

### Type Detection

Apiwork reads column types from the database:

| Database Type             | Detected Type |
| ------------------------- | ------------- |
| `varchar`, `text`         | `:string`     |
| `integer`, `bigint`       | `:integer`    |
| `boolean`                 | `:boolean`    |
| `datetime`, `timestamp`   | `:datetime`   |
| `date`                    | `:date`       |
| `time`                    | `:time`       |
| `decimal`, `numeric`      | `:decimal`    |
| `float`, `real`           | `:number`     |
| `uuid`                    | `:uuid`       |
| `binary`, `blob`, `bytea` | `:binary`     |
| `json`, `jsonb`           | `:unknown`    |

```ruby
# Database: name VARCHAR(255), age INTEGER, active BOOLEAN
class UserRepresentation < Apiwork::Representation::Base
  attribute :name    # type: :string (auto)
  attribute :age     # type: :integer (auto)
  attribute :active  # type: :boolean (auto)
end
```

### JSON and JSONB Columns

JSON/JSONB columns auto-detect as `:unknown`:

```ruby
# Database: settings JSONB, tags JSONB
class UserRepresentation < Apiwork::Representation::Base
  attribute :settings  # type: :unknown (auto)
  attribute :tags      # type: :unknown (auto)
end
```

**Why `:unknown` instead of `:object` or `:array`?**

A JSONB column only means "here lies JSON." It could be an object, array, string, number, or null.

Typed exports require an explicitly defined shape:

```ruby
# Object shape
attribute :settings do
  object do
    string :theme
    boolean :notifications
  end
end

# Array shape
attribute :tags do
  array do
    string
  end
end
```

See [Representation Types](./attributes/inline-types.md) for complete syntax.

### Nullable Detection

Detected from column NULL constraints:

```ruby
# Database: bio TEXT NULL, email VARCHAR(255) NOT NULL
class UserRepresentation < Apiwork::Representation::Base
  attribute :bio    # nullable: true (auto)
  attribute :email  # nullable: false (auto)
end
```

The detected value can be overridden:

```ruby
attribute :bio, nullable: false  # Reject null even if DB allows it
```

### Optional Detection

An attribute is optional when:

- Column allows NULL, or
- Column has a default value

```ruby
# Database: title VARCHAR(255) NOT NULL, body TEXT NULL, status INTEGER DEFAULT 0
class PostRepresentation < Apiwork::Representation::Base
  attribute :title   # required (NOT NULL, no default)
  attribute :body    # optional (allows NULL)
  attribute :status  # optional (has default)
end
```

### Default Detection

Defaults are inherited from the database in two ways:

- **Static column defaults** — value from `DEFAULT 'X'`, `DEFAULT 0`, `DEFAULT true`, etc.
- **Implicit `null` for nullable optional attributes** — a nullable column without an explicit non-null default has implicit `DEFAULT NULL` in SQL. Apiwork inherits this when the attribute is both nullable and optional.

```ruby
# Database:
#   status VARCHAR DEFAULT 'pending'
#   count INTEGER DEFAULT 0
#   active BOOLEAN DEFAULT true
#   email VARCHAR NULL          (no DEFAULT)
#   id INTEGER NOT NULL
class UserRepresentation < Apiwork::Representation::Base
  attribute :status  # default: 'pending' (auto)
  attribute :count   # default: 0 (auto)
  attribute :active  # default: true (auto)
  attribute :email   # default: nil (auto, nullable + optional)
  attribute :id      # no default (required)
end
```

Defaults are skipped when:

- **The column has a default function** — `CURRENT_TIMESTAMP`, `gen_random_uuid()`, sequences. These are runtime expressions, not static values the client can replicate.
- **The attribute is required** — non-nullable columns or `optional: false` overrides.

The detected default can be overridden:

```ruby
attribute :status, default: 'archived'  # Override DB default
attribute :status, default: nil         # Explicit null default (preserved)
attribute :email, optional: false       # Mark required — no default applied
```

### Enum Detection

Rails enum definitions are detected automatically:

```ruby
# Model
class Account < ApplicationRecord
  enum :status, { active: 0, inactive: 1, archived: 2 }
end

# Representation
class AccountRepresentation < Apiwork::Representation::Base
  attribute :status  # enum: [:active, :inactive, :archived] (auto)
end
```

Generated TypeScript:

```typescript
type AccountStatus = "active" | "inactive" | "archived";
```

The detected enum values can be overridden:

```ruby
attribute :status, enum: [:pending, :approved]  # Custom values
```

### Bounds Detection

Apiwork detects min/max constraints from database column definitions. Explicit values are clamped to column limits — they can be stricter, never wider. This prevents values from passing contract validation but failing at the database level with a range error.

#### String

Detected from column character limit. Columns without a limit (PostgreSQL `text`, `varchar` without length) produce no constraint.

```ruby
# Database: reference_code VARCHAR(20), notes TEXT
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :reference_code  # max: 20 (auto)
  attribute :notes           # max: nil (no limit)
end
```

#### Decimal

Detected from column precision and scale:

```ruby
# Database: unit_price DECIMAL(10, 2)
class ItemRepresentation < Apiwork::Representation::Base
  attribute :unit_price  # min: -99999999.99, max: 99999999.99 (auto)
end
```

Explicit values are clamped:

```ruby
attribute :unit_price, min: 0                   # Preserved (within bounds)
attribute :unit_price, max: 999_999_999         # max clamped to 99,999,999.99
```

#### Integer

Detected from column byte size using signed 2's complement bounds:

| Column         | Min              | Max             |
| -------------- | ---------------- | --------------- |
| `smallint` (2) | -32,768          | 32,767          |
| `integer` (4)  | -2,147,483,648   | 2,147,483,647   |
| `bigint` (8)   | -9.2 quintillion | 9.2 quintillion |

```ruby
class ItemRepresentation < Apiwork::Representation::Base
  attribute :quantity  # min: -2147483648, max: 2147483647 (auto, 4-byte integer)
end
```

Explicit values are clamped to column bounds:

```ruby
attribute :quantity, min: 0, max: 100              # Preserved (within bounds)
attribute :quantity, min: 0, max: 5_000_000_000    # max clamped to 2,147,483,647
```

## Association Inference

### Representation Detection

Association representations are resolved by name:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  has_many :comments  # representation: CommentRepresentation (auto)
  belongs_to :author  # representation: AuthorRepresentation (auto)
end
```

Non-standard names require an explicit representation:

```ruby
has_many :recent_posts, representation: PostRepresentation
```

### Nullable Detection

For `belongs_to`, nullable is detected from the foreign key column:

```ruby
# Database: author_id INTEGER NOT NULL, reviewer_id INTEGER NULL
class PostRepresentation < Apiwork::Representation::Base
  belongs_to :author    # nullable: false (FK is NOT NULL)
  belongs_to :reviewer  # nullable: true (FK allows NULL)
end
```

For `has_one`, nullable defaults to `false`. The default can be overridden if needed:

```ruby
has_one :profile, nullable: true
```

The detected value can be overridden:

```ruby
belongs_to :author, nullable: true  # Allow null even if FK is required
```

### Foreign Key Detection

For `belongs_to` associations, Apiwork detects the foreign key column from Rails reflection:

```ruby
# Model
class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: :writer_id
end

# Representation - foreign key auto-detected as :writer_id
class PostRepresentation < Apiwork::Representation::Base
  belongs_to :author  # Uses writer_id column for nullable detection
end
```

When no explicit foreign key is defined, Apiwork falls back to `#{association_name}_id`.

### Polymorphic Discriminator

For polymorphic associations, the discriminator column is detected from Rails:

```ruby
# Model
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

# Representation - discriminator auto-detected as :commentable_type
class CommentRepresentation < Apiwork::Representation::Base
  belongs_to :commentable, polymorphic: [
    PostRepresentation,
    ImageRepresentation,
  ]
end
```

## Nested Attributes Detection

When an association is writable, Apiwork validates that the model has `accepts_nested_attributes_for`:

```ruby
# Model - required for writable associations
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end

# Representation
class PostRepresentation < Apiwork::Representation::Base
  has_many :comments, writable: true
end
```

## Single Table Inheritance

Apiwork automatically detects STI from Rails models:

- Inheritance column from `inheritance_column` (default: `:type`)
- Subclass representations auto-register when they inherit from a base representation

The `type_name` method overrides the API discriminator value (default: `model.sti_name`).

See [Single Table Inheritance](./single-table-inheritance.md) for details.

## Root Key Detection

The root key for JSON responses is detected from `model_class.model_name.element`:

```ruby
class Invoice < ApplicationRecord; end

class InvoiceRepresentation < Apiwork::Representation::Base
  # Root key auto-detected:
  # - Singular: 'invoice'
  # - Plural: 'invoices'
end
```

Response shape:

```json
{ "invoice": { ... } }
{ "invoices": [{ ... }] }
```

The default can be overridden:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  root :bill, :bills  # Custom root keys
end
```

## When to Override

Auto-detection should be overridden when:

1. **Names don't match** - Representation/model/association names differ from convention
2. **Virtual attributes** - Attribute doesn't exist in database
3. **Stricter constraints** - Tighter bounds, stricter nullability, or narrower enum than database allows
5. **Custom types** - Need specific serialization behavior

```ruby
class UserRepresentation < Apiwork::Representation::Base
  model Account                           # Different model name
  attribute :full_name, type: :string     # Virtual attribute
  attribute :email, nullable: false       # Stricter than DB
  attribute :age, type: :integer          # Explicit type
end
```

## Not Detected

The following are not automatically detected and must be specified manually:

| Option        | Why Not Detected                                      |
| ------------- | ----------------------------------------------------- |
| `filterable`  | Query capability is a design decision (adapter interprets) |
| `sortable`    | Query capability is a design decision (adapter interprets) |
| `writable`    | Write permissions are security-sensitive              |
| `include`     | Eager loading strategy is a performance decision (adapter interprets) |
| `description` | Documentation requires human context                  |
| `example`     | Examples require domain knowledge                     |
| `format`      | Semantic formats (email, url) need explicit intent    |
| `deprecated`  | Deprecation is a lifecycle decision                   |

These options affect API behavior, security, or documentation in ways that need explicit choices, not automatic detection.

::: info
JSON/JSONB columns only tell Apiwork "this is JSON" — not what is inside. Unlike most attributes where the type is detected from the database, JSON columns require an explicit `object` or `array` block for typed exports. See [Representation Types](./attributes/inline-types.md).
:::

#### See also

- [Representation::Base reference](../../reference/representation/base.md) — all representation methods and options
