# Enums

Enums restrict a parameter to a specific set of allowed values. Think of them as multiple choice questions - the value must be one of the predefined options, or validation fails.

## Why enums?

Without enums, you'd have to validate allowed values manually:

```ruby
param :status, type: :string

# In your controller:
unless ['draft', 'published', 'archived'].include?(params[:status])
  return render_error('Invalid status')
end
```

With enums, validation happens automatically:

```ruby
param :status, type: :string, enum: ['draft', 'published', 'archived']
```

Now Apiwork validates for you. Any value outside that list fails before it reaches your controller.

## Basic usage

Pass an array of allowed values to `enum:`:

```ruby
action :create do
  input do
    param :status, type: :string, enum: ['draft', 'published', 'archived']
    param :priority, type: :integer, enum: [1, 2, 3, 4, 5]
    param :visibility, type: :string, enum: ['public', 'private', 'unlisted']
  end
end
```

The type must match the enum values - strings for string enums, integers for integer enums.

## Inline enums

The simplest enums are defined inline:

```ruby
param :size, type: :string, enum: ['small', 'medium', 'large']
```

This works great for one-off enums that you won't reuse.

## Named enums (scoped)

When you need to reuse an enum across multiple parameters, define it once and reference it by name:

```ruby
action :create do
  input do
    # Define the enum
    enum :status_values, ['draft', 'published', 'archived']

    # Use it multiple times
    param :current_status, type: :string, enum: :status_values
    param :desired_status, type: :string, enum: :status_values
  end
end
```

### Global enums

Define enums at the contract level to use them across all actions:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema PostSchema

  # Global enum - available in all actions
  enum :post_status, ['draft', 'published', 'archived']

  action :create do
    input do
      param :status, type: :string, enum: :post_status
    end
  end

  action :update do
    input do
      param :status, type: :string, enum: :post_status
    end
  end
end
```

## Global enums (across all contracts)

Apiwork provides global enums available in all contracts:

```ruby
# Built-in global enum
param :sort_direction, type: :string, enum: :sort_direction
# Allows: 'asc' or 'desc'
```

You can register your own global enums:

```ruby
# In an initializer or config
Apiwork.register_descriptors do
  enum :http_method, %w[get post put patch delete]
  enum :content_type, %w[json xml csv]
end

# Now available in all contracts
class Api::V1::RequestContract < Apiwork::Contract::Base
  action :proxy do
    input do
      param :method, type: :string, enum: :http_method
      param :accept, type: :string, enum: :content_type
    end
  end
end
```

## Enums with arrays

Use enums to validate array items:

```ruby
action :update do
  input do
    enum :tag_values, ['tech', 'news', 'tutorial', 'review']

    # Each tag must be one of the enum values
    param :tags, type: :array, of: :string, enum: :tag_values
  end
end
```

This validates that every item in the `tags` array is one of the allowed values.

## Enums in custom types

You can use enums within custom type definitions:

```ruby
type :address do
  param :street, type: :string, required: true
  param :city, type: :string, required: true
  param :country, type: :string, enum: ['US', 'CA', 'MX'], required: true
end

action :create do
  input do
    param :shipping_address, type: :address
    param :billing_address, type: :address
  end
end
```

Now every address must have a valid country code.

## Real-world example: Filter operators

One powerful pattern is using enums for filter operators:

```ruby
action :index do
  input do
    enum :string_operators, %w[equals contains starts_with ends_with]
    enum :numeric_operators, %w[equals greater_than less_than between]

    param :filters, type: :object do
      param :title, type: :object, required: false do
        param :operator, type: :string, enum: :string_operators
        param :value, type: :string
      end

      param :views, type: :object, required: false do
        param :operator, type: :string, enum: :numeric_operators
        param :value, type: :integer
      end
    end
  end
end
```

Each filter type gets appropriate operators.

## Built-in filter enums

Apiwork provides built-in filter types with predefined enums:

```ruby
# String filter with enum for operators
param :title, type: :string_filter

