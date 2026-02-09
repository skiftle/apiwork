---
order: 2
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L19)

Base class for API definitions.

Created via [API.define](/reference/introspection/api/#define). Configure resources, types, enums,
adapters, and exports. Each API is mounted at a unique path.

**Example: Define an API**

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel

  resources :invoices do
    resources :items
  end
end
```

## Class Methods

### .adapter

`.adapter(name = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L132)

Sets or gets the adapter for this API.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol`, `nil` | `nil` |  |

**Returns**

[Adapter::Base](/reference/adapter/base), `nil`

**Yields** [Configuration](/reference/configuration/)

**Example**

```ruby
adapter do
  pagination do
    default_size 25
  end
end
```

---

### .concern

`.concern(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L469)

Defines a reusable concern for resources.

Concerns are reusable blocks of resource configuration that can
be included in multiple resources via the `concerns` option.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | concern name |

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
concern :archivable do
  member do
    post :archive
    post :unarchive
  end
end

resources :posts, concerns: [:archivable]
```

**Example: yield style**

```ruby
concern :archivable do |resource|
  resource.member do |member|
    member.post :archive
    member.post :unarchive
  end
end

resources :posts, concerns: [:archivable]
```

---

### .enum

`.enum(name, values: nil, scope: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L205)

Defines a reusable enumeration type.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  |  |
| `values` | `Array<String>`, `nil` | `nil` |  |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` |  |
| `description` | `String`, `nil` | `nil` |  |
| `example` | `String`, `nil` | `nil` |  |
| `deprecated` | `Boolean` | `false` |  |

**Returns**

`void`

**Example**

```ruby
enum :status, values: %w[draft sent paid]
```

---

### .export

`.export(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L92)

Enables an export for this API.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | :openapi, :typescript, or :zod |

**Returns**

`void`

**Yields** [Configuration](/reference/configuration/)

**Example**

```ruby
export :openapi
export :typescript do
  endpoint do
    mode :always
  end
end
```

---

### .info

`.info(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L314)

The info for this API.

**Returns**

[Info](/reference/api/info/), `nil`

**Yields** [Info](/reference/api/info/)

**Example: instance_eval style**

```ruby
info do
  title 'My API'
  version '1.0.0'
end
```

**Example: yield style**

```ruby
info do |info|
  info.title 'My API'
  info.version '1.0.0'
end
```

---

### .key_format

`.key_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L50)

Transforms request and response keys.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `format` | `Symbol<:keep, :camel, :underscore, :kebab>`, `nil` | `nil` |  |

**Returns**

`Symbol`, `nil`

**Example**

```ruby
key_format :camel
```

---

### .object

`.object(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false, representation_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L169)

Defines a reusable object type.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  |  |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` |  |
| `description` | `String`, `nil` | `nil` |  |
| `example` | `Object`, `nil` | `nil` |  |
| `format` | `String`, `nil` | `nil` |  |
| `deprecated` | `Boolean` | `false` |  |
| `representation_class` | `Class<Representation::Base>`, `nil` | `nil` |  |

**Returns**

`void`

**Yields** [API::Object](/reference/api/object)

**Example**

```ruby
object :item do
  string :description
  decimal :amount
end
```

---

### .path

`.path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L31)

The path for this API.

**Returns**

`String`

---

### .path_format

`.path_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L68)

Transforms resource and action names in URL paths.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `format` | `Symbol<:keep, :kebab, :camel, :underscore>`, `nil` | `nil` |  |

**Returns**

`Symbol`, `nil`

**Example**

```ruby
path_format :kebab
```

---

### .raises

`.raises(*error_code_keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L277)

API-wide error codes.

Included in generated specs (OpenAPI, etc.) as possible error responses.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `error_code_keys` | `Array<Symbol>` |  | registered error code keys |

**Returns**

`Array<Symbol>`

**Example**

```ruby
raises :unauthorized, :forbidden, :not_found
api_class.raises  # => [:unauthorized, :forbidden, :not_found]
```

---

### .resource

`.resource(name, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L411)

Defines a singular resource (no index action, no :id in URL).

Useful for resources where only one instance exists,
like user profile or application settings.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | resource name (singular) |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | concerns to include |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | route constraints (regex, lambdas) |
| `contract` | `String`, `nil` | `nil` | custom contract path |
| `controller` | `String`, `nil` | `nil` | custom controller path |
| `defaults` | `Hash`, `nil` | `nil` | default parameters for routes |
| `except` | `Array<Symbol>`, `nil` | `nil` | exclude specific CRUD actions |
| `only` | `Array<Symbol>`, `nil` | `nil` | limit to specific CRUD actions |
| `param` | `Symbol`, `nil` | `nil` | custom parameter name for ID |
| `path` | `String`, `nil` | `nil` | custom URL path segment |

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
resource :profile do
  resources :settings
end
```

**Example: yield style**

```ruby
resource :profile do |resource|
  resource.resources :settings
end
```

---

### .resources

`.resources(name, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L354)

Defines a RESTful resource with standard CRUD actions.

This is the main method for declaring API endpoints. Creates
routes for index, show, create, update, destroy actions.
Nested resources and custom actions can be defined in the block.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | resource name (plural) |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | concerns to include |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | route constraints (regex, lambdas) |
| `contract` | `String`, `nil` | `nil` | custom contract path |
| `controller` | `String`, `nil` | `nil` | custom controller path |
| `defaults` | `Hash`, `nil` | `nil` | default parameters for routes |
| `except` | `Array<Symbol>`, `nil` | `nil` | exclude specific CRUD actions |
| `only` | `Array<Symbol>`, `nil` | `nil` | limit to specific CRUD actions |
| `param` | `Symbol`, `nil` | `nil` | custom parameter name for ID |
| `path` | `String`, `nil` | `nil` | custom URL path segment |

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
resources :invoices do
  member { post :archive }
  resources :items
end
```

**Example: yield style**

```ruby
resources :invoices do |resource|
  resource.member { |member| member.post :archive }
  resource.resources :items
end
```

---

### .union

`.union(name, discriminator: nil, scope: nil, description: nil, deprecated: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L244)

Defines a discriminated union type.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  |  |
| `discriminator` | `Symbol`, `nil` | `nil` |  |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` |  |
| `description` | `String`, `nil` | `nil` |  |
| `deprecated` | `Boolean` | `false` |  |

**Returns**

`void`

**Yields** [API::Union](/reference/api/union)

**Example**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
end
```

---

### .with_options

`.with_options(options = {}, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L496)

Applies options to all nested resource definitions.

Useful for applying common configuration to a group of resources.
Accepts the same options as [#resources](#resources): only, except, defaults,
constraints, controller, param, path.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `options` | `Hash`, `nil` | `nil` | options to apply to nested resources |

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
with_options only: [:index, :show] do
  resources :reports
  resources :analytics
end
```

**Example: yield style**

```ruby
with_options only: [:index, :show] do |resource|
  resource.resources :reports
  resource.resources :analytics
end
```

---
