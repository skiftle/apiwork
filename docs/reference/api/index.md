---
order: 1
prev: false
next: false
---

# API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L6)

Namespace for API definitions and the API registry.

## Modules

- [Base](./base)
- [Element](./element)
- [Info](./info/)
- [Object](./object)
- [Resource](./resource)
- [Union](./union)

## Class Methods

### .define

`.define(path, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L58)

Defines a new API at the given path.

This is the main entry point for creating an Apiwork API.
The block receives an API recorder for defining resources,
types, and configuration.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`path`** | `String` |  | the API path |

</div>

**Returns**

Class&lt;[API::Base](/reference/api/base)&gt;

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L26)

Finds an API by path.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`path`** | `String` |  | the API path |

</div>

**Returns**

Class&lt;[API::Base](/reference/api/base)&gt;, `nil`

**See also**

- [.find!](#find!)

**Example**

```ruby
Apiwork::API.find('/api/v1')
```

---

### .find!

`.find!(path)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L26)

Finds an API by path.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`path`** | `String` |  | the API path |

</div>

**Returns**

Class&lt;[API::Base](/reference/api/base)&gt;

**See also**

- [.find](#find)

**Example**

```ruby
Apiwork::API.find!('/api/v1')
```

---

### .introspect

`.introspect(path, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L76)

The introspection data for an API.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`path`** | `String` |  | the API path |
| `locale` | `Symbol`, `nil` | `nil` | the locale for descriptions |

</div>

**Returns**

[Introspection::API](/reference/introspection/api/)

**Example**

```ruby
Apiwork::API.introspect('/api/v1')
```

---