# Equivalent to:
param :title, type: :object do
  param :equal, type: :string, required: false
  param :not_equal, type: :string, required: false
  param :contains, type: :string, required: false
  param :in, type: :array, of: :string, required: false
  # ... more operators
end
```

Available built-in filter types:

- `:string_filter` - String comparison operators
- `:integer_filter` - Integer comparison and range operators
- `:decimal_filter` - Decimal/float comparison operators
- `:boolean_filter` - Boolean equality
- `:date_filter` - Date comparison operators
- `:datetime_filter` - DateTime comparison operators
- `:uuid_filter` - UUID equality and inclusion

See [Built-in Types](built-in-types.md) for complete details.

## Enum serialization

When you serialize a contract, inline enums are output directly:

```ruby
param :status, type: :string, enum: ['draft', 'published']

# Serializes to:
{
  type: :string,
  enum: ['draft', 'published'],
  required: false
}
```

Named enum references are preserved:

```ruby
enum :status_values, ['draft', 'published']
param :status, type: :string, enum: :status_values

# Serializes to:
{
  type: :string,
  enum: :status_values,  # Reference preserved
  required: false
}
```

This lets code generators look up the enum definition and create typed constants:

```typescript
enum StatusValues {
  Draft = "draft",
  Published = "published",
}

type CreateInput = {
  status: StatusValues;
};
```

## Enums vs unions

Enums and unions solve different problems:

**Enums** restrict a single type to specific values:

```ruby
# status must be a string, and specifically one of these
param :status, type: :string, enum: ['draft', 'published', 'archived']
```

**Unions** allow different types entirely:

```ruby
# id can be a string OR an integer
param :id, type: :union do
  variant type: :string
  variant type: :integer
end
```

**Enums** are about restricting _values_. **Unions** are about allowing _types_.

You can combine them:

```ruby
param :identifier, type: :union do
  # String variant with enum
  variant type: :string, enum: ['auto', 'manual', 'imported']

  # Or integer variant
  variant type: :integer
end
```

## Enums vs literal types

When you have a single allowed value, use a [literal type](literal-types.md) instead of an enum:

```ruby
# Awkward - enum with one value
param :status, type: :string, enum: ['archived']

# Better - literal type
param :status, type: :literal, value: 'archived'
```

Literals make the intent clear: this field must be this exact value, always.

## Validation behavior

Enum validation is strict:

```ruby
param :status, type: :string, enum: ['draft', 'published']
```

Valid values:

- `"draft"` ✅
- `"published"` ✅

Invalid values:

- `"DRAFT"` ❌ (case-sensitive)
- `"Draft"` ❌ (case-sensitive)
- `"pending"` ❌ (not in enum)
- `nil` ❌ (unless `required: false` and value is absent)
- `""` ❌ (empty string not in enum)

## Default values with enums

You can combine enums with defaults:

```ruby
param :status, type: :string, enum: ['draft', 'published', 'archived'], default: 'draft'
```

The default must be one of the enum values, or you'll get a validation error.

## Optional enums

Enums can be optional:

```ruby
param :priority, type: :string, enum: ['low', 'medium', 'high'], required: false
```

If the parameter is absent, validation passes. If it's present, it must be one of the enum values.

## When to use enums

**Use enums when:**

- You have a fixed set of allowed values
- The values are known at development time
- You want client-side type safety
- You need validation without custom code

**Don't use enums when:**

- Values come from the database (use a separate lookup endpoint)
- The set of values changes frequently
- You have too many values (>20 or so)
- Values are user-generated

For dynamic values, expose a separate endpoint:

```ruby
# Instead of hardcoding categories
param :category, type: :string, enum: ['tech', 'news', '...']

# Provide a categories endpoint
GET /api/v1/categories
# Returns: [{ id: 1, name: 'tech' }, ...]
```

## Schema generation: From validation to type safety

Enums don't just validate at runtime - they generate schemas that give you autocomplete, type checking, and compile-time safety.

### From contract to schemas

Let's use a realistic example:

```ruby
action :create do
  input do
    param :status, type: :string, enum: ['draft', 'published', 'archived']
    param :priority, type: :integer, enum: [1, 2, 3, 4, 5]
  end
