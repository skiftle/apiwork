---
order: 18
prev: false
next: false
---

# Scope

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L12)

Scope for capability contract builders.

Provides access to the representation and actions linked to this contract.
Use this to query contract-specific state when building types.

## Instance Methods

### #action?

`#action?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L53)

Returns whether an action exists.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |

**Returns**

`Boolean`

---

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L15)

**Returns**

`Hash{Symbol => Resource::Action}` — actions linked to this contract

---

### #collection_actions

`#collection_actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L28)

Returns actions that operate on collections.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #crud_actions

`#crud_actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L44)

Returns CRUD actions only.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #filterable_attributes

`#filterable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L61)

Returns attributes that are filterable.

**Returns**

Array&lt;[Representation::Attribute](/reference/representation/attribute)&gt;

---

### #member_actions

`#member_actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L36)

Returns actions that operate on a single resource.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #sortable_attributes

`#sortable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L69)

Returns attributes that are sortable.

**Returns**

Array&lt;[Representation::Attribute](/reference/representation/attribute)&gt;

---

### #writable_attributes

`#writable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L77)

Returns attributes that are writable.

**Returns**

Array&lt;[Representation::Attribute](/reference/representation/attribute)&gt;

---
