---
order: 33
prev: false
next: false
---

# Default

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/member/default.rb#L22)

Default member response wrapper.

Wraps a serialized record under a singular root key with optional meta and capability metadata.

**Example: Configuration**

```ruby
class MyAdapter < Adapter::Base
  member_wrapper Wrapper::Member::Default
end
```

**Example: Output**

```ruby
{
  "invoice": { "id": 1, "number": "INV-001" },
  "meta": { ... }
}
```

## Class Methods

### .shape

`.shape(klass_or_callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L28)

Defines the response shape for contract generation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass_or_callable` | `Class<Shape>`, `Proc`, `nil` | `nil` | A [Shape](/reference/adapter/wrapper/shape) subclass or callable. |

</div>

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