end
```

### OpenAPI 3.1

```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["draft", "published", "archived"]
    },
    "priority": {
      "type": "integer",
      "enum": [1, 2, 3, 4, 5]
    }
  }
}
```

### TypeScript

Code generators can create TypeScript in different ways:

**Option 1: Union of literal types**

```typescript
type CreateInput = {
  status: "draft" | "published" | "archived";
  priority: 1 | 2 | 3 | 4 | 5;
};
```

**Option 2: TypeScript enums**

```typescript
enum PostStatus {
  Draft = "draft",
  Published = "published",
  Archived = "archived",
}

enum Priority {
  Lowest = 1,
  Low = 2,
  Medium = 3,
  High = 4,
  Highest = 5,
}

type CreateInput = {
  status: PostStatus;
  priority: Priority;
};
```

Both give you autocomplete and compile-time checking:

```typescript
// With union literals
const input: CreateInput = {
  status: "draft", // ✅ Autocomplete suggests: draft, published, archived
  priority: 3, // ✅ Autocomplete suggests: 1, 2, 3, 4, 5
};

const invalid: CreateInput = {
  status: "pending", // ❌ Type error! "pending" not in enum
  priority: 10, // ❌ Type error! 10 not in enum
};

// With TypeScript enums
const input: CreateInput = {
  status: PostStatus.Draft, // ✅ Autocomplete works
  priority: Priority.Medium, // ✅ Autocomplete works
};
```

### Zod (runtime validation + types)

```typescript
import { z } from "zod";

const CreateInput = z.object({
  status: z.enum(["draft", "published", "archived"]),
  priority: z.union([
    z.literal(1),
    z.literal(2),
    z.literal(3),
    z.literal(4),
    z.literal(5),
  ]),
});

// Infer TypeScript type from Zod schema
type CreateInput = z.infer<typeof CreateInput>;
// Results in: { status: "draft" | "published" | "archived", priority: 1 | 2 | 3 | 4 | 5 }
```

### The complete flow

1. **Backend** - Define enum in contract:

```ruby
action :create do
  input do
    enum :post_status, ['draft', 'published', 'archived']
    param :status, type: :string, enum: :post_status
  end
end
```

2. **Runtime validation** - Apiwork validates input:

```ruby
# ✅ Valid
{ status: 'draft' }

# ❌ Invalid - returns 422 error
{ status: 'pending' }
```

3. **Schema endpoint** - Expose as OpenAPI:

```bash
GET /api/v1/.schema/openapi
```

4. **Code generation** - Generate TypeScript/Zod:

```bash
npx @apiwork/codegen --input /api/v1/.schema/openapi --output ./src/api
```

5. **Frontend** - Get compile-time safety:

```typescript
// Editor autocomplete
const input: CreateInput = {
  status: "...", // Suggests: draft, published, archived
};

// Compile-time errors
const invalid: CreateInput = {
  status: "wrong", // ❌ Type error before you even save
};
```

### Real-world example: Sort direction

Apiwork includes a global `:sort_direction` enum:

```ruby
# Built-in global enum
enum :sort_direction, %w[asc desc]

# Used in auto-generated sort params
param :sort, type: :object do
  param :created_at, type: :string, enum: :sort_direction
  param :title, type: :string, enum: :sort_direction
end
```

Generated TypeScript:

```typescript
enum SortDirection {
  Asc = "asc",
  Desc = "desc",
}

type IndexInput = {
  sort?: {
    created_at?: SortDirection;
    title?: SortDirection;
  };
};

// Usage with autocomplete
api.posts.index({
  sort: {
    created_at: SortDirection.Desc, // ✅ Autocomplete works
    title: SortDirection.Asc,
  },
});
```

Generated Zod:

```typescript
const SortDirection = z.enum(["asc", "desc"]);

