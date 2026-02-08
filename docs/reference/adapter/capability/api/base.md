---
order: 15
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L12)

Base class for capability API builders.

Provides access to capability options and aggregated configuration
across all representations.

## Instance Methods

### #build

`#build`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L59)

Builds API-level types.

Override this method to register shared types.

**Returns**

`void`

---

### #configured

`#configured(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L42)

The configured values for a key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | the configuration key to look up |

**Returns**

`Set`

**Example: Check if any representation uses cursor pagination**

```ruby
if configured(:strategy).include?(:cursor)
  # build cursor pagination schema
end
```

---

### #enum

`#enum(name, values:, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L42)

**See also**

- [API::Base#enum](/reference/api/base#enum)

---

### #enum?

`#enum?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L42)

**See also**

- [API::Base#enum?](/reference/api/base#enum?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L42)

**See also**

- [API::Base#object](/reference/api/base#object)

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L23)

The options for this API.

**Returns**

[Configuration](/reference/configuration/)

---

### #scope

`#scope`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/api/base.rb#L17)

The scope for this API.

**Returns**

[Scope](/reference/adapter/capability/api/scope)

---

### #type?

`#type?(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L42)

**See also**

- [API::Base#type?](/reference/api/base#type?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/builder/api/base.rb#L42)

**See also**

- [API::Base#union](/reference/api/base#union)

---
