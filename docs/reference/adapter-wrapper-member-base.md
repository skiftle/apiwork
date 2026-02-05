---
order: 31
prev: false
next: false
---

# Adapter::Wrapper::Member::Base

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L25)

Defines the response shape for contract generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass_or_callable` | `Class, Proc, nil` | a Shape subclass or callable |

**Returns**

`Class`, `nil` — the shape class

---

## Instance Methods

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L12)

**Returns**

`Hash` — the serialized resource data

---

### #meta

`#meta`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L31)

**Returns**

`Hash` — custom metadata passed from the controller

---

### #metadata

`#metadata`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L35)

**Returns**

`Hash` — capability metadata

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/base.rb#L39)

**Returns**

[RootKey](representation-root-key) — the resource root key for response wrapping

---

### #wrap

`#wrap`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L61)

Transforms the data into the final response format.

**Returns**

`Hash` — the wrapped response

---
