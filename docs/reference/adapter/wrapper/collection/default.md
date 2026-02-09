---
order: 29
prev: false
next: false
---

# Default

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/default.rb#L26)

Default collection response wrapper.

Wraps serialized records under a pluralized root key with optional meta and capability metadata.

**Example: Configuration**

```ruby
class MyAdapter < Adapter::Base
  collection_wrapper Wrapper::Collection::Default
end
```

**Example: Output**

```ruby
{
  "invoices": [
    { "id": 1, "number": "INV-001" },
    { "id": 2, "number": "INV-002" }
  ],
  "meta": { ... },
  "pagination": { "current": 1, "total": 5 }
}
```

## Class Methods

### .shape

`.shape(klass_or_callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/base.rb#L27)

Defines the response shape for contract generation.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass_or_callable` | `Class<Shape>`, `Proc`, `nil` | `nil` | a Shape subclass or callable |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L35)

The meta for this wrapper.

**Returns**

`Hash`

---

### #metadata

`#metadata`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L41)

The metadata for this wrapper.

**Returns**

`Hash`

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/collection/base.rb#L47)

The root key for this wrapper.

**Returns**

[RootKey](/reference/representation/root-key)

---
