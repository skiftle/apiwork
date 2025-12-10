---
order: 2
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L5)

## Class Methods

### .adapter(name = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L125)

---

### .adapter_config()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute adapter_config.

---

### .as_json()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L202)

---

### .built_contracts()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute built_contracts.

---

### .concern(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L188)

---

### .ensure_all_contracts_built!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L226)

---

### .ensure_contract_built!(contract_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L210)

---

### .enum(name, values: = nil, scope: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L148)

---

### .info(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L174)

---

### .introspect(locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L196)

---

### .key_format(format = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L35)

---

### .metadata()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute metadata.

---

### .mount(path)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L17)

---

### .mount_path()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute mount_path.

---

### .namespaces()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute namespaces.

---

### .raises(*error_code_keys)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L108)

---

### .recorder()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute recorder.

---

### .reset_contracts!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L206)

---

### .resolve_enum(name, scope:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L166)

---

### .resolve_type(name, scope: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L162)

---

### .resource(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L184)

---

### .resources(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L180)

---

### .scoped_name(scope, name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L170)

---

### .spec(type, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L74)

---

### .spec_config(type)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L100)

---

### .spec_configs()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute spec_configs.

---

### .spec_path(type)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L96)

---

### .specs()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute specs.

---

### .specs?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L104)

**Returns**

`Boolean` — 

---

### .transform_request(hash)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L44)

---

### .transform_response(hash)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L48)

---

### .type(name, scope: = nil, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L142)

---

### .type_system()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute type_system.

---

### .union(name, scope: = nil, discriminator: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L154)

---

### .with_options(options = {}, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L192)

---
