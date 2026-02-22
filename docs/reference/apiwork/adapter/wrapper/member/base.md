---
order: 32
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L26)

Base class for member response wrappers.

Member wrappers structure responses for show, create, and update actions
that return a single record. Extend this class to customize how individual
resources are wrapped in your API responses.

**Example: Custom member wrapper**

```ruby
class MyMemberWrapper < Wrapper::Member::Base
  shape do
    reference(root_key.singular.to_sym, to: data_type)
    object?(:meta)
    metadata_type_names.each { |type_name| merge(type_name) }
  end

  def wrap
    { root_key.singular.to_sym => data, meta: meta.presence, **metadata }.compact
  end
end
```

## Class Methods

### .shape

`.shape(klass_or_callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L24)

Defines the response shape for contract generation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass_or_callable` | `Class<Shape>`, `Proc`, `nil` | `nil` | A [Shape](/reference/apiwork/adapter/wrapper/shape) subclass or callable. |

</div>

**Returns**

Class&lt;[Shape](/reference/apiwork/adapter/wrapper/shape)&gt;, `nil`

---

## Instance Methods

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L14)

The data for this wrapper.

**Returns**

`Hash`

---

### #meta

`#meta`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L44)

The meta for this wrapper.

**Returns**

`Hash`

---

### #metadata

`#metadata`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L44)

The metadata for this wrapper.

**Returns**

`Hash`

---

### #wrap

`#wrap`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L64)

Transforms the data into the final response format.

**Returns**

`Hash`

---
