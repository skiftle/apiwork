---
order: 4
prev: false
next: false
---

# Adapter::APIRegistrar

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L24)

Registers API-wide types during adapter initialization.

Passed to `register_api` in your adapter. Use to define
shared types like pagination, error responses, or enums.

**Example: Register pagination type**

```ruby
def register_api(registrar, schema_data)
  registrar.type :pagination do
    param :page, type: :integer
    param :per_page, type: :integer
    param :total, type: :integer
  end
end
```

**Example: Register enum**

```ruby
def register_api(registrar, schema_data)
  registrar.enum :status, values: %w[pending active completed]
end
```

## Instance Methods

### #enum(name, values:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L36)

Defines an enum type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

---

### #resolve_enum(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L62)

Resolves an enum registered at the API level.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Array, nil` — the enum values if registered

---

### #resolve_type(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L50)

Resolves a type registered at the API level.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**Returns**

`Object, nil` — the type definition if registered

---

### #type(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L29)

Defines a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

---

### #union(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L43)

Defines a union type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

---
