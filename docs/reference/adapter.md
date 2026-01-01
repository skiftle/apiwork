---
order: 6
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L9)

Registry for response adapters.

Adapters control serialization, pagination, filtering, and response formatting.
The built-in :standard adapter is used by default.

## Class Methods

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L19)

Registers an adapter.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | an [Adapter::Base](adapter-base) subclass with adapter_name set |

**See also**

- [Adapter::Base](adapter-base)

**Example**

```ruby
Apiwork::Adapter.register(JSONAPIAdapter)
```

---

### .reset!

`.reset!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L40)

Clears all registered adapters. Intended for test cleanup.

**Example**

```ruby
Apiwork::Adapter.reset!
```

---
