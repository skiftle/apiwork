---
order: 1
---

# API

## Class Methods

### .all()

---

### .draw(path, &block)

Defines a new API at the given path.

This is the main entry point for creating an Apiwork API.
The block receives an API recorder for defining resources,
types, and configuration.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `String` | the mount path for this API (e.g. '/api/v1') |

**Returns**

`Class` — the created API class (subclass of API::Base)

**Example: Basic API**

```ruby
Apiwork::API.draw '/api/v1' do
  resources :users
  resources :posts
end
```

**Example: With configuration**

```ruby
Apiwork::API.draw '/api/v1' do
  key_format :camel
  pagination :offset, default_limit: 25
  resources :invoices
end
```

---

### .find(path)

---

### .introspect(path, locale: = nil)

DOCUMENTATION

---

### .reset!()

DOCUMENTATION

---
