---
order: 64
prev: false
next: false
---

# Schema::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L40)

Base class for resource schemas.

Schemas define attributes and associations for serialization.
Types and nullability are auto-detected from the model's database columns.

**Example: Basic schema**

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :title
  attribute :amount, type: :decimal
  attribute :status, filterable: true, sortable: true

  belongs_to :customer
  has_many :line_items
end
```

## Class Methods

### .abstract!

`.abstract!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L40)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L40)

Returns whether this schema is abstract.

**Returns**

`Boolean` — true if abstract

---

### .adapter

`.adapter(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L148)

Configures adapter options for this schema.

Use this to override API-level adapter settings for a specific
resource. Available options depend on the adapter being used.

**See also**

- [Adapter::Base](adapter-base)

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

### .adapter_config

`.adapter_config`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L171)

The merged adapter configuration for this schema.

Configuration values are resolved in order:
1. Schema-level (defined in the schema class via `adapter do`)
2. API-level (defined in the API definition via `adapter do`)
3. Adapter defaults (defined in the adapter class)

**Returns**

[Configuration](configuration)

**See also**

- [API::Base#adapter_config](api-base#adapter-config)
- [Adapter::Base](adapter-base)

**Example**

```ruby
schema_class.adapter_config.pagination.default_size
schema_class.adapter_config.pagination.strategy
```

---

### .associations

`.associations`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L51)

**Returns**

Hash{Symbol =&gt; [Association](schema-association)} — defined associations

---

### .attribute

`.attribute(name, decode: nil, deprecated: false, description: nil, empty: nil, encode: nil, enum: nil, example: nil, filterable: nil, format: nil, max: nil, min: nil, nullable: nil, optional: nil, sortable: nil, type: nil, writable: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L210)

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

### .attributes

`.attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L46)

**Returns**

Hash{Symbol =&gt; [Attribute](schema-attribute)} — defined attributes

---

### .belongs_to

`.belongs_to(name, class_name: nil, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, schema: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L392)

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

### .deprecated!

`.deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L519)

Marks this schema as deprecated.

Deprecated schemas are included in generated documentation
with a deprecation notice.

**Example**

```ruby
class LegacyOrderSchema < Apiwork::Schema::Base
  deprecated!
end
```

---

### .description

`.description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L503)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L583)

Deserializes a hash or an array of hashes using this schema's decode transformers.

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

### .discriminated!

`.discriminated!(as: nil, by: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L447)

Declares this schema as discriminated (polymorphic).

Call on the base schema to enable discriminated responses. Variant
schemas must call `variant` to register themselves.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `as` | `Symbol` | discriminator field name in API responses (defaults to inheritance_column, usually :type) |
| `by` | `Symbol` | Rails column (default: inheritance_column) |

**Returns**

`self`

**Example: Base schema with discriminated variants**

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminated!
end

class PersonClientSchema < ClientSchema
  variant as: :person
end
```

---

### .example

`.example(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L535)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L340)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L286)

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

The model class.

By default, the model is auto-detected from the schema name
(e.g., InvoiceSchema becomes Invoice). Use this to override.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Class` | the ActiveRecord model class (optional) |

**Returns**

`Class`, `nil`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L126)

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

### .root_key

`.root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L604)

The root key for JSON responses.

Uses the custom root if defined via [#root](#root), otherwise derives
from the schema type or model name.

**Returns**

[RootKey](schema-root-key)

**See also**

- [RootKey](schema-root-key)

**Example**

```ruby
InvoiceSchema.root_key.singular  # => "invoice"
InvoiceSchema.root_key.plural    # => "invoices"
```

---

### .serialize

`.serialize(record_or_collection, context: {}, include: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L560)

Serializes a record or a collection of records using this schema.

Converts records to JSON-ready hashes based on
attribute and association definitions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record_or_collection` | `ActiveRecord::Base, Array<ActiveRecord::Base>` | record(s) to serialize |
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

### .tag

`.tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L63)

**Returns**

`Symbol`, `nil` — the variant's tag, or nil if not a variant

---

### .union

`.union`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L57)

**Returns**

[Schema::Union](schema-union), `nil` — the union configuration

---

### .variant

`.variant(as: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L474)

Registers this schema as a variant of its parent.

The parent schema must have called `discriminated!` first.
Responses will use the variant's attributes based on the
record's actual type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `as` | `Symbol` | discriminator tag in API responses (defaults to model's sti_name) |

**Returns**

`self`

**Example**

```ruby
class PersonClientSchema < ClientSchema
  variant as: :person
end
```

---

## Instance Methods

### #context

`#context`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L72)

**Returns**

`Hash` — custom context passed during serialization

---

### #record

`#record`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L76)

**Returns**

`ActiveRecord::Base` — the record being serialized

---
