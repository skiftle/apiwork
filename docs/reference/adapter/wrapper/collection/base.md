---
order: 27
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L28)

Base class for collection response wrappers.

Collection wrappers structure responses for index actions that return
multiple records. Extend this class to customize how collections are
wrapped in your API responses.

**Example: Custom collection wrapper**

```ruby
class MyCollectionWrapper < Wrapper::Collection::Base
  shape do
    array(root_key.plural.to_sym) do |array|
      array.reference(data_type)
    end
    object?(:meta)
    merge_shape!(metadata_shapes)
  end

  def wrap
    { root_key.plural.to_sym => data, meta: meta.presence, **metadata }.compact
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L33)

**Returns**

`Hash` — custom metadata passed from the controller

---

### #metadata

`#metadata`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L37)

**Returns**

`Hash` — capability metadata (pagination, etc.)

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L41)

**Returns**

[RootKey](/reference/representation/root-key) — the resource root key for response wrapping

---

### #wrap

`#wrap`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L61)

Transforms the data into the final response format.

**Returns**

`Hash` — the wrapped response

---
