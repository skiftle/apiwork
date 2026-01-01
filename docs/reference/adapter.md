---
order: 6
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L5)

## Class Methods

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L15)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L36)

Clears all registered adapters. Intended for test cleanup.

**Example**

```ruby
Apiwork::Adapter.reset!
```

---
