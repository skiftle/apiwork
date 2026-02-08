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
    merge_shape!(metadata_shapes)
  end

  def wrap
    { root_key.singular.to_sym => data, meta: meta.presence, **metadata }.compact
  end
end
```

## Class Methods

### .shape

`.shape(klass_or_callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L27)

Defines the response shape for contract generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass_or_callable` | `Class<Shape>, Proc, nil` | a Shape subclass or callable |

**Returns**

Class&lt;[Shape](/reference/adapter/wrapper/shape)&gt;, `nil`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L33)

The meta for this wrapper.

**Returns**

`Hash`

---

### #metadata

`#metadata`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L39)

The metadata for this wrapper.

**Returns**

`Hash`

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L45)

The root key for this wrapper.

**Returns**

[RootKey](/reference/representation/root-key)

---

### #wrap

`#wrap`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L63)

Transforms the data into the final response format.

**Returns**

`Hash`

---
