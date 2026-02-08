---
order: 16
prev: false
next: false
---

# Scope

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L12)

Aggregated scope for capability API builders.

Provides access to data collected across all representations in the API.
Use this to query API-wide state when building shared types.

## Instance Methods

### #configured

`#configured(capability, key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L55)

The configured values for a capability.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capability` | `Symbol` | the capability name |
| `key` | `Symbol` | the configuration key |

**Returns**

`Set`

---

### #filter_types

`#filter_types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L43)

Returns all filterable types across representations.

**Returns**

`Set<Symbol>`

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L43)

Returns whether any representation has filterable attributes.

**Returns**

`Boolean`

---

### #has_index_actions?

`#has_index_actions?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L22)

Returns whether any resource has index actions.

**Returns**

`Boolean`

---

### #nullable_filter_types

`#nullable_filter_types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L43)

Returns filterable types that can be null.

**Returns**

`Set<Symbol>`

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/scope.rb#L43)

Returns whether any representation has sortable attributes.

**Returns**

`Boolean`

---
