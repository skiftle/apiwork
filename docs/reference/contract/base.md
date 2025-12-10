---
order: 57
---

# Base

## Class Methods

### .action(action_name, replace: = false, &block)

DOCUMENTATION

---

### .action_definition(action_name)

---

### .api_class()

---

### .api_path()

---

### .as_json()

---

### .define_action(action_name, &block)

---

### .enum(name, values: = nil, description: = nil, example: = nil, deprecated: = false)

---

### .find_contract_for_schema(schema_class)

---

### .global_type(name, &block)

---

### .identifier(value = nil)

DOCUMENTATION

---

### .import(contract_class, as:)

DOCUMENTATION

---

### .inherited(subclass)

---

### .introspect(action: = nil, locale: = nil)

DOCUMENTATION

---

### .parse_response(body, action)

---

### .register_sti_variants(*variant_schema_classes)

---

### .reset_build_state!()

---

### .resolve_custom_type(type_name, visited: = Set.new)

---

### .resolve_enum(enum_name, visited: = Set.new)

---

### .resolve_type(name)

---

### .schema!()

DOCUMENTATION

---

### .schema?()

DOCUMENTATION

**Returns**

`Boolean` — 

---

### .schema_class()

---

### .scope_prefix()

---

### .scoped_name(name)

---

### .type(name, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

---

### .union(name, discriminator: = nil, &block)

---

## Instance Methods

### #action_name()

Returns the value of attribute action_name.

---

### #body()

Returns the value of attribute body.

---

### #initialize(query:, body:, action_name:, coerce: = false)

**Returns**

`Base` — a new instance of Base

---

### #invalid?()

**Returns**

`Boolean` — 

---

### #issues()

Returns the value of attribute issues.

---

### #query()

Returns the value of attribute query.

---

### #valid?()

**Returns**

`Boolean` — 

---
