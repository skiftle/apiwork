---
order: 7
prev: false
next: false
---

# Schema::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L6)

## Class Methods

### .adapter(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L124)

Configures adapter options for this schema.

Use this to override API-level adapter settings for a specific
resource. Available options depend on the adapter being used.

**Example: Custom pagination for this resource**

```ruby
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end
```

---

### .attribute(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L184)

Defines an attribute for serialization and API contracts.

Types and nullability are auto-detected from the model's database
columns when available.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | attribute name (must match model attribute) |
| `options` | `Hash` | a customizable set of options |

**Example: Basic attribute**

```ruby
attribute :title
attribute :price, type: :decimal, min: 0
```

**Example: With filtering and sorting**

```ruby
attribute :status, filterable: true, sortable: true
```

**Example: Writable only on create**

```ruby
attribute :email, writable: { on: [:create] }
```

---

### .belongs_to(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L265)

Defines a belongs_to association for serialization and contracts.

Nullability is auto-detected from the foreign key column.
See {#has_one} for all available options.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | association name (must match model association) |

**Example: Basic belongs_to**

```ruby
belongs_to :customer
```

**Example: Filterable**

```ruby
belongs_to :category, filterable: true
```

---

### .deprecated(value = true)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L381)

Marks this schema as deprecated.

Deprecated schemas are included in generated documentation
with a deprecation notice.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Boolean` | whether deprecated (default: true) |

**Example**

```ruby
class LegacyOrderSchema < Apiwork::Schema::Base
  deprecated
end
```

---

### .description(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L363)

Sets or gets a description for this schema.

Used in generated documentation (OpenAPI, etc.) to describe
what this resource represents.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | description text (optional) |

**Returns**

`String, nil` — the description

**Example**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  description 'Represents a customer invoice'
end
```

---

### .discriminator(name = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L291)

Enables STI (Single Table Inheritance) polymorphism for this schema.

Call on the base schema to enable discriminated responses. Variant
schemas must call `variant` to register themselves.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | discriminator field name in API responses
(defaults to Rails inheritance_column, usually :type) |

**Returns**

`self` — 

**Example: Base schema with STI**

```ruby
class VehicleSchema < Apiwork::Schema::Base
  discriminator :vehicle_type
  attribute :name
end

class CarSchema < VehicleSchema
  variant as: :car
  attribute :doors
end
```

---

### .example(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L401)

Sets or gets an example value for this schema.

Used in generated documentation to show example responses.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Hash` | example data (optional) |

**Returns**

`Hash, nil` — the example

**Example**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  example { id: 1, total: 99.00, status: 'paid' }
end
```

---

### .has_many(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L245)

Defines a has_many association for serialization and contracts.

See {#has_one} for shared options. Additionally supports:

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | association name (must match model association) |
| `options` | `Hash` | a customizable set of options |

**Example: Basic collection**

```ruby
has_many :line_items
```

**Example: With nested attributes and destroy**

```ruby
has_many :line_items, writable: true, allow_destroy: true
```

**Example: Always include**

```ruby
has_many :tags, include: :always
```

---

### .has_one(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L221)

Defines a has_one association for serialization and contracts.

The association is auto-detected from the model. Use options to
control serialization behavior, nested attributes, and querying.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | association name (must match model association) |
| `options` | `Hash` | a customizable set of options |

**Example: Basic association**

```ruby
has_one :profile
```

**Example: With explicit schema**

```ruby
has_one :author, schema: UserSchema
```

**Example: Nested attributes**

```ruby
has_one :address, writable: true
```

**Example: Polymorphic**

```ruby
has_one :imageable, polymorphic: [:product, :user]
```

---

### .model(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L62)

Sets or gets the model class for this schema.

By default, the model is auto-detected from the schema name
(e.g., InvoiceSchema → Invoice). Use this to override.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Class` | the ActiveRecord model class (optional) |

**Returns**

`Class, nil` — the model class

**Example: Explicit model**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  model Invoice
end
```

**Example: Namespaced model**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  model Billing::Invoice
end
```

---

### .root(singular, plural = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L92)

Declares the JSON root key for this schema.

Adapters can use this to wrap responses in a root key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `singular` | `String, Symbol` | root key for single records |
| `plural` | `String, Symbol` | root key for collections (default: singular.pluralize) |

**Example: Custom root key**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  root :bill, :bills
end
```

---

### .variant(as: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L315)

Registers this schema as an STI variant of its parent.

The parent schema must have called `discriminator` first.
Responses will use the variant's attributes based on the
record's actual type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `as` | `Symbol` | discriminator value in API responses
(defaults to model's sti_name) |

**Returns**

`self` — 

**Example**

```ruby
class CarSchema < VehicleSchema
  variant as: :car
  attribute :doors
end
```

---
