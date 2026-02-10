---
order: 81
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L45)

Base class for representations.

Defines how an ActiveRecord model is represented in the API. Drives contracts
and runtime behavior. Sensible defaults are auto-detected from database columns
but can be overridden.

**Example: Basic representation**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :title
  attribute :status, filterable: true, sortable: true

  belongs_to :customer
  has_many :items
end
```

**Example: Contract**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

## Class Methods

### .abstract!

`.abstract!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L45)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L45)

Whether this representation is abstract.

**Returns**

`Boolean`

---

### .adapter

`.adapter(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L145)

Configures adapter options for this representation.

Overrides API-level options.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L60)

The associations for this representation.

**Returns**

Hash{Symbol =&gt; [Association](/reference/representation/association)}

---

### .attribute

`.attribute(name, decode: nil, deprecated: false, description: nil, empty: nil, encode: nil, enum: nil, example: nil, filterable: false, format: nil, max: nil, min: nil, nullable: nil, optional: nil, sortable: false, type: nil, writable: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L208)

Defines an attribute for this representation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The attribute name. |
| `type` | `Symbol<:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :number, :object, :string, :time, :unknown, :uuid>`, `nil` | `nil` | The type. If `nil` and name maps to a database column, auto-detected from column type. |
| `enum` | `Array`, `nil` | `nil` | The allowed values. If `nil`, auto-detected from Rails enum definition. |
| `optional` | `Boolean`, `nil` | `nil` | Whether the attribute is optional for writes. If `nil` and name maps to a database column, auto-detected from column default or NULL constraint. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. If `nil` and name maps to a database column, auto-detected from column NULL constraint. |
| `filterable` | `Boolean` | `false` | Whether the attribute is filterable. |
| `sortable` | `Boolean` | `false` | Whether the attribute is sortable. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the attribute is writable. |
| `encode` | `Proc`, `nil` | `nil` | Transform for serialization. |
| `decode` | `Proc`, `nil` | `nil` | Transform for deserialization. |
| `empty` | `Boolean`, `nil` | `nil` | Whether to use empty string instead of `null`. Serializes `nil` as `""` and deserializes `""` as `nil`. Only valid for `:string` type. |
| `min` | `Integer`, `nil` | `nil` | The minimum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `max` | `Integer`, `nil` | `nil` | The maximum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `format` | `Symbol<:date, :datetime, :double, :email, :float, :hostname, :int32, :int64, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | The format hint. Valid formats by type: `:decimal`/`:number` (`:double`, `:float`), `:integer` (`:int32`, `:int64`), `:string` (`:date`, `:datetime`, `:email`, `:hostname`, `:ipv4`, `:ipv6`, `:password`, `:url`, `:uuid`). |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |

</div>

**Returns**

`void`

**Yields** [Representation::Element](/reference/representation/element)

**Example: Basic**

```ruby
attribute :title
attribute :price, type: :decimal, min: 0
attribute :status, filterable: true, sortable: true
```

**Example: Custom method**

```ruby
attribute :total, type: :decimal

def total
  record.items.sum(:amount)
end
```

---

### .attributes

`.attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L53)

The attributes for this representation.

**Returns**

Hash{Symbol =&gt; [Attribute](/reference/representation/attribute)}

---

### .belongs_to

`.belongs_to(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, polymorphic: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L444)

Defines a belongs_to association for this representation.

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
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. If `nil`, auto-detected from foreign key column. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |

</div>

**Returns**

`void`

**See also**

- [#has_one](#has-one)

**Example: Basic**

```ruby
belongs_to :customer
```

**Example: Explicit representation**

```ruby
belongs_to :author, representation: AuthorRepresentation
```

**Example: Always included**

```ruby
belongs_to :customer, include: :always
```

**Example: Polymorphic**

```ruby
belongs_to :commentable, polymorphic: [PostRepresentation, CustomerRepresentation]
```

**Example: Custom method**

```ruby
belongs_to :customer

def customer
  record.customer || Customer.default
end
```

---

### .deprecated!

`.deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L547)

Marks this representation as deprecated.

Metadata included in exports.

**Returns**

`void`

**Example**

```ruby
deprecated!
```

---

### .description

