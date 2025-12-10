---
order: 111
prev: false
next: false
---

# ZodMapper

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L5)

## Instance Methods

### #action_schema_name(resource_name, action_name, suffix, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L123)

---

### #build_action_request_body_schema(resource_name, action_name, body_params, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L78)

---

### #build_action_request_query_schema(resource_name, action_name, query_params, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L66)

---

### #build_action_request_schema(resource_name, action_name, request_data, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L90)

---

### #build_action_response_body_schema(resource_name, action_name, response_body_definition, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L108)

---

### #build_action_response_schema(resource_name, action_name, response_data, parent_path: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L116)

---

### #build_object_schema(type_name, type_shape, action_name: = nil, recursive: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L31)

---

### #build_union_schema(type_name, type_shape)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L51)

---

### #initialize(introspection:, key_format: = :keep)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L26)

**Returns**

`ZodMapper` — a new instance of ZodMapper

---

### #introspection()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L23)

Returns the value of attribute introspection.

---

### #key_format()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L23)

Returns the value of attribute key_format.

---

### #map_array_type(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L187)

---

### #map_discriminated_union(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L211)

---

### #map_field_definition(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L131)

---

### #map_format_to_zod(format)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L247)

---

### #map_literal_type(definition)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L220)

---

### #map_object_type(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L168)

---

### #map_primitive(definition)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L229)

---

### #map_type_definition(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L146)

---

### #map_union_type(definition, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L202)

---

### #pascal_case(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L267)

---

### #schema_reference(symbol)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/zod_mapper.rb#L263)

---
