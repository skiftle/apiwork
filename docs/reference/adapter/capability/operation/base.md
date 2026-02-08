---
order: 20
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L12)

Base class for capability Operation phase.

Operation phase runs on each request.
Use it to transform data at runtime.

## Class Methods

### .metadata_shape

`.metadata_shape(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L66)

Defines metadata shape for this operation.

Pass a block or a [MetadataShape](/reference/adapter/capability/operation/metadata-shape) subclass.
Blocks are evaluated via instance_exec, providing access to
type DSL methods and capability options.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class<MetadataShape>, nil` | the metadata shape class |

**Returns**

Class&lt;[MetadataShape](/reference/adapter/capability/operation/metadata-shape)&gt;, `nil`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L43)

The target for this operation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | :collection or :member |

**Returns**

`Symbol`, `nil`

---

## Instance Methods

### #apply

`#apply`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L104)

Applies this operation to the data.

Override this method to implement transformation logic.
Return nil if no changes are made.

**Returns**

`Result`, `nil`

---

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L17)

The data for this operation.

**Returns**

`Object`

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L23)

The options for this operation.

**Returns**

[Configuration](/reference/configuration/)

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L35)

The representation class for this operation.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L29)

The request for this operation.

**Returns**

[Request](/reference/request)

---

### #result

`#result(data: nil, includes: nil, metadata: nil, serialize_options: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L116)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/base.rb#L141)

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

`String`, `nil`

**Example**

```ruby
translate(:domain_issues, :invalid, :detail)
# Tries: apiwork.apis.billing.adapters.standard.capabilities.writing.domain_issues.invalid.detail
# Falls back to: apiwork.adapters.standard.capabilities.writing.domain_issues.invalid.detail
```

---
