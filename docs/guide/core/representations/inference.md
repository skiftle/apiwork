---
order: 2
---

# Inference

Apiwork infers configuration from your database schema and ActiveRecord models. This reduces repetition and keeps the API aligned with the data.

Apiwork pulls structural details that are safe to reuse: column types, enums, associations, nullability. Application-specific behavior is not inferred.

Everything inferred can be overridden when needed.

## Overview

| What                      | Detected From            | Override                |
| ------------------------- | ------------------------ | ----------------------- |
| Model class               | Schema class name        | `model YourModel`       |
| Attribute type            | Database column type     | `type: :string`         |
| Nullable                  | Column NULL constraint   | `nullable: true`        |
| Optional                  | NULL allowed or has default | `optional: true`     |
| Enum values               | Rails enum definition    | `enum: [:a, :b]`        |
| Association representation        | Association name         | `representation: CommentRepresentation` |
| Association nullable      | Foreign key constraint   | `nullable: true`        |
| Foreign key column        | Rails reflection         | (automatic)             |
| Polymorphic discriminator | Rails reflection         | `discriminator: :type`  |
| STI column                | `inheritance_column`     | `discriminated!`        |
| STI variant tag           | `sti_name`               | `variant as: :custom`   |
| Allow destroy             | `nested_attributes_options` | `allow_destroy: true` |
| Root key                  | `model_name.element`     | `root :item, :items`    |

## Model Detection

Schema class names map to model classes automatically:

```ruby
class UserRepresentation < Apiwork::Representation::Base
  # Auto-detects: User model
end

class Api::V1::PostRepresentation < Apiwork::Representation::Base
  # Tries: Api::V1::Post, then Post
end
```

Override when names don't match:

```ruby
class AccountSchema < Apiwork::Representation::Base
  model Organization  # Use Organization model instead
end
```

## Attribute Inference

### Type Detection

Apiwork reads column types from your database:

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

To get typed exports, define the shape explicitly:

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

See [Inline Type Definitions](./attributes.md#inline-type-definitions) for complete syntax.

### Nullable Detection

Detected from column NULL constraints:

```ruby
# Database: bio TEXT NULL, email VARCHAR(255) NOT NULL
class UserRepresentation < Apiwork::Representation::Base
  attribute :bio    # nullable: true (auto)
  attribute :email  # nullable: false (auto)
end
```

Override:

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

### Enum Detection

Rails enum definitions are detected automatically:

```ruby
# Model
class Account < ApplicationRecord
  enum :status, { active: 0, inactive: 1, archived: 2 }
end

# Schema
class AccountSchema < Apiwork::Representation::Base
  attribute :status  # enum: [:active, :inactive, :archived] (auto)
end
```

Generated TypeScript:

```typescript
type AccountStatus = "active" | "inactive" | "archived";
```

Override:

```ruby
attribute :status, enum: [:pending, :approved]  # Custom values
```

## Association Inference

### Schema Detection

Association representations are resolved by name:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  has_many :comments  # representation: CommentRepresentation (auto)
  belongs_to :author  # representation: AuthorRepresentation (auto)
end
```

Override for non-standard names:

```ruby
has_many :recent_posts, representation: PostRepresentation
```

### Nullable Detection

For `belongs_to` associations, nullable is detected from the foreign key column:

```ruby
# Database: author_id INTEGER NOT NULL, reviewer_id INTEGER NULL
class PostRepresentation < Apiwork::Representation::Base
  belongs_to :author    # nullable: false (FK is NOT NULL)
  belongs_to :reviewer  # nullable: true (FK allows NULL)
end
```

Override:

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

# Schema - foreign key auto-detected as :writer_id
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

# Schema - discriminator auto-detected as :commentable_type
class CommentRepresentation < Apiwork::Representation::Base
  belongs_to :commentable, polymorphic: {
    post: PostRepresentation,
    image: ImageSchema
  }
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

# Schema
class PostRepresentation < Apiwork::Representation::Base
  has_many :comments, writable: true
  # allow_destroy: true is auto-detected from model
end
```

## Single Table Inheritance

Apiwork detects STI hierarchies from Rails:

- Inheritance column from `inheritance_column` (default: `:type`)
- Variant tag from `sti_name` (e.g., `"Car"`)

See [Single Table Inheritance](./single-table-inheritance.md) for setup and customization.

## Root Key Detection

The root key for JSON responses is inferred from `model_class.model_name.element`:

```ruby
class Invoice < ApplicationRecord; end

class InvoiceRepresentation < Apiwork::Representation::Base
  # Root key auto-detected:
  # - Singular: 'invoice'
  # - Plural: 'invoices'
end
```

Response format:

```json
{ "invoice": { ... } }
{ "invoices": [{ ... }] }
```

Override when needed:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  root :bill, :bills  # Custom root keys
end
```

## When to Override

Override auto-detection when:

1. **Names don't match** - Schema/model/association names differ from convention
2. **Virtual attributes** - Attribute doesn't exist in database
3. **Stricter validation** - API should be stricter than database allows
4. **Looser validation** - API should accept values database rejects
5. **Custom types** - Need specific serialization behavior

```ruby
class UserRepresentation < Apiwork::Representation::Base
  model Account                           # Different model name
  attribute :full_name, type: :string     # Virtual attribute
  attribute :email, nullable: false       # Stricter than DB
  attribute :age, type: :integer          # Explicit type
end
```

## Not Inferred

The following are **not** automatically detected and must be specified manually:

| Option        | Why Not Inferred                                      |
| ------------- | ----------------------------------------------------- |
| `min` / `max` | Column length limits don't always match API needs     |
| `filterable`  | API query capability is a design decision             |
| `sortable`    | API query capability is a design decision             |
| `writable`    | Write permissions are security-sensitive              |
| `include`     | Eager loading strategy is a performance decision      |
| `description` | Documentation requires human context                  |
| `example`     | Examples require domain knowledge                     |
| `format`      | Semantic formats (email, url) need explicit intent    |
| `deprecated`  | Deprecation is a lifecycle decision                   |

These options affect API behavior, security, or documentation in ways that require explicit intent rather than automatic derivation from the database schema.

::: info JSON Columns Require Explicit Shapes
Unlike most attributes where Apiwork infers the type from the database, JSON/JSONB columns only tell us "this is JSON"—not what's inside. Define the shape with an `object` or `array` block to get typed exports. See [Inline Type Definitions](./attributes.md#inline-type-definitions).
:::

#### See also

- [Representation::Base reference](../../../reference/representation-base.md) — all representation methods and options
