---
order: 11
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L6)

Namespace for adapters and the adapter registry.

## Modules

- [Base](./base)
- [Builder](./builder/)
- [Capability](./capability/)
- [Serializer](./serializer/)
- [Wrapper](./wrapper/)

## Class Methods

### .find

`.find(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L34)

Finds an adapter by name.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the adapter name |

**Returns**

Class&lt;[Adapter::Base](/reference/adapter/base)&gt;, `nil`

**See also**

- [.find!](#find!)

**Example**

```ruby
Apiwork::Adapter.find(:standard)
```

---

### .find!

`.find!(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L34)

Finds an adapter by name.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the adapter name |

**Returns**

Class&lt;[Adapter::Base](/reference/adapter/base)&gt;

**See also**

- [.find](#find)

**Example**

```ruby
Apiwork::Adapter.find!(:standard)
```

---

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L34)

Registers an adapter.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Adapter::Base>` |  | the adapter class with adapter_name set |

**See also**

- [Adapter::Base](/reference/adapter/base)

**Example**

```ruby
Apiwork::Adapter.register(JSONAPIAdapter)
```

---
