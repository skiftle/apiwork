---
order: 12
prev: false
next: false
---

# Adapter::Capability::API::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L12)

Base class for capability API phase.

API phase runs once per API at initialization time.
Use it to register shared types used across all contracts.

## Instance Methods

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L73)

Builds API-level types for this capability.

Override this method to register shared types.

**Returns**

`void`

---

### #configured

`#configured(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L82)

Returns configured options for a specific key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | the option key |

**Returns**

`Object` — the configured value

---

### #enum

`#enum(name, values:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L21)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L28)

Checks if an enum is registered.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the enum name |

**Returns**

`Boolean` — true if enum exists

---

### #features

`#features`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L15)

**Returns**

`Features` — feature detection for the API

---

### #object

`#object(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L34)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L19)

**Returns**

[Configuration](configuration) — capability options

---

### #type?

`#type?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L41)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L54)

Defines a union type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the union name |

**Returns**

`void`

---
