---
order: 16
prev: false
next: false
---

# Adapter::Capability::Operation::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L12)

Base class for capability Operation phase.

Operation phase runs on each request.
Use it to transform data at runtime.

## Class Methods

### .metadata

`.metadata(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L54)

Defines metadata shape for this operation.

The block receives a shape builder with access to type DSL methods
and capability options.

**Returns**

`Proc`, `nil` — the metadata block

**Example**

```ruby
metadata do |shape|
  shape.reference(:pagination, to: :offset_pagination)
end
```

---

### .scope

`.scope(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L35)

Sets the scope for this operation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | :collection or :member |

**Returns**

`Symbol`, `nil` — the current scope

---

## Instance Methods

### #apply

`#apply`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L74)

Applies this operation to the data.

Override this method to implement transformation logic.
Return nil if no changes are made.

**Returns**

`Result`, `nil` — the result or nil for no changes

---

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L15)

**Returns**

`Object` — the data to transform (relation or record)

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L19)

**Returns**

[Configuration](configuration) — capability options

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L27)

**Returns**

`Class` — the representation class for this request

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L23)

**Returns**

[Request](adapter-request) — the current request

---

### #result

`#result(data: nil, includes: nil, metadata: nil, serialize_options: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L86)

Creates a result object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `Object, nil` | transformed data |
| `metadata` | `Hash, nil` | metadata to add to response |
| `includes` | `Array, nil` | associations to preload |
| `serialize_options` | `Hash, nil` | options for serialization |

**Returns**

`Result`

---
