---
order: 17
prev: false
next: false
---

# Schema::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L25)

## Class Methods

### .abstract!

`.abstract!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L25)

Marks this schema as abstract.

Abstract schemas don't require a model and serve as base classes
for other schemas. Use this when creating application-wide base schemas.
Subclasses automatically become non-abstract.

**Returns**

`void`

**Example: Application base schema**

```ruby
class ApplicationSchema < Apiwork::Schema::Base
  abstract!
end
```

---

### .abstract?

`.abstract?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L25)

Returns whether this schema is abstract.

**Returns**

`Boolean` — true if abstract

---

### .adapter

`.adapter(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L161)

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

### .attribute

`.attribute(name, decode: nil, deprecated: false, description: nil, empty: nil, encode: nil, enum: nil, example: nil, filterable: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, optional: nil, sortable: nil, type: nil, writable: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L221)

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

### .belongs_to

`.belongs_to(name, class_name: nil, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, schema: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L399)

Defines a belongs_to association for serialization and contracts.

Nullability is auto-detected from the foreign key column.
See [#has_one](#has-one) for all available options.

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

### .deprecated

`.deprecated(value = true)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L543)

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

### .description

`.description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L525)

Sets or gets a description for this schema.

Used in generated documentation (OpenAPI, etc.) to describe
what this resource represents.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | description text (optional) |

**Returns**

`String`, `nil` — the description

**Example**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  description 'Represents a customer invoice'
end
```

---

### .deserialize

`.deserialize(hash_or_array)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L624)

Deserializes a hash using this schema's decode transformers.

Transforms incoming data by applying decode transformers defined
on each attribute. Use this for processing request payloads,
webhooks, or any external data.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash_or_array` | `Hash, Array<Hash>` | data to deserialize |

**Returns**

`Hash`, `Array<Hash>` — deserialized data

**Example: Deserialize request payload**

```ruby
InvoiceSchema.deserialize(params[:invoice])
```

**Example: Deserialize a collection**

```ruby
InvoiceSchema.deserialize(params[:invoices])
```

---

### .discriminator

`.discriminator(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L453)

Enables STI (Single Table Inheritance) polymorphism for this schema.

Call on the base schema to enable discriminated responses. Variant
schemas must call `variant` to register themselves.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | discriminator field name in API responses (defaults to Rails inheritance_column, usually :type) |

**Returns**

`self`

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

### .example

`.example(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L563)

Sets or gets an example value for this schema.

Used in generated documentation to show example responses.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Hash` | example data (optional) |

**Returns**

`Hash`, `nil` — the example

**Example**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  example { id: 1, total: 99.00, status: 'paid' }
end
```

---

### .has_many

`.has_many(name, allow_destroy: false, class_name: nil, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, schema: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L349)

Defines a has_many association for serialization and contracts.

See [#has_one](#has-one) for shared options. Additionally supports:

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

### .has_one

`.has_one(name, class_name: nil, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, schema: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L297)

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

### .model

`.model(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L100)

Sets or gets the model class for this schema.

By default, the model is auto-detected from the schema name
(e.g., InvoiceSchema → Invoice). Use this to override.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Class` | the ActiveRecord model class (optional) |

**Returns**

`Class`, `nil` — the model class

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

### .root

`.root(singular, plural = singular.to_s.pluralize)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L131)

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

### .serialize

`.serialize(object_or_collection, context: {}, include: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L601)

Serializes a record or collection using this schema.

Converts ActiveRecord objects to JSON-ready hashes based on
attribute and association definitions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `object_or_collection` | `Object, Array` | record(s) to serialize |
| `context` | `Hash` | context data available during serialization |
| `include` | `Symbol, Array, Hash` | associations to include |

**Returns**

`Hash`, `Array<Hash>` — serialized data

**Example: Serialize a single record**

```ruby
InvoiceSchema.serialize(invoice)
```

**Example: Serialize with associations**

```ruby
InvoiceSchema.serialize(invoice, include: [:customer, :line_items])
```

**Example: Serialize a collection**

```ruby
InvoiceSchema.serialize(Invoice.all)
```

---

### .variant

`.variant(as: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L477)

Registers this schema as an STI variant of its parent.

The parent schema must have called `discriminator` first.
Responses will use the variant's attributes based on the
record's actual type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `as` | `Symbol` | discriminator value in API responses (defaults to model's sti_name) |

**Returns**

`self`

**Example**

```ruby
class CarSchema < VehicleSchema
  variant as: :car
  attribute :doors
end
```

---
