---
order: 28
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
