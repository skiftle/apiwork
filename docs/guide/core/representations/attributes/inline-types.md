---
order: 6
---

# Inline Types

JSON/JSONB columns auto-detect as `:unknown` because Apiwork cannot know their structure from the database schema alone. Use blocks to define the shape explicitly.

::: tip When to Define Shapes
If your JSON column has a consistent structure (settings, preferences, configuration), define it. If the structure truly varies per record, leave it as `:unknown`.
:::

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
    views: record.view_count,
    likes: record.likes.count,
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
  record.activities.last(10).map do |activity|
    {
      action: activity.name,
      timestamp: activity.created_at,
    }
  end
end
```

Primitives (`string`, `integer`, `boolean`, etc.) do not support blocks.

## Object Shape

Define an object structure:

```ruby
class CustomerRepresentation < Apiwork::Representation::Base
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
export interface Customer {
  settings: {
    language: string;
    notifications: boolean;
    theme: string;
  };
}
```

## Array of Primitives

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
export interface Customer {
  tags: string[];
}
```

## Array of Objects

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
export interface Customer {
  addresses: {
    city: string;
    primary: boolean;
    street: string;
    zip: string;
  }[];
}
```

## Nested Objects

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
export interface Customer {
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

## Union Types

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
        string :url, format: :url
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
export interface Invoice {
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
if (invoice.content.kind === 'image') {
  console.log(invoice.content.width); // TypeScript knows this exists
}
```

## Type Override

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

## Field Types

Inside `object` blocks, all [scalar and structure types](../../types/types.md) are available: `string`, `integer`, `boolean`, `datetime`, `object`, `array`, etc.

Each field accepts options: `optional`, `nullable`, `description`, `example`, `enum`, `min`, `max`.

```ruby
object do
  string :status, enum: %w[active inactive]
  integer :count, min: 0, max: 100
  string :notes, optional: true, nullable: true
end
```

## With Rails `store`

For `store` on TEXT columns:

```ruby
# Model
class Customer < ApplicationRecord
  store :settings, accessors: [:theme, :language], coder: JSON
end

# Representation
class CustomerRepresentation < Apiwork::Representation::Base
  attribute :settings, writable: true do
    object do
      string :theme
      string :language
    end
  end
end
```

## From Unknown to Typed

Here's the complete transformation:

**Step 1: Auto-detected as `:unknown`**

```ruby
# Migration
add_column :customers, :preferences, :jsonb

# Representation — no block
class CustomerRepresentation < Apiwork::Representation::Base
  attribute :preferences  # type: :unknown
end
```

Exports:
```typescript
// TypeScript
preferences: unknown;

// Zod
preferences: z.unknown()
```

**Step 2: Define the shape**

```ruby
class CustomerRepresentation < Apiwork::Representation::Base
  attribute :preferences do
    object do
      string :theme, enum: %w[light dark system]
      boolean :email_notifications
      object :display do
        integer :font_size, min: 10, max: 24
        boolean :compact_mode
      end
    end
  end
end
```

Exports:
```typescript
// TypeScript
preferences: {
  theme: 'light' | 'dark' | 'system';
  emailNotifications: boolean;
  display: {
    fontSize: number;
    compactMode: boolean;
  };
};

// Zod
preferences: z.object({
  theme: z.enum(['light', 'dark', 'system']),
  emailNotifications: z.boolean(),
  display: z.object({
    fontSize: z.number().int().min(10).max(24),
    compactMode: z.boolean(),
  }),
})
```

### Arrays

Same transformation for arrays:

**Step 1: Auto-detected as `:unknown`**

```ruby
# Migration
add_column :invoices, :tags, :jsonb  # Contains ["ruby", "rails", "api"]

# Representation — no block
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :tags  # type: :unknown
end
```

Exports:
```typescript
// TypeScript
tags: unknown;  // Not string[] — we don't know it's an array

// Zod
tags: z.unknown()
```

**Step 2: Define the array shape**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :tags do
    array do
      string
    end
  end
end
```

Exports:
```typescript
// TypeScript
tags: string[];

// Zod
tags: z.array(z.string())
```

## Common Patterns

**Object patterns:**

```ruby
# Settings/Preferences
attribute :settings do
  object do
    string :locale
    string :timezone
    boolean :dark_mode
  end
end

# Metadata with nested structure
attribute :metadata do
  object do
    string :version
    datetime :processed_at
    object :source do
      string :system
      string :id
    end
  end
end
```

**Array patterns:**

```ruby
# Simple string array (tags, labels)
attribute :tags do
  array do
    string
  end
end

# Array of objects (line items, addresses)
attribute :line_items do
  array do
    object do
      string :sku
      integer :quantity
      decimal :price
    end
  end
end

# Array of integers (IDs, counts)
attribute :category_ids do
  array do
    integer
  end
end
```

**Keep as unknown:**

```ruby
# When structure genuinely varies per record
attribute :raw_payload  # stays :unknown

# When array could contain mixed types
attribute :flexible_data  # stays :unknown
```

## Examples

- [Inline Type Definitions](/examples/inline-type-definitions.md) — Define shapes for JSON columns with full TypeScript typing

#### See also

- [Representation::Element](/reference/representation/element.md) — block context reference
