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

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L30)

**Returns**

`Class` — the contract class being configured

---

### #define_action(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L57)

Defines an action with query, body, and response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |

---

### #enum(name, values:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L43)

Defines an enum type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

---

### #import(type_name, from:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L71)

Imports a type from another contract or the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | the type to import |
| `from` | `Class` | source contract class |

---

### #type(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L36)

Defines a named type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

---

### #union(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_type_registrar.rb#L50)

Defines a union type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

---
