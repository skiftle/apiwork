---
order: 14
prev: false
next: false
---

# Adapter::Capability::API::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L12)

Base class for capability API builders.

Provides access to capability options and aggregated configuration
across all representations.

## Instance Methods

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L43)

Builds API-level types.

Override this method to register shared types.

**Returns**

`void`

---

### #configured

`#configured(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L41)

Returns all unique values for a configuration key across all representations.

Use this to check which options are used by any representation
when building API-level schemas.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | the configuration key to look up |

**Returns**

`Set` — unique values from all representations

**Example: Check if any representation uses cursor pagination**

```ruby
if configured(:strategy).include?(:cursor)
  # build cursor pagination schema
end
```

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L19)

**Returns**

[Configuration](configuration) — capability options

---

### #scope

`#scope`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L15)

**Returns**

[Scope](adapter-capability-api-scope) — aggregated data across all representations

---
