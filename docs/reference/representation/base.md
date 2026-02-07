---
order: 79
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L40)

Base class for resource representations.

Representations define attributes and associations for serialization.
Types and nullability are auto-detected from the model's database columns.

**Example: Basic representation**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L40)

Marks this representation as abstract.

Abstract representations don't require a model and serve as base classes
for other representations. Use this when creating application-wide base representations.
Subclasses automatically become non-abstract.

**Returns**

`void`

**Example: Application base representation**

```ruby
class ApplicationRepresentation < Apiwork::Representation::Base
  abstract!
end
```

---

### .abstract?

`.abstract?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L40)

Returns whether this representation is abstract.

**Returns**

`Boolean`

---

### .adapter

`.adapter(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L151)

Configures adapter options for this representation.

Use this to override API-level adapter settings for a specific
resource. Available options depend on the adapter being used.

**See also**

- [Adapter::Base](/reference/adapter/base)

**Example: Custom pagination for this resource**

```ruby
class ActivityRepresentation < Apiwork::Representation::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end
```

---

### .associations

`.associations`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L55)

The associations for this representation.

**Returns**

Hash{Symbol =&gt; [Association](/reference/representation/association)}

---

### .attribute

`.attribute(name, decode: nil, deprecated: false, description: nil, empty: nil, encode: nil, enum: nil, example: nil, filterable: nil, format: nil, max: nil, min: nil, nullable: nil, optional: nil, sortable: nil, type: nil, writable: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L198)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L48)

The attributes for this representation.

**Returns**

Hash{Symbol =&gt; [Attribute](/reference/representation/attribute)}

---

### .belongs_to

`.belongs_to(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L376)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L497)

Marks this representation as deprecated.

Deprecated representations are included in generated documentation
with a deprecation notice.

**Returns**

`void`

**Example**

```ruby
class LegacyOrderRepresentation < Apiwork::Representation::Base
  deprecated!
end
```

---

### .description

`.description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L479)

The description for this representation.

Used in generated documentation (OpenAPI, etc.).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String, nil` | the description text |

**Returns**

`String`, `nil`

**Example**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  description 'Represents a customer invoice'
end
```

---

### .deserialize

`.deserialize(hash_or_array)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L561)

Deserializes using this representation's decode transformers.

Transforms incoming data by applying decode transformers defined
on each attribute. Use this for processing request payloads,
webhooks, or any external data.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash_or_array` | `Hash, Array<Hash>` | data to deserialize |

**Returns**

`Hash`, `Array<Hash>`

**Example: Deserialize request payload**

```ruby
InvoiceRepresentation.deserialize(params[:invoice])
```

**Example: Deserialize a collection**

```ruby
InvoiceRepresentation.deserialize(params[:invoices])
```

---

### .example

`.example(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L513)

The example value for this representation.

Used in generated documentation to show example responses.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Hash, nil` | the example data |

**Returns**

`Hash`, `nil`

**Example**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  example { id: 1, total: 99.00, status: 'paid' }
end
```

---

### .has_many

`.has_many(name, allow_destroy: false, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L326)

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

`.has_one(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, optional: nil, polymorphic: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L274)

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

**Example: With explicit representation**

```ruby
has_one :author, representation: UserRepresentation
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

### .inheritance

`.inheritance`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L62)

The inheritance for this representation.

**Returns**

[Representation::Inheritance](/reference/representation/inheritance), `nil`

---

### .model

`.model(value)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L103)

Sets the model class for this representation.

By default, the model is auto-detected from the representation name
(e.g., InvoiceRepresentation becomes Invoice). Use this to override.

To retrieve the model class, use [#model_class](#model-class) instead.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Class<ActiveRecord::Base>` | the ActiveRecord model class |

**Returns**

`void`

**Example: Explicit model**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  model Invoice
end
```

**Example: Namespaced model**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  model Billing::Invoice
end
```

---

### .model_class

`.model_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L599)

The ActiveRecord model class for this representation.

Auto-detected from representation name (InvoiceRepresentation becomes Invoice)
or explicitly set via [.model](#model).

**Returns**

`Class<ActiveRecord::Base>`

**See also**

- [.model](#model)

**Example**

```ruby
InvoiceRepresentation.model_class  # => Invoice
```

---

### .polymorphic_name

`.polymorphic_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L455)

The polymorphic name for this representation.

Uses type_name if set, otherwise the model's polymorphic_name.

**Returns**

`String`

**See also**

- [#type_name](#type-name)

---

### .root

`.root(singular, plural = singular.to_s.pluralize)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L129)

Sets the JSON root key for this representation.

By default, the root key is auto-detected from the model name
(e.g., Invoice becomes "invoice"/"invoices"). Use this to override.

To retrieve the root key, use [#root_key](#root-key) instead.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `singular` | `String, Symbol` | root key for single records |
| `plural` | `String, Symbol` | root key for collections (default: singular.pluralize) |

**Returns**

`void`

**See also**

- [#root_key](#root-key)

**Example: Custom root key**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  root :bill, :bills
end
```

---

### .root_key

`.root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L580)

The root key for this representation.

Defaults to model name when not set (Invoice becomes "invoice"/"invoices").

**Returns**

[RootKey](/reference/representation/root-key)

**See also**

- [.root](#root)

**Example**

```ruby
InvoiceRepresentation.root_key.singular  # => "invoice"
InvoiceRepresentation.root_key.plural    # => "invoices"
```

---

### .serialize

`.serialize(record_or_collection, context: {}, include: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L538)

Serializes a record or collection using this representation.

Converts records to JSON-ready hashes based on
attribute and association definitions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record_or_collection` | `ActiveRecord::Base, Array<ActiveRecord::Base>` | record(s) to serialize |
| `context` | `Hash` | context data available during serialization |
| `include` | `Symbol, Array, Hash` | associations to include |

**Returns**

`Hash`, `Array<Hash>`

**Example: Serialize a single record**

```ruby
InvoiceRepresentation.serialize(invoice)
```

**Example: Serialize with associations**

```ruby
InvoiceRepresentation.serialize(invoice, include: [:customer, :line_items])
```

**Example: Serialize a collection**

```ruby
InvoiceRepresentation.serialize(Invoice.all)
```

---

### .sti_name

`.sti_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L444)

The STI name for this representation.

Uses type_name if set, otherwise the model's sti_name.

**Returns**

`String`

**See also**

- [#type_name](#type-name)

---

### .subclass?

`.subclass?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L463)

Whether this representation is registered as an STI subclass.

**Returns**

`Boolean`

---

### .type_name

`.type_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L431)

The custom API type name for this representation.

When set, this value is used instead of the model's default type names
in both STI discriminators and polymorphic type columns.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String, Symbol, nil` | the custom type name |

**Returns**

`String`, `nil`

**See also**

- [#sti_name](#sti-name)
- [#polymorphic_name](#polymorphic-name)

**Example: STI subclass with custom type name**

```ruby
class PersonClientRepresentation < ClientRepresentation
  type_name :person
end
```

**Example: Polymorphic target with custom type name**

```ruby
class PostRepresentation < Apiwork::Representation::Base
  type_name :post
end
```

---

## Instance Methods

### #context

`#context`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L73)

The context for this representation.

**Returns**

`Hash`

---

### #record

`#record`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L79)

The record for this representation.

**Returns**

`ActiveRecord::Base`

---
