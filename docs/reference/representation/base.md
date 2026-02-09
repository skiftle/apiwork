---
order: 81
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L135)

Configures adapter options for this representation.

Overrides API-level adapter settings.

**Returns**

`void`

**Yields** [Configuration](/reference/configuration/)

**Example**

```ruby
adapter do
  pagination do
    strategy :cursor
    default_size 50
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

`.attribute(name, decode: nil, deprecated: false, description: nil, empty: nil, encode: nil, enum: nil, example: nil, filterable: false, format: nil, max: nil, min: nil, nullable: nil, optional: nil, sortable: false, type: nil, writable: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L193)

Defines an attribute for serialization.

Types and nullability are auto-detected from database columns.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The attribute name. |
| `type` | `Symbol<:string, :integer, :boolean, :datetime, :date, :uuid, :decimal, :number, :object, :array>`, `nil` | `nil` | The type. If nil and name maps to a database column, auto-detected from column type. |
| `enum` | `Array`, `nil` | `nil` | The allowed values. If nil, auto-detected from Rails enum definition. |
| `optional` | `Boolean`, `nil` | `nil` | Whether the attribute is optional for writes. If nil, auto-detected from column default or NULL constraint. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be null. If nil, auto-detected from column NULL constraint. |
| `filterable` | `Boolean` | `false` | Whether the attribute is filterable. |
| `sortable` | `Boolean` | `false` | Whether the attribute is sortable. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the attribute is writable. |
| `encode` | `Proc`, `nil` | `nil` | Transform for serialization. |
| `decode` | `Proc`, `nil` | `nil` | Transform for deserialization. |
| `empty` | `Boolean`, `nil` | `nil` | Whether to use empty string instead of null. Serializes nil as "" and deserializes "" as nil. |
| `min` | `Integer`, `nil` | `nil` | The minimum value or length. |
| `max` | `Integer`, `nil` | `nil` | The maximum value or length. |
| `description` | `String`, `nil` | `nil` | The description for documentation. |
| `example` | `Object`, `nil` | `nil` | An example value for documentation. |
| `format` | `Symbol<:float, :double, :int32, :int64, :email, :uuid, :url, :date, :datetime, :ipv4, :ipv6, :password, :hostname>`, `nil` | `nil` | The format hint for validation. |
| `deprecated` | `Boolean` | `false` | Whether the attribute is deprecated. |

</div>

**Returns**

`void`

**Yields** [Representation::Element](/reference/representation/element)

**Example**

```ruby
attribute :title
attribute :price, type: :decimal, min: 0
attribute :status, filterable: true, sortable: true
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

`.belongs_to(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, polymorphic: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L392)

Defines a belongs_to association for serialization.

Nullability is auto-detected from the foreign key column.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The association name. |
| `representation` | `Class<Representation::Base>`, `nil` | `nil` | The representation class. If `nil`, inferred from the associated model in the same namespace (e.g., `CustomerRepresentation` for `Customer`). |
| `polymorphic` | `Array<Class<Representation::Base>>`, `nil` | `nil` | The allowed representation classes for polymorphic associations. |
| `include` | `Symbol<:always, :optional>` | `:optional` | The inclusion strategy. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the association is writable. |
| `filterable` | `Boolean` | `false` | Whether the association is filterable. |
| `sortable` | `Boolean` | `false` | Whether the association is sortable. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be null. If nil, auto-detected from foreign key column. |
| `description` | `String`, `nil` | `nil` | The description for documentation. |
| `example` | `Object`, `nil` | `nil` | An example value for documentation. |
| `deprecated` | `Boolean` | `false` | Whether the association is deprecated. |

</div>

**Returns**

`void`

**See also**

- [#has_one](#has-one)

**Example**

```ruby
belongs_to :customer
belongs_to :commentable, polymorphic: [PostRepresentation, CustomerRepresentation]
```

---

### .deprecated!

`.deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L485)

Marks this representation as deprecated.

**Returns**

`void`

**Example**

```ruby
deprecated!
```

---

### .description

`.description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L472)

The description for this representation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` |  |

</div>

**Returns**

`String`, `nil`

**Example**

```ruby
description 'A customer invoice'
```

---

### .deserialize

`.deserialize(hash_or_array)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L530)

Deserializes using this representation's decode transformers.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`hash_or_array`** | `Hash`, `Array<Hash>` |  |  |

</div>

**Returns**

`Hash`, `Array<Hash>`

**Example**

```ruby
InvoiceRepresentation.deserialize(params[:invoice])
```

---

### .example

`.example(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L497)

The example value for this representation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Hash`, `nil` | `nil` |  |

</div>

**Returns**

`Hash`, `nil`

**Example**

```ruby
example id: 1, total: 99.00, status: 'paid'
```

---

### .has_many

