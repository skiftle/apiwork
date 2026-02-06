---
order: 10
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L5)

## Modules

- [Base](./base)
- [Builder](./builder/)
- [Capability](./capability/)
- [Serializer](./serializer/)
- [Wrapper](./wrapper/)

## Class Methods

### .find

`.find(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L33)

Finds an adapter by name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the adapter name |

**Returns**

[Adapter::Base](/reference/adapter/base), `nil` — the adapter class or nil if not found

**Example**

```ruby
Apiwork::Adapter.find(:standard)
```

---

### .find!

`.find!(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L33)

Finds an adapter by name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the adapter name |

**Returns**

[Adapter::Base](/reference/adapter/base) — the adapter class

**Example**

```ruby
Apiwork::Adapter.find!(:standard)
```

---

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L33)

Registers an adapter.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | an [Adapter::Base](/reference/adapter/base) subclass with adapter_name set |

**See also**

- [Adapter::Base](/reference/adapter/base)

**Example**

```ruby
Apiwork::Adapter.register(JSONAPIAdapter)
```

---
