---
order: 1
prev: false
next: false
---

# API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L5)

## Modules

- [Base](./base)
- [Element](./element)
- [Info](./info/)
- [Object](./object)
- [Resource](./resource)
- [Union](./union)

## Class Methods

### .define

`.define(base_path, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L60)

Defines a new API at the given base path.

This is the main entry point for creating an Apiwork API.
The block receives an API recorder for defining resources,
types, and configuration.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`base_path`** | `String` |  | The API base path. |

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

`.find(base_path)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L27)

Finds an API by base path.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`base_path`** | `String` |  | The API base path. |

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

`.find!(base_path)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L27)

Finds an API by base path.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`base_path`** | `String` |  | The API base path. |

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

`.introspect(base_path, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api.rb#L80)

The introspection data for an API.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`base_path`** | `String` |  | The API base path. |
| `locale` | `Symbol`, `nil` | `nil` | The locale for descriptions. |

</div>

**Returns**

[Introspection::API](/reference/introspection/api/)

**Example**

```ruby
Apiwork::API.introspect('/api/v1')
```

---
