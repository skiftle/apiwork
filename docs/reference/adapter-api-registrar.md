---
order: 7
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

**See also**

- [Apiwork::Api::Base.enum](api-base#enum)

---

### #resolve_enum

`#resolve_enum(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L62)

Resolves an enum registered at the API level.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

[Array](introspection-array), `nil` — the enum values if registered

---

### #resolve_type

`#resolve_type(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L50)

Resolves a type registered at the API level.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**Returns**

[Object](introspection-object), `nil` — the type definition if registered

---

### #type

`#type(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L29)

Defines a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**See also**

- [Apiwork::Api::Base.type](api-base#type)

---

### #union

`#union(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/api_registrar.rb#L43)

Defines a union type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

**See also**

- [Apiwork::Api::Base.union](api-base#union)

---