const IndexInput = z.object({
  sort: z
    .object({
      created_at: SortDirection.optional(),
      title: SortDirection.optional(),
    })
    .optional(),
});
```

### Named enums and code generation

When you use named enums, code generators can create reusable constants:

```ruby
# Backend
enum :post_status, ['draft', 'published', 'archived']

action :create do
  input do
    param :status, type: :string, enum: :post_status
  end
end

action :update do
  input do
    param :status, type: :string, enum: :post_status
  end
end
```

Generated TypeScript creates a single enum used in multiple places:

```typescript
// Enum defined once
enum PostStatus {
  Draft = "draft",
  Published = "published",
  Archived = "archived",
}

// Used in multiple input types
type CreateInput = {
  status: PostStatus;
};

type UpdateInput = {
  status: PostStatus;
};
```

### Enums in filter inputs

Auto-generated filter inputs use enums for operators:

```ruby
# What Apiwork generates for filterable: true
param :filter, type: :object do
  param :status, type: :union do
    # Simple variant - direct value
    variant type: :string, enum: ['draft', 'published', 'archived']

    # Object variant - with operators
    variant type: :object do
      param :equal, type: :string, enum: ['draft', 'published', 'archived']
      param :in, type: :array, of: :string
    end
  end
end
```

Generated TypeScript:

```typescript
type PostStatus = "draft" | "published" | "archived";

type IndexInput = {
  filter?: {
    status?:
      | PostStatus // Simple: filter[status]=draft
      | {
          // Complex: filter[status][equal]=draft
          equal?: PostStatus;
          in?: PostStatus[];
        };
  };
};

// Usage
api.posts.index({
  filter: {
    status: "draft", // ✅ Autocomplete suggests enum values
  },
});

api.posts.index({
  filter: {
    status: {
      in: ["draft", "published"], // ✅ Autocomplete for array items
    },
  },
});
```

### Why this matters

**Without enums:**

```typescript
// Anything goes, errors at runtime
type CreateInput = {
  status: string; // Could be anything!
  priority: number; // Could be -999 or 1000000!
};

await api.posts.create({
  status: "pendng", // Typo! Only caught at runtime
  priority: 99, // Invalid! Only caught at runtime
});
```

**With enums:**

```typescript
// Restricted values, errors at compile-time
type CreateInput = {
  status: "draft" | "published" | "archived";
  priority: 1 | 2 | 3 | 4 | 5;
};

await api.posts.create({
  status: "pendng", // ❌ Compile error! (suggests: draft, published, archived)
  priority: 99, // ❌ Compile error! (suggests: 1, 2, 3, 4, 5)
});
```

**Same enum, validated at runtime in Ruby, enforced at compile-time in TypeScript.**

### Combining enums with other features

Enums work beautifully with other type safety features:

```ruby
# Enum in a discriminated union variant
param :filter, type: :union, discriminator: :type do
  variant tag: 'status' do
    param :type, type: :literal, value: 'status'
    param :value, type: :string, enum: ['draft', 'published', 'archived']
  end

  variant tag: 'priority' do
    param :type, type: :literal, value: 'priority'
    param :value, type: :integer, enum: [1, 2, 3, 4, 5]
  end
end
```

Generated TypeScript with full type narrowing:

```typescript
type Filter =
  | { type: "status"; value: "draft" | "published" | "archived" }
  | { type: "priority"; value: 1 | 2 | 3 | 4 | 5 };

function applyFilter(filter: Filter) {
  switch (filter.type) {
    case "status":
      // TypeScript knows: filter.value is a status string
      console.log(filter.value); // Autocomplete: draft, published, archived
      break;
    case "priority":
      // TypeScript knows: filter.value is a priority number
      console.log(filter.value); // Autocomplete: 1, 2, 3, 4, 5
      break;
  }
}
```

The whole system works together: enums + literal types + discriminated unions = complete type safety from backend to frontend.

## Next steps

- Learn about [Literal Types](literal-types.md) for fields with single constant values
- Explore [Discriminated Unions](discriminated-unions.md) for enums that determine structure
- See [Params](params.md) for all parameter options
- Check [Built-in Types](built-in-types.md) for filter types with predefined enums
