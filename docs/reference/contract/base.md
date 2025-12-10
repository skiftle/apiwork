---
order: 57
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L5)

## Class Methods

### .action(action_name, replace: = false, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L143)

DOCUMENTATION

---

### .action_definition(action_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L161)

---

### .api_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L186)

---

### .api_path()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L177)

---

### .as_json()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L173)

---

### .define_action(action_name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L220)

---

### .enum(name, values: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L114)

---

### .find_contract_for_schema(schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L64)

---

### .global_type(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L199)

---

### .identifier(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L42)

DOCUMENTATION

---

### .import(contract_class, as:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L123)

DOCUMENTATION

---

### .inherited(subclass)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L35)

---

### .introspect(action: = nil, locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L169)

DOCUMENTATION

---

### .parse_response(body, action)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L195)

---

### .register_sti_variants(*variant_schema_classes)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L73)

---

### .reset_build_state!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L94)

---

### .resolve_custom_type(type_name, visited: = Set.new)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L152)

---

### .resolve_enum(enum_name, visited: = Set.new)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L207)

---

### .resolve_type(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L203)

---

### .schema!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

DOCUMENTATION

---

### .schema?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L90)

DOCUMENTATION

**Returns**

`Boolean` — 

---

### .schema_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L85)

---

### .scope_prefix()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L99)

---

### .scoped_name(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L216)

---

### .type(name, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L108)

---

### .union(name, discriminator: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L118)

---

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute action_name.

---

### #body()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute body.

---

### #initialize(query:, body:, action_name:, coerce: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L18)

**Returns**

`Base` — a new instance of Base

---

### #invalid?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L30)

**Returns**

`Boolean` — 

---

### #issues()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute issues.

---

### #query()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L13)

Returns the value of attribute query.

---

### #valid?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L26)

**Returns**

`Boolean` — 

---
