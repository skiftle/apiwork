---
order: 7
prev: false
next: false
---

# Adapter::ContractTypeRegistrar

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L27)

Registers contract-scoped types during contract building.

Passed to `register_contract_types` in your adapter. Use to define
types specific to a resource contract (request/response shapes).

**Example: Register request body type**

```ruby
def register_contract_types(type_registrar, schema_class, actions:)
  type_registrar.type :user_input do
    param :name, type: :string
    param :email, type: :string
  end
end
```

**Example: Define action contracts**

```ruby
def register_contract_types(type_registrar, schema_class, actions:)
  type_registrar.define_action :index do
    response do
      param :users, type: :array, of: :user
    end
  end
end
```

## Instance Methods

### #api_registrar()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L103)

Returns a registrar for API-level types.
Use this to define or resolve types at the API scope.

**Returns**

`ApiTypeRegistrar` — the API type registrar

---

### #define_action(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L53)

Defines an action with query, body, and response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |

---

### #enum(name, values:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L39)

Defines an enum type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

---

### #find_contract_for_schema(schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L85)

Finds the contract class for an associated schema.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `schema_class` | `Class` | the schema class |

**Returns**

`Class, nil` — the contract class

---

### #import(type_name, from:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L60)

Imports a type from another contract or the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | the type to import |
| `from` | `Class` | source contract class |

---

### #imports()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L96)

Returns the hash of imported types.

**Returns**

`Hash` — imported types

---

### #resolve_enum(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L73)

Resolves an enum registered in this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Array, nil` — the enum values if registered

---

### #resolve_type(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L67)

Resolves a type registered in this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**Returns**

`Object, nil` — the type definition if registered

---

### #scoped_name(name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L79)

Returns the fully qualified name for a type in this contract's scope.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the local type name |

**Returns**

`Symbol` — the scoped name

---

### #type(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L32)

Defines a named type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

---

### #union(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L46)

Defines a union type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

---
