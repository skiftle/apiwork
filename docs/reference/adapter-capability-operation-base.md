---
order: 18
prev: false
next: false
---

# Adapter::Capability::Operation::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L12)

Base class for capability Operation phase.

Operation phase runs on each request.
Use it to transform data at runtime.

## Class Methods

### .metadata_shape

`.metadata_shape(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L53)

Defines metadata shape for this operation.

The block is evaluated via instance_exec on a [Capability::Shape](adapter-capability-shape),
providing access to type DSL methods and capability options.

**Returns**

`Proc`, `nil` — the metadata shape block

**Example**

```ruby
metadata_shape do
  reference(:pagination, to: :offset_pagination)
end
```

---

### .target

`.target(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L35)

Sets the target for this operation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | :collection or :member |

**Returns**

`Symbol`, `nil` — the current target

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

[Request](request) — the current request

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

### #translate

`#translate(*segments, default: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L111)

Translates a key using the adapter's i18n convention.

Lookup order:
1. `apiwork.apis.&lt;locale_key&gt;.adapters.&lt;adapter_name&gt;.capabilities.&lt;capability_name&gt;.&lt;segments&gt;`
2. `apiwork.adapters.&lt;adapter_name&gt;.capabilities.&lt;capability_name&gt;.&lt;segments&gt;`
3. Provided default

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `segments` | `Array<Symbol, String>` | key path segments |
| `default` | `String, nil` | fallback value if no translation found |

**Returns**

`String`, `nil` — the translated string or default

**Example**

```ruby
translate(:domain_issues, :invalid, :detail)
# Tries: apiwork.apis.billing.adapters.standard.capabilities.writing.domain_issues.invalid.detail
# Falls back to: apiwork.adapters.standard.capabilities.writing.domain_issues.invalid.detail
```

---
