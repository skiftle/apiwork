---
order: 1
prev: false
next: false
---

# API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L4)

## Class Methods

### .all()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L41)

---

### .draw(path, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L28)

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

  resources :invoices
end
```

---

### .find(path)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L37)

---

### .introspect(path, locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L46)

DOCUMENTATION

---

### .reset!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L51)

DOCUMENTATION

---
