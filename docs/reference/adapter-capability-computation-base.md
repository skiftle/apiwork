---
order: 13
prev: false
next: false
---

# Adapter::Capability::Computation::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L12)

Base class for capability Computation phase.

Computation phase runs on each request.
Use it to transform data at runtime.

## Class Methods

### .scope

`.scope(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L35)

Sets the scope for this computation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | :collection or :record |

**Returns**

`Symbol`, `nil` — the current scope

---

## Instance Methods

### #apply

`#apply`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L55)

Transforms data for this capability.

Override this method to implement transformation logic.
Return nil if no changes are made.

**Returns**

`ApplyResult`, `nil` — the result or nil for no changes

---

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L15)

**Returns**

`Object` — the data to transform (relation or record)

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L19)

**Returns**

[Configuration](configuration) — capability options

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L27)

**Returns**

`Class` — the representation class for this request

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L23)

**Returns**

[Request](adapter-request) — the current request

---

### #result

`#result(data: nil, document: nil, includes: nil, serialize_options: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/computation/base.rb#L67)

Creates a result object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `Object, nil` | transformed data |
| `document` | `Hash, nil` | metadata to add to response |
| `includes` | `Array, nil` | associations to preload |
| `serialize_options` | `Hash, nil` | options for serialization |

**Returns**

`ApplyResult`

---
