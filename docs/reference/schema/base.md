---
order: 94
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L5)

## Class Methods

### .adapter(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L148)

---

### .api_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L132)

---

### .api_path()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L139)

---

### .attribute(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L207)

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

### .auto_detect_model()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L71)

---

### .belongs_to(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L225)

---

### .column_for(attribute_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L397)

---

### .deprecated(value = true)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L338)

---

### .deprecated?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L342)

**Returns**

`Boolean` — 

---

### .derive_variant_tag()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L285)

---

### .description(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L332)

---

### .discriminator(name = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L250)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L294)

---

### .discriminator_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L298)

---

### .discriminator_sti_mapping()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L328)

---

### .ensure_auto_detection_complete()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L119)

---

### .example(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L346)

---

### .filterable_attributes()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L369)

---

### .has_many(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L219)

---

### .has_one(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L213)

---

### .model(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L58)

---

### .model?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L114)

**Returns**

`Boolean` — 

---

### .model_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L109)

---

### .needs_discriminator_transform?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L324)

**Returns**

`Boolean` — 

---

### .register_variant(tag:, schema:, sti_type:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L289)

---

### .required_attributes_for(action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L387)

---

### .required_columns()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L401)

---

### .resolve_association_schema(reflection, base_schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L50)

---

### .resolve_option(name, subkey = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L157)

---

### .root(singular, plural = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L126)

---

### .root_key()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L360)

---

### .sortable_attributes()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L373)

---

### .sti_base?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L314)

**Returns**

`Boolean` — 

---

### .sti_type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L306)

---

### .sti_variant?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L320)

**Returns**

`Boolean` — 

---

### .try_constantize_model(namespace, model_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L94)

---

### .type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L352)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L356)

---

### .variant(as: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L273)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L302)

---

### .variants()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L310)

---

### .writable_attributes_for(action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L377)

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
