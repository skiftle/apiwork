---
order: 1
prev: false
next: false
---

# API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L5)

## Class Methods

### .define

`.define(path, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L30)

Defines a new API at the given path.

This is the main entry point for creating an Apiwork API.
The block receives an API recorder for defining resources,
types, and configuration.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `String` | the mount path for this API (e.g. '/api/v1') |

**Returns**

`Class` — an [API::Base](api-base) subclass

**Example: Basic API**

```ruby
Apiwork::API.define '/api/v1' do
  resources :users
  resources :posts
end
```

**Example: With configuration**

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel

  resources :invoices
end
```

---

### .introspect

`.introspect(path, locale: = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L60)

Returns introspection data for an API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `String` | the API mount path |
| `locale` | `Symbol` | optional locale for descriptions |

**Returns**

`Hash` — the introspection data

**Example**

```ruby
Apiwork::API.introspect('/api/v1')
```

---

### .reset!

`.reset!()`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L69)

Clears all registered APIs. Intended for test cleanup.

**Example**

```ruby
Apiwork::API.reset!
```

---
