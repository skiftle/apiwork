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

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/contract/base.rb#L48)

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

### #scope

`#scope`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/base.rb#L15)

**Returns**

[Scope](adapter-capability-api-scope) — representation and actions for this contract

---
