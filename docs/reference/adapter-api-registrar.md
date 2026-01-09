---
order: 8
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
def register_api(registrar, capabilities)
  registrar.type :pagination do
    param :page, type: :integer
    param :per_page, type: :integer
    param :total, type: :integer
  end
end
```

**Example: Register enum**

```ruby
def register_api(registrar, capabilities)
  registrar.enum :status, values: %w[pending active completed]
end
```

## Instance Methods

### #enum

`#enum(name, values:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L36)

Defines an enum type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

---

### #enum?

`#enum?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L56)

Checks if an enum is registered.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Boolean` — true if enum exists

---

### #enum_values

`#enum_values(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L68)

Returns the values for a registered enum.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Array<String>`, `nil` — enum values or nil

---

### #type

`#type(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L29)

Defines a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

---

### #type?

`#type?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L50)

Checks if a type is registered.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**Returns**

`Boolean` — true if type exists

---

### #union

`#union(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L43)

Defines a union type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

---
