---
order: 109
prev: false
next: false
---

# TypescriptMapper

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L5)

## Instance Methods

### #action_type_name(resource_name, action_name, suffix, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L113)

---

### #build_action_request_body_type(resource_name, action_name, body_params, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L69)

---

### #build_action_request_query_type(resource_name, action_name, query_params, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L55)

---

### #build_action_request_type(resource_name, action_name, request_data, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L83)

---

### #build_action_response_body_type(resource_name, action_name, response_body_definition, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L101)

---

### #build_action_response_type(resource_name, action_name, response_data, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L107)

---

### #build_interface(type_name, type_shape, action_name: = nil, recursive: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L14)

---

### #build_union_type(type_name, type_shape)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L36)

---

### #initialize(introspection:, key_format: = :keep)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L9)

**Returns**

`TypescriptMapper` — a new instance of TypescriptMapper

---

### #introspection()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L6)

Returns the value of attribute introspection.

---

### #key_format()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L6)

Returns the value of attribute key_format.

---

### #map_array_type(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L186)

---

### #map_field(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L121)

---

### #map_literal_type(definition)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L212)

---

### #map_object_type(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L170)

---

### #map_primitive(type)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L221)

---

### #map_type_definition(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L149)

---

### #map_union_type(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L205)

---

### #pascal_case(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L242)

---

### #type_reference(symbol)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/typescript_mapper.rb#L238)

---
