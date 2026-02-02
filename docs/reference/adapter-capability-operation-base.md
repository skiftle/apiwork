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

`.metadata_shape(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L58)

Defines metadata shape for this operation.

Pass a block or a [MetadataShape](adapter-capability-operation-metadata-shape) subclass.
Blocks are evaluated via instance_exec, providing access to
type DSL methods and capability options.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class, nil` | a MetadataShape subclass |

**Returns**

`Class`, `nil` — the metadata shape class

**Example: With block**

```ruby
metadata_shape do
  reference(:pagination, to: :offset_pagination)
end
```

**Example: With class**

```ruby
metadata_shape PaginationShape
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L96)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L108)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L133)

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
