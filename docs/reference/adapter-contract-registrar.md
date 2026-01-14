---
order: 14
prev: false
next: false
---

# Adapter::ContractRegistrar

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L27)

Registers contract-scoped types during contract building.

Passed to `register_contract` in your adapter. Use to define
types specific to a resource contract (request/response shapes).

**Example: Register request body object**

```ruby
def register_contract(registrar, schema_class, actions)
  registrar.object :user_input do
    string :name
    string :email
  end
end
```

**Example: Define action contracts**

```ruby
def register_contract(registrar, schema_class, actions)
  actions.each do |name, action|
    registrar.action(name) do
      # ...
    end
  end
end
```

## Instance Methods

### #action

`#action(name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L53)

Defines an action. Multiple calls to the same action merge definitions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |
| `replace` | `Boolean` | replace existing definition (default: false) |

**Returns**

[Action](adapter-action) — the action definition

---

### #api_registrar

`#api_registrar`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L110)

Returns a registrar for API-level types.
Use this to define or resolve types at the API scope.

**Returns**

[Adapter::APIRegistrar](adapter-api-registrar) — the API registrar

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

---

### #find_contract_for_schema

`#find_contract_for_schema(schema_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L81)

Finds the contract class for an associated schema.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |

**Returns**

[Contract::Base](contract-base), `nil`

---

### #import

`#import(type_name, from:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L62)

Imports a type from another contract or the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | the type to import |
| `from` | `Class` | a [Contract::Base](contract-base) subclass |

---

### #imports

`#imports`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L92)

The hash of imported types.

**Returns**

`Hash` — imported types

---

### #object

`#object(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L32)

Defines a named object type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the object name |

---

### #scoped_enum_name

`#scoped_enum_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L75)

The fully qualified name for an enum in this contract's scope.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the local enum name |

**Returns**

`Symbol` — the scoped name

---

### #scoped_type_name

`#scoped_type_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L69)

The fully qualified name for a type in this contract's scope.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the local type name |

**Returns**

`Symbol` — the scoped name

---

### #union

`#union(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/contract_registrar.rb#L46)

Defines a union type scoped to this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

---