`.description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L532)

The description for this representation.

Metadata included in exports.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The description. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L611)

Deserializes using this representation's decode transformers.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`hash_or_array`** | `Hash`, `Array<Hash>` |  | The hash or array of hashes to deserialize. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L562)

The example value for this representation.

Metadata included in exports.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Hash`, `nil` | `nil` | The example. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L366)

Defines a has_many association for this representation.

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
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |

</div>

**Returns**

`void`

**See also**

- [#has_one](#has-one)

**Example: Basic**

```ruby
has_many :items
```

**Example: Explicit representation**

```ruby
has_many :comments, representation: CommentRepresentation
```

**Example: Always included**

```ruby
has_many :items, include: :always
```

**Example: Custom method**

```ruby
has_many :items

def items
  record.items.limit(5)
end
```

---

### .has_one

`.has_one(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L293)

Defines a has_one association for this representation.

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
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |

</div>

**Returns**

`void`

**Example: Basic**

```ruby
has_one :profile
```

**Example: Explicit representation**

```ruby
has_one :author, representation: AuthorRepresentation
```

**Example: Always included**

```ruby
has_one :customer, include: :always
```

**Example: Custom method**

```ruby
has_one :profile

def profile
  record.profile || record.build_profile
end
```

---

### .inheritance

`.inheritance`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L69)

The inheritance configuration for this representation.

Auto-configured when the model uses STI and representation classes mirror the model hierarchy.

**Returns**

[Representation::Inheritance](/reference/representation/inheritance), `nil`

---

### .model

`.model(value)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L103)

Sets the model class for this representation.

Auto-detected from representation name when not set. Use
[.model_class](#model-class) to retrieve.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`value`** | `Class<ActiveRecord::Base>` |  | The model class. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L641)

The model class for this representation.

Auto-detected from representation name or set via [.model](#model).

**Returns**

`Class<ActiveRecord::Base>`

**See also**

- [.model](#model)

---

### .polymorphic_name

`.polymorphic_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L509)

The polymorphic name for this representation.

Uses [.type_name](#type-name) if set, otherwise the model's `polymorphic_name`.

**Returns**

`String`

---

### .root

`.root(singular, plural = singular.to_s.pluralize)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L126)

Sets the JSON root key for this representation.

Auto-detected from model name when not set. Use [.root_key](#root-key) to retrieve.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`singular`** | `String`, `Symbol` |  | The singular root key. |
| `plural` | `String`, `Symbol` | `singular.pluralize` | The plural root key. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L626)

The root key for this representation.

Derived from model name when [.root](#root) is not set.

**Returns**

[RootKey](/reference/representation/root-key)

**See also**

- [.root](#root)

---

### .serialize

`.serialize(record_or_collection, context: {}, include: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L594)

Serializes a record or collection to JSON-ready hashes.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`record_or_collection`** | `ActiveRecord::Base`, `Array<ActiveRecord::Base>` |  | The record or collection to serialize. |
| `context` | `Hash` | `{}` | The serialization context. |
| `include` | `Symbol`, `Array`, `Hash`, `nil` | `nil` | The associations to include. |

</div>

**Returns**

`Hash`, `Array<Hash>`

**Example: Basic**

```ruby
InvoiceRepresentation.serialize(invoice)
# => { id: 1, total: 99.00, status: 'paid' }
```

**Example: Collection**

```ruby
InvoiceRepresentation.serialize(invoices)
# => [{ id: 1, ... }, { id: 2, ... }]
```

**Example: With associations**

```ruby
InvoiceRepresentation.serialize(invoice, include: [:customer, :items])
# => { id: 1, ..., customer: { id: 1, name: 'Acme' }, items: [...] }
```

**Example: Nested associations**

```ruby
InvoiceRepresentation.serialize(invoice, include: { customer: [:address] })
# => { id: 1, ..., customer: { id: 1, name: 'Acme', address: { ... } } }
```

---

### .sti_name

`.sti_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L499)

The STI name for this representation.

Uses [.type_name](#type-name) if set, otherwise the model's `sti_name`.

**Returns**

`String`

---

### .subclass?

`.subclass?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L517)

Whether this representation is an STI subclass.

**Returns**

`Boolean`

---

### .type_name

`.type_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L487)

Overrides the model's default type name for STI and polymorphic types.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `Symbol`, `nil` | `nil` | The type name override. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L80)

The context for this representation.

**Returns**

`Hash`

---

### #record

`#record`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L86)

The record for this representation.

**Returns**

`ActiveRecord::Base`

---
