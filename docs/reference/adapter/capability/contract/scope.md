---
order: 18
prev: false
next: false
---

# Scope

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L12)

Scope for capability contract builders.

Provides access to the representation and actions for this contract.
Use this to query contract-specific state when building types.

## Instance Methods

### #action?

`#action?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L55)

Whether this scope has the action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the action name |

**Returns**

`Boolean`

---

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L17)

The actions for this scope.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #associations

`#associations`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L100)

The associations for this scope.

**Returns**

Hash{Symbol =&gt; [Representation::Association](/reference/representation/association)}

---

### #attributes

`#attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L100)

The attributes for this scope.

**Returns**

Hash{Symbol =&gt; [Representation::Attribute](/reference/representation/attribute)}

---

### #collection_actions

`#collection_actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L30)

The collection actions for this scope.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #crud_actions

`#crud_actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L46)

The CRUD actions for this scope.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #filterable_attributes

`#filterable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L63)

The filterable attributes for this scope.

**Returns**

Array&lt;[Representation::Attribute](/reference/representation/attribute)&gt;

---

### #member_actions

`#member_actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L38)

The member actions for this scope.

**Returns**

`Hash{Symbol => Resource::Action}`

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L100)

The root key for this scope.

**Returns**

[Representation::RootKey](/reference/representation/root-key)

---

### #sortable_attributes

`#sortable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L71)

The sortable attributes for this scope.

**Returns**

Array&lt;[Representation::Attribute](/reference/representation/attribute)&gt;

---

### #writable_attributes

`#writable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L79)

The writable attributes for this scope.

**Returns**

Array&lt;[Representation::Attribute](/reference/representation/attribute)&gt;

---
