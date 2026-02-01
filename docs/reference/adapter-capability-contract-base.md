---
order: 16
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L27)

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

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L50)

Builds contract-level types.

Override this method to generate types based on the representation.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L26)

**Returns**

`Class` — the representation class for this contract

---
