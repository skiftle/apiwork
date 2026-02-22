---
order: 19
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L56)

Whether this scope includes the given action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The action name. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L101)

The associations for this scope.

**Returns**

Hash{Symbol =&gt; [Representation::Association](/reference/apiwork/representation/association)}

---

### #attributes

`#attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L101)

The attributes for this scope.

**Returns**

Hash{Symbol =&gt; [Representation::Attribute](/reference/apiwork/representation/attribute)}

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L64)

The filterable attributes for this scope.

**Returns**

Array&lt;[Representation::Attribute](/reference/apiwork/representation/attribute)&gt;

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L101)

The root key for this scope.

**Returns**

[Representation::RootKey](/reference/apiwork/representation/root-key)

---

### #sortable_attributes

`#sortable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L72)

The sortable attributes for this scope.

**Returns**

Array&lt;[Representation::Attribute](/reference/apiwork/representation/attribute)&gt;

---

### #writable_attributes

`#writable_attributes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/contract/scope.rb#L80)

The writable attributes for this scope.

**Returns**

Array&lt;[Representation::Attribute](/reference/apiwork/representation/attribute)&gt;

---
