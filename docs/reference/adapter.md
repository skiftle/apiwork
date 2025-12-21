---
order: 3
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L5)

## Class Methods

### .register(klass)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L14)

Registers an adapter.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | the adapter class (subclass of Adapter::Base with adapter_name) |

**Example**

```ruby
Apiwork::Adapter.register(JsonApiAdapter)
```

---

### .reset!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L35)

Clears all registered adapters. Intended for test cleanup.

**Example**

```ruby
Apiwork::Adapter.reset!
```

---