`.has_many(name, allow_destroy: false, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L327)

Defines a has_many association for serialization.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The association name. |
| `allow_destroy` | `Boolean` | `false` | Whether nested records can be destroyed. Auto-detected from model nested_attributes_options. |
| `representation` | `Class<Representation::Base>`, `nil` | `nil` | The representation class. If `nil`, inferred from the associated model in the same namespace (e.g., `CustomerRepresentation` for `Customer`). |
| `include` | `Symbol<:always, :optional>` | `:optional` | The inclusion strategy. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the association is writable. |
| `filterable` | `Boolean` | `false` | Whether the association is filterable. |
| `sortable` | `Boolean` | `false` | Whether the association is sortable. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be null. |
| `description` | `String`, `nil` | `nil` | The description for documentation. |
| `example` | `Object`, `nil` | `nil` | An example value for documentation. |
| `deprecated` | `Boolean` | `false` | Whether the association is deprecated. |

</div>

**Returns**

`void`

**See also**

- [#has_one](#has-one)

**Example**

```ruby
has_many :line_items
has_many :tags, include: :always
```

---

### .has_one

`.has_one(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L266)

Defines a has_one association for serialization.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The association name. |
| `representation` | `Class<Representation::Base>`, `nil` | `nil` | The representation class. If `nil`, inferred from the associated model in the same namespace (e.g., `CustomerRepresentation` for `Customer`). |
| `include` | `Symbol<:always, :optional>` | `:optional` | The inclusion strategy. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the association is writable. |
| `filterable` | `Boolean` | `false` | Whether the association is filterable. |
| `sortable` | `Boolean` | `false` | Whether the association is sortable. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be null. |
| `description` | `String`, `nil` | `nil` | The description for documentation. |
| `example` | `Object`, `nil` | `nil` | An example value for documentation. |
| `deprecated` | `Boolean` | `false` | Whether the association is deprecated. |

</div>

**Returns**

`void`

**Example**

```ruby
has_one :profile
has_one :author, representation: UserRepresentation
```

---

### .inheritance

`.inheritance`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L62)

The inheritance configuration for this representation.

**Returns**

[Representation::Inheritance](/reference/representation/inheritance), `nil`

---

### .model

`.model(value)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L95)

Sets the model class for this representation.

Auto-detected from representation name when not set. Use
[.model_class](#model-class) to retrieve.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`value`** | `Class<ActiveRecord::Base>` |  |  |

</div>

**Returns**

`void`

**See also**

- [.model_class](#model-class)

**Example**

```ruby
model Invoice
```

---

### .model_class

`.model_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L556)

Auto-detected from representation name or set via [.model](#model).

**Returns**

`Class<ActiveRecord::Base>`

**See also**

- [.model](#model)

---

### .polymorphic_name

`.polymorphic_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L452)

Uses [.type_name](#type-name) if set, otherwise the model's `polymorphic_name`.

**Returns**

`String`

---

### .root

`.root(singular, plural = singular.to_s.pluralize)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L116)

Sets the JSON root key for this representation.

Auto-detected from model name when not set. Use [.root_key](#root-key) to retrieve.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`singular`** | `String`, `Symbol` |  |  |
| `plural` | `String`, `Symbol` | `singular.pluralize` |  |

</div>

**Returns**

`void`

**See also**

- [.root_key](#root-key)

**Example**

```ruby
root :bill, :bills
```

---

### .root_key

`.root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L543)

Derived from model name when [.root](#root) is not set.

**Returns**

[RootKey](/reference/representation/root-key)

**See also**

- [.root](#root)

---

### .serialize

`.serialize(record_or_collection, context: {}, include: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L514)

Serializes a record or collection to JSON-ready hashes.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`record_or_collection`** | `ActiveRecord::Base`, `Array<ActiveRecord::Base>` |  |  |
| `context` | `Hash` | `{}` |  |
| `include` | `Symbol`, `Array`, `Hash`, `nil` | `nil` |  |

</div>

**Returns**

`Hash`, `Array<Hash>`

**Example**

```ruby
InvoiceRepresentation.serialize(invoice)
InvoiceRepresentation.serialize(invoice, include: [:customer])
```

---

### .sti_name

`.sti_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L444)

Uses [.type_name](#type-name) if set, otherwise the model's `sti_name`.

**Returns**

`String`

---

### .subclass?

`.subclass?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L460)

Whether this representation is an STI subclass.

**Returns**

`Boolean`

---

### .type_name

`.type_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L434)

Overrides the model's default type name for STI and polymorphic types.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `Symbol`, `nil` | `nil` |  |

</div>

**Returns**

`String`, `nil`

**See also**

- [.sti_name](#sti-name)
- [.polymorphic_name](#polymorphic-name)

**Example**

```ruby
type_name :person
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
