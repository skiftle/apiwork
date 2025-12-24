---
order: 5
prev: false
next: false
---

# Adapter::ApiTypeRegistrar

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_type_registrar.rb#L24)

Registers API-wide types during adapter initialization.

Passed to `register_api_types` in your adapter. Use to define
shared types like pagination, error responses, or enums.

**Example: Register pagination type**

```ruby
def register_api_types(type_registrar, schema_data)
  type_registrar.type :pagination do
    param :page, type: :integer
    param :per_page, type: :integer
    param :total, type: :integer
  end
end
```

**Example: Register enum**

```ruby
def register_api_types(type_registrar, schema_data)
  type_registrar.enum :status, values: %w[pending active completed]
end
```

## Instance Methods

### #enum(name, values:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_type_registrar.rb#L36)

Defines an enum type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

---

### #type(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_type_registrar.rb#L29)

Defines a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

---

### #union(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_type_registrar.rb#L50)

Defines a union type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

---
