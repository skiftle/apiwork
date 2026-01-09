---
order: 9
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L5)

## Class Methods

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L14)

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
