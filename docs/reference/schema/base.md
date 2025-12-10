---
order: 97
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L173)

---

### .auto_detect_model()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L71)

---

### .belongs_to(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L191)

---

### .column_for(attribute_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L329)

---

### .deprecated(value = true)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L270)

---

### .deprecated?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L274)

**Returns**

`Boolean` — 

---

### .derive_variant_tag()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L217)

---

### .description(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L264)

---

### .discriminator(name = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L197)

---

### .discriminator_column()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L226)

---

### .discriminator_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L230)

---

### .discriminator_sti_mapping()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L260)

---

### .ensure_auto_detection_complete()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L119)

---

### .example(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L278)

---

### .filterable_attributes()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L301)

---

### .has_many(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L185)

---

### .has_one(name, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L179)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L256)

**Returns**

`Boolean` — 

---

### .register_variant(tag:, schema:, sti_type:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L221)

---

### .required_attributes_for(action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L319)

---

### .required_columns()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L333)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L292)

---

### .sortable_attributes()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L305)

---

### .sti_base?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L246)

**Returns**

`Boolean` — 

---

### .sti_type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L238)

---

### .sti_variant?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L252)

**Returns**

`Boolean` — 

---

### .try_constantize_model(namespace, model_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L94)

---

### .type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L284)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L288)

---

### .variant(as: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L205)

---

### .variant_tag()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L234)

---

### .variants()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L242)

---

### .writable_attributes_for(action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/base.rb#L309)

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
