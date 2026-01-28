---
order: 14
prev: false
next: false
---

# Adapter::Capability::Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L12)

Base class for capability Contract phase.

Contract phase runs once per bound contract at registration time.
Use it to generate contract-specific types based on the representation.

## Instance Methods

### #action

`#action(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L25)

Defines request/response for an action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |

**Returns**

`void`

---

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L15)

**Returns**

`Array<Symbol>` — actions available for this contract

---

### #api_class

`#api_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L95)

Returns the API class for this contract.

**Returns**

`Class` — the API class

---

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L120)

Builds contract-level types for this capability.

Override this method to generate types based on the representation.

**Returns**

`void`

---

### #enum

`#enum(name, values:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L32)

Defines an enum type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |
| `values` | `Array<String>` | allowed values |

**Returns**

`void`

---

### #enum?

`#enum?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L39)

Checks if an enum is registered.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Boolean` — true if enum exists

---

### #find_contract_for_representation

`#find_contract_for_representation(representation_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L84)

Finds the contract class for a representation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `representation_class` | `Class` | the representation class |

**Returns**

`Class`, `nil` — the contract class

---

### #import

`#import(name, from:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L45)

Imports a type from API-level registry.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the local type name |
| `from` | `Symbol` | the API-level type name |

**Returns**

`void`

---

### #object

`#object(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L52)

Defines a named object type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the object name |

**Returns**

`void`

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L19)

**Returns**

[Configuration](configuration) — capability options

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L23)

**Returns**

`Class` — the representation class for this contract

---

### #scoped_enum_name

`#scoped_enum_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L72)

Returns the scoped name for an enum.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the base enum name |

**Returns**

`Symbol` — the scoped enum name

---

### #scoped_type_name

`#scoped_type_name(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L78)

Returns the scoped name for a type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the base type name |

**Returns**

`Symbol` — the scoped type name

---

### #type?

`#type?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L59)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L65)

Defines a union type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

**Returns**

`void`

---
