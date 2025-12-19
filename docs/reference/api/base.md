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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L261)

---

### .built_contracts()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute built_contracts.

---

### .concern(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L247)

---

### .ensure_all_contracts_built!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L285)

---

### .ensure_contract_built!(contract_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L269)

---

### .enum(name, values: = nil, scope: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L188)

Defines a reusable enumeration type.

Enums can be referenced by name in `param` definitions using
the `enum:` option.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | enum name for referencing |
| `values` | `Array<String>` | allowed values |
| `scope` | `Class` | contract class for scoping (nil for global) |
| `description` | `String` | documentation description |
| `example` | `String` | example value for docs |
| `deprecated` | `Boolean` | mark as deprecated |

**Example**

```ruby
enum :status, values: %w[draft published archived]

# Later in contract:
param :status, enum: :status
```

---

### .info(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L233)

---

### .introspect(locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L255)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L265)

---

### .resolve_enum(name, scope:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L225)

---

### .resolve_type(name, scope: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L221)

---

### .resource(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L243)

---

### .resources(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L239)

---

### .scoped_name(scope, name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L229)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L165)

Defines a reusable custom type (object shape).

Custom types can be referenced by name in `param` definitions.
Scoped types are namespaced to a contract class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | type name for referencing |
| `scope` | `Class` | contract class for scoping (nil for global) |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint for docs |
| `deprecated` | `Boolean` | mark as deprecated |
| `schema_class` | `Class` | associate with a schema for type inference |

**Example: Global type**

```ruby
type :address do
  param :street, type: :string
  param :city, type: :string
  param :zip, type: :string
end
```

**Example: Using in a contract**

```ruby
param :shipping_address, type: :address
```

---

### .type_system()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L7)

Returns the value of attribute type_system.

---

### .union(name, scope: = nil, discriminator: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L213)

Defines a discriminated union type.

Unions allow a field to accept one of several shapes, distinguished
by a discriminator field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name for referencing |
| `scope` | `Class` | contract class for scoping (nil for global) |
| `discriminator` | `Symbol` | field name that identifies the variant |

**Example**

```ruby
union :payment_method, discriminator: :type do
  variant type: :card, tag: 'card' do
    param :last_four, type: :string
  end
  variant type: :bank, tag: 'bank' do
    param :account_number, type: :string
  end
end
```

---

### .with_options(options = {}, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L251)

---
