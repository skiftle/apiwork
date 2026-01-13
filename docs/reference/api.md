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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L55)

Defines a new API at the given path.

This is the main entry point for creating an Apiwork API.
The block receives an API recorder for defining resources,
types, and configuration.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `String` | the mount path for this API (e.g. '/api/v1') |

**Returns**

[API::Base](api-base)

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

### .find

`.find(path)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L25)

Finds an API by its mount path.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `String` | the API mount path |

**Returns**

[API::Base](api-base), `nil` — the API class or nil if not found

**Example**

```ruby
Apiwork::API.find('/api/v1')
```

---

### .find!

`.find!(path)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L25)

Finds an API by its mount path.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `String` | the API mount path |

**Returns**

[API::Base](api-base) — the API class

**Example**

```ruby
Apiwork::API.find!('/api/v1')
```

---

### .introspect

`.introspect(path, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L73)

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
