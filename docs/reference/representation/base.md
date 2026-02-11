---
order: 81
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L44)

Base class for representations.

Defines how an ActiveRecord model is represented in the API. Drives contracts and runtime behavior.
Sensible defaults are auto-detected from database columns but can be overridden. Supports STI and
polymorphic associations.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L44)

Marks this representation as abstract.

Abstract representations don't require a model and serve as base classes for other representations.
Use this when creating application-wide base representations. Subclasses automatically become non-abstract.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L44)

Whether this representation is abstract.

**Returns**

`Boolean`

---

### .adapter

`.adapter(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L165)

Configures adapter options for this representation.

Overrides API-level options. Subclasses inherit parent adapter options.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L59)

The associations for this representation.

**Returns**

Hash{Symbol =&gt; [Association](/reference/representation/association)}

---

### .attribute

`.attribute(name, decode: nil, deprecated: false, description: nil, empty: nil, encode: nil, enum: nil, example: nil, filterable: false, format: nil, max: nil, min: nil, nullable: nil, optional: nil, preload: nil, sortable: false, type: nil, writable: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L266)

Defines an attribute for this representation.

Subclasses inherit parent attributes.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The attribute name. |
| `decode` | `Proc`, `nil` | `nil` | Transform for request input (API to database). Must preserve the attribute type. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `empty` | `Boolean`, `nil` | `nil` | Whether to use empty string instead of `null`. Serializes `nil` as `""` and deserializes `""` as `nil`. Only valid for `:string` type. |
| `encode` | `Proc`, `nil` | `nil` | Transform for response output (database to API). Must preserve the attribute type. |
| `enum` | `Array`, `nil` | `nil` | The allowed values. If `nil`, auto-detected from Rails enum definition. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `filterable` | `Boolean` | `false` | Whether the attribute is filterable. |
| `format` | `Symbol<:date, :datetime, :double, :email, :float, :hostname, :int32, :int64, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Valid formats by type: `:decimal`/`:number` (`:double`, `:float`), `:integer` (`:int32`, `:int64`), `:string` (`:date`, `:datetime`, `:email`, `:hostname`, `:ipv4`, `:ipv6`, `:password`, `:url`, `:uuid`). |
| `max` | `Integer`, `nil` | `nil` | The maximum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `min` | `Integer`, `nil` | `nil` | The minimum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. If `nil` and name maps to a database column, auto-detected from column NULL constraint. |
| `optional` | `Boolean`, `nil` | `nil` | Whether the attribute is optional for writes. If `nil` and name maps to a database column, auto-detected from column default or NULL constraint. |
| `preload` | `Symbol`, `Array`, `Hash`, `nil` | `nil` | Associations to preload for this attribute. Use when custom attributes depend on associations. |
| `sortable` | `Boolean` | `false` | Whether the attribute is sortable. |
| `type` | `Symbol<:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :number, :object, :string, :time, :unknown, :uuid>`, `nil` | `nil` | The type. If `nil` and name maps to a database column, auto-detected from column type. Defaults to `:unknown` for json/jsonb columns and when no column exists (custom attributes). Use an explicit type or block in those cases. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the attribute is writable. Use `[ on: :create ](/reference/ on: :create )` for immutable fields or `[ on: :update ](/reference/ on: :update )` for fields that can only be changed after creation. |

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

**Example: Custom attribute with preload**

```ruby
attribute :total, type: :decimal, preload: :items

def total
  record.items.sum(:amount)
end
```

**Example: Nested preload**

```ruby
attribute :total_with_tax, type: :decimal, preload: { items: :tax_rate }

def total_with_tax
  record.items.sum { |item| item.amount * (1 + item.tax_rate.rate) }
end
```

**Example: Inline type for JSON column**

```ruby
attribute :settings do
  object do
    string :theme
    boolean :notifications
  end
end
```

**Example: Encode/decode transforms**

```ruby
attribute :status, encode: ->(value) { value.upcase }, decode: ->(value) { value.downcase }
```

**Example: Writable only on create**

```ruby
attribute :slug, writable: { on: :create }
```

**Example: Explicit enum values**

```ruby
attribute :priority, enum: [:low, :medium, :high]
```

**Example: Multiple preloads**

```ruby
attribute :summary, type: :string, preload: [:items, :customer]

def summary
  "#{record.customer.name}: #{record.items.count} items"
end
```

---

### .attributes

`.attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L52)

The attributes for this representation.

**Returns**

Hash{Symbol =&gt; [Attribute](/reference/representation/attribute)}

---

### .belongs_to

`.belongs_to(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, polymorphic: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L516)

Defines a belongs_to association for this representation.

Subclasses inherit parent associations.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The association name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `filterable` | `Boolean` | `false` | Whether the association is filterable. |
| `include` | `Symbol<:always, :optional>` | `:optional` | The inclusion strategy. `:always` includes automatically but has circular reference protection. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. If `nil`, auto-detected from foreign key column NULL constraint. |
| `polymorphic` | `Array<Class<Representation::Base>>`, `nil` | `nil` | The allowed representation classes for polymorphic associations. |
| `representation` | `Class<Representation::Base>`, `nil` | `nil` | The representation class. If `nil`, inferred from the associated model in the same namespace (e.g., `CustomerRepresentation` for `Customer`). |
| `sortable` | `Boolean` | `false` | Whether the association is sortable. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the association is writable. Use `[ on: :create ](/reference/ on: :create )` for immutable associations or `[ on: :update ](/reference/ on: :update )` for associations that can only be changed after creation. |

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

**Example: Custom association**

```ruby
belongs_to :customer

