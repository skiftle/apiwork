---
order: 94
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L5)

## Class Methods

### .adapter(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L140)

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

### .api_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L111)

---

### .api_path()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L115)

---

### .attribute(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L199)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L277)

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

### .column_for(attribute_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L479)

---

### .deprecated(value = true)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L409)

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

### .deprecated?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L413)

**Returns**

`Boolean` — 

---

### .description(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L392)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L302)

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

### .discriminator_column()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L342)

---

### .discriminator_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L346)

---

### .discriminator_sti_mapping()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L376)

---

### .example(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L428)

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

### .filterable_attributes()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L451)

---

### .has_many(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L258)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L235)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L76)

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

### .model_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L89)

---

### .needs_discriminator_transform?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L372)

**Returns**

`Boolean` — 

---

### .register_variant(tag:, schema:, sti_type:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L337)

---

### .required_attributes_for(action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L469)

---

### .required_columns()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L483)

---

### .resolve_association_schema(reflection, base_schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L50)

---

### .resolve_option(name, subkey = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L149)

---

### .root(singular, plural = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L105)

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

### .root_key()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L442)

---

### .sortable_attributes()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L455)

---

### .sti_base?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L362)

**Returns**

`Boolean` — 

---

### .sti_type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L354)

---

### .sti_variant?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L368)

**Returns**

`Boolean` — 

---

### .type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L434)

---

### .type=(value)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L43)

Sets the attribute type

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `` | the value to set the attribute type to. |

---

### .validate!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L438)

---

### .variant(as: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L325)

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

### .variant_tag()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L350)

---

### .variants()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L358)

---

### .writable_attributes_for(action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L459)

---

## Instance Methods

### #as_json()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/serialization.rb#L36)

---

### #context()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L22)

Returns the value of attribute context.

---

### #detect_association_resource(association_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L32)

---

### #include()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L22)

Returns the value of attribute include.

---

### #initialize(object, context: = {}, include: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L26)

**Returns**

`Base` — a new instance of Base

---

### #object()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L22)

Returns the value of attribute object.

---
