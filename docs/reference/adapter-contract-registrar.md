---
order: 11
prev: false
next: false
---

# Adapter::ContractRegistrar

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L27)

Registers contract-scoped types during contract building.

Passed to `register_contract` in your adapter. Use to define
types specific to a resource contract (request/response shapes).

**Example: Register request body type**

```ruby
def register_contract(registrar, schema_class, actions)
  registrar.type :user_input do
    param :name, type: :string
    param :email, type: :string
  end
end
```

**Example: Define action contracts**

```ruby
def register_contract(registrar, schema_class, actions)
  actions.each do |name, action|
    registrar.define_action(name) do
      # ...
    end
  end
end
```

## Instance Methods

### #api_registrar

`#api_registrar`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L113)

Returns a registrar for API-level types.
Use this to define or resolve types at the API scope.

**Returns**

[Adapter::APIRegistrar](adapter-api-registrar) — the API registrar

---

### #define_action

`#define_action(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L53)

Defines an action with query, body, and response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |

**Returns**

[ActionDefinition](introspection-action-definition) — the action definition

**See also**

- [Apiwork::Contract::Base.define_action](contract-base#define-action)

---

### #enum

`#enum(name, values:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L39)

Defines an enum type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

**See also**

- [Apiwork::Contract::Base.enum](contract-base#enum)

---

### #find_contract_for_schema

`#find_contract_for_schema(schema_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L86)

Finds the contract class for an associated schema.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |

**Returns**

`Class`, `nil` — a [Contract::Base](contract-base) subclass if found

---

### #import

`#import(type_name, from:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L61)

Imports a type from another contract or the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | the type to import |
| `from` | `Class` | a [Contract::Base](contract-base) subclass |

**See also**

- [Apiwork::Contract::Base.import](contract-base#import)

---

### #imports

`#imports`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L97)

Returns the hash of imported types.

**Returns**

`Hash` — imported types

---

### #resolve_enum

`#resolve_enum(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L74)

Resolves an enum registered in this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Array`, `nil` — the enum values if registered

---

### #resolve_type

`#resolve_type(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L68)

Resolves a type registered in this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**Returns**

`Object`, `nil` — the type definition if registered

---

### #scoped_name

`#scoped_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L80)

Returns the fully qualified name for a type in this contract's scope.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the local type name |

**Returns**

`Symbol` — the scoped name

---

### #type

`#type(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L32)

Defines a named type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the type name |

**See also**

- [Apiwork::Contract::Base.type](contract-base#type)

---

### #union

`#union(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L46)

Defines a union type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

**See also**

- [Apiwork::Contract::Base.union](contract-base#union)

---