def customer
  record.customer || Customer.default
end
```

---

### .deprecated!

`.deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L621)

Marks this representation as deprecated.

Metadata included in exports.

**Returns**

`void`

**Example**

```ruby
deprecated!
```

---

### .deprecated?

`.deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L729)

Whether this representation is deprecated.

**Returns**

`Boolean`

---

### .description

`.description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L606)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L691)

Transforms a hash or an array of hashes for records.

Applies attribute decoders, maps STI and polymorphic type names,
and recursively deserializes nested associations.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L636)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L434)

Defines a has_many association for this representation.

Subclasses inherit parent associations.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The association name. |
| `allow_destroy` | `Boolean` | `false` | Whether nested records can be destroyed. Auto-detected from model nested_attributes_options. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `filterable` | `Boolean` | `false` | Whether the association is filterable. |
| `include` | `Symbol<:always, :optional>` | `:optional` | The inclusion strategy. `:always` includes automatically but has circular reference protection. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. |
| `representation` | `Class<Representation::Base>`, `nil` | `nil` | The representation class. If `nil`, inferred from the associated model in the same namespace (e.g., `CustomerRepresentation` for `Customer`). |
| `sortable` | `Boolean` | `false` | Whether the association is sortable. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the association is writable. Use `[ on: :create ](/reference/ on: :create )` for immutable associations or `[ on: :update ](/reference/ on: :update )` for associations that can only be changed after creation. |

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

**Example: Custom association**

```ruby
has_many :items

def items
  record.items.limit(5)
end
```

---

### .has_one

`.has_one(name, deprecated: false, description: nil, example: nil, filterable: false, include: :optional, nullable: nil, representation: nil, sortable: false, writable: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L357)

Defines a has_one association for this representation.

Subclasses inherit parent associations.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The association name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `filterable` | `Boolean` | `false` | Whether the association is filterable. |
| `include` | `Symbol<:always, :optional>` | `:optional` | The inclusion strategy. `:always` includes automatically but has circular reference protection. |
| `nullable` | `Boolean`, `nil` | `nil` | Whether the value can be `null`. |
| `representation` | `Class<Representation::Base>`, `nil` | `nil` | The representation class. If `nil`, inferred from the associated model in the same namespace (e.g., `CustomerRepresentation` for `Customer`). |
| `sortable` | `Boolean` | `false` | Whether the association is sortable. |
| `writable` | `Boolean`, `Hash<on: :create \| :update>` | `false` | Whether the association is writable. Use `[ on: :create ](/reference/ on: :create )` for immutable associations or `[ on: :update ](/reference/ on: :update )` for associations that can only be changed after creation. |

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

**Example: Custom association**

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
Subclasses share the parent's inheritance configuration.

**Returns**

[Representation::Inheritance](/reference/representation/inheritance), `nil`

---

### .model

`.model(value)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L124)

Configures the model class for this representation.

Auto-detected from representation name when not set. Use [.model_class](#model-class) to retrieve.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`value`** | `Class<ActiveRecord::Base>` |  | The model class. |

</div>

**Returns**

`void`

**Example**

```ruby
model Invoice
```

---

### .model_class

`.model_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L719)

The model class for this representation.

Auto-detected from representation name or set via [.model](#model).

**Returns**

`Class<ActiveRecord::Base>`

---

### .polymorphic_name

`.polymorphic_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L583)

The polymorphic name for this representation.

Uses [.type_name](#type-name) if set, otherwise the model's `polymorphic_name`.

**Returns**

`String`

---

### .root

`.root(singular, plural = singular.to_s.pluralize)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L146)

Configures the JSON root key for this representation.

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

**Example**

```ruby
root :bill, :bills
```

---

### .root_key

`.root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L705)

The root key for this representation.

Derived from model name when [.root](#root) is not set.

**Returns**

[RootKey](/reference/representation/root-key)

---

### .serialize

`.serialize(record_or_collection, context: {}, include: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L671)

Transforms a record or an array of records to hashes.

Applies attribute encoders, maps STI and polymorphic type names,
and recursively serializes nested associations.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L573)

The STI name for this representation.

Uses [.type_name](#type-name) if set, otherwise the model's `sti_name`.

**Returns**

`String`

---

### .subclass?

`.subclass?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L591)

Whether this representation is an STI subclass.

**Returns**

`Boolean`

---

### .type_name

`.type_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L561)

The type name for this representation.

Overrides the model's default for STI and polymorphic types.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `Symbol`, `nil` | `nil` | The type name. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/base.rb#L108)

The serialization context.

Passed from controller or directly to [.serialize](#serialize). Use for data that isn't on the record, like
current user or permissions.

**Returns**

`Hash`

**Example: Override in controller**

```ruby
def context
  { current_user: current_user }
end
```

**Example: Access in custom attribute**

```ruby
attribute :editable, type: :boolean

def editable
  context[:current_user]&.admin?
end
```

---
