---
order: 117
---

# ZodMapper

## Instance Methods

### #action_schema_name(resource_name, action_name, suffix, parent_path: = nil)

---

### #build_action_request_body_schema(resource_name, action_name, body_params, parent_path: = nil)

---

### #build_action_request_query_schema(resource_name, action_name, query_params, parent_path: = nil)

---

### #build_action_request_schema(resource_name, action_name, request_data, parent_path: = nil)

---

### #build_action_response_body_schema(resource_name, action_name, response_body_definition, parent_path: = nil)

---

### #build_action_response_schema(resource_name, action_name, response_data, parent_path: = nil)

---

### #build_object_schema(type_name, type_shape, action_name: = nil, recursive: = false)

---

### #build_union_schema(type_name, type_shape)

---

### #initialize(introspection:, key_format: = :keep)

**Returns**

`ZodMapper` — a new instance of ZodMapper

---

### #introspection()

Returns the value of attribute introspection.

---

### #key_format()

Returns the value of attribute key_format.

---

### #map_array_type(definition, action_name: = nil)

---

### #map_discriminated_union(definition, action_name: = nil)

---

### #map_field_definition(definition, action_name: = nil)

---

### #map_format_to_zod(format)

---

### #map_literal_type(definition)

---

### #map_object_type(definition, action_name: = nil)

---

### #map_primitive(definition)

---

### #map_type_definition(definition, action_name: = nil)

---

### #map_union_type(definition, action_name: = nil)

---

### #pascal_case(name)

---

### #schema_reference(symbol)

---
