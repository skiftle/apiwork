---
order: 32
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

[RootKey](/reference/representation/root-key) — the resource root key for response wrapping

---
