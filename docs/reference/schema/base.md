---
order: 103
---

# Base

## Class Methods

### .adapter(&block)

---

### .api_class()

---

### .api_path()

---

### .attribute(name, **options)

---

### .auto_detect_model()

---

### .belongs_to(name, **options)

---

### .column_for(attribute_name)

---

### .deprecated(value = true)

---

### .deprecated?()

**Returns**

`Boolean` — 

---

### .derive_variant_tag()

---

### .description(value = nil)

---

### .discriminator(name = nil)

---

### .discriminator_column()

---

### .discriminator_name()

---

### .discriminator_sti_mapping()

---

### .ensure_auto_detection_complete()

---

### .example(value = nil)

---

### .filterable_attributes()

---

### .has_many(name, **options)

---

### .has_one(name, **options)

---

### .model(value = nil)

---

### .model?()

**Returns**

`Boolean` — 

---

### .model_class()

---

### .needs_discriminator_transform?()

**Returns**

`Boolean` — 

---

### .register_variant(tag:, schema:, sti_type:)

---

### .required_attributes_for(action)

---

### .required_columns()

---

### .resolve_association_schema(reflection, base_schema_class)

---

### .resolve_option(name, subkey = nil)

---

### .root(singular, plural = nil)

---

### .root_key()

---

### .sortable_attributes()

---

### .sti_base?()

**Returns**

`Boolean` — 

---

### .sti_type()

---

### .sti_variant?()

**Returns**

`Boolean` — 

---

### .try_constantize_model(namespace, model_name)

---

### .type()

---

### .type=(value)

Sets the attribute type

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `` | the value to set the attribute type to. |

---

### .validate!()

---

### .variant(as: = nil)

---

### .variant_tag()

---

### .variants()

---

### .writable_attributes_for(action)

---

## Instance Methods

### #as_json()

---

### #context()

Returns the value of attribute context.

---

### #detect_association_resource(association_name)

---

### #include()

Returns the value of attribute include.

---

### #initialize(object, context: = {}, include: = nil)

**Returns**

`Base` — a new instance of Base

---

### #object()

Returns the value of attribute object.

---
