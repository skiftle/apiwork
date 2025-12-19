---
order: 15
prev: false
next: false
---

# TypeSystem

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L5)

## Instance Methods

### #clear!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L80)

---

### #enum_metadata(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L47)

---

### #enums()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L6)

Returns the value of attribute enums.

---

### #initialize()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L9)

**Returns**

`TypeSystem` — a new instance of TypeSystem

---

### #register_enum(name, values = nil, scope: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L62)

---

### #register_type(name, scope: = nil, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L14)

---

### #register_union(name, payload, scope: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L26)

---

### #resolve_enum(name, scope: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L72)

---

### #resolve_type(name, scope: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L31)

---

### #scoped_name(scope, name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L51)

---

### #type_metadata(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L43)

---

### #types()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L6)

Returns the value of attribute types.

---

### #unregister_type(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/type_system.rb#L85)

---
