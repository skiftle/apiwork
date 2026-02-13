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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L178)

Sets or configures the adapter for this API.

Without arguments, returns the adapter instance. With a block, configures the current adapter.
Without a name, the built-in `:standard` adapter is used.

Custom adapters must be registered via [Adapter.register](/reference/adapter/#register) and referenced by their `adapter_name`.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol`, `nil` | `nil` | A registered adapter name matching `adapter_name` in the adapter class. |

</div>

**Returns**

[Adapter::Base](/reference/adapter/base), `void` — the adapter instance when called without block

**Yields** [Configuration](/reference/configuration/)

**See also**

- [Adapter.register](/reference/adapter/#register)

**Example: Configure the default :standard adapter**

```ruby
adapter do
  pagination do
    default_size 25
    max_size 100
  end
end
```

**Example: Use a registered custom adapter**

```ruby
adapter :jsonapi
```

**Example: Use and configure a custom adapter**

```ruby
adapter :jsonapi do
  pagination do
    strategy :cursor
  end
end
```

---

### .base_path

`.base_path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L33)

The base path for this API.

**Returns**

`String`

---

### .concern

`.concern(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L585)

Defines a reusable concern for resources.

Concerns are reusable blocks of resource configuration that can
be included in multiple resources via the `concerns` option.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The concern name. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L290)

Defines a reusable enumeration type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The enum name. |
| `values` | `Array<String>`, `nil` | `nil` | The allowed values. |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` | The contract scope for type prefixing. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example. Metadata included in exports. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |

</div>

**Returns**

`void`

**Example**

```ruby
enum :status, values: %w[draft sent paid]
```

---

### .export

`.export(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L118)

Enables an export for this API.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The registered export name. Built-in: :openapi, :typescript, :zod. |

</div>

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

### .fragment

`.fragment(name, scope: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L261)

Defines a fragment type for composition.

Fragments are only available for merging into other types and never appear as standalone types. Use
fragments to define reusable field groups.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The fragment name. |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` | The contract scope for type prefixing. |

</div>

**Returns**

`void`

**Yields** [API::Object](/reference/api/object)

**Example: Reusable timestamps**

```ruby
fragment :timestamps do
  datetime :created_at
  datetime :updated_at
end

object :invoice do
  merge :timestamps
  string :number
end
```

---

### .info

`.info(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L409)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L64)

Configures key transformation for this API.

Transforms JSON keys in request bodies, response bodies, and query parameters. Incoming requests are
normalized to underscore internally, so controllers always receive `params[:user_name]` regardless of
format.

With `:camel`, `user_name` becomes `userName`. With `:pascal`, `user_name` becomes `UserName`.
With `:kebab`, `user_name` becomes `user-name`.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `format` | `Symbol<:camel, :kebab, :keep, :pascal, :underscore>`, `nil` | `nil` | The key format. Default is `:keep`. |

</div>

**Returns**

`Symbol`, `nil`

**Example: camelCase keys**

```ruby
key_format :camel

# Client sends: { "userName": "alice" }
# Controller receives: params[:user_name]
# Response: { "userName": "alice", "createdAt": "2024-01-01" }
```

---

### .object

`.object(name, deprecated: false, description: nil, example: nil, scope: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L219)

Defines a reusable object type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The object name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` | The contract scope for type prefixing. |

</div>

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

### .path_format

`.path_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L94)

Configures URL path transformation for this API.

Transforms URL path segments: base path, resource paths, action paths, and explicit `path:` options.
Path parameters like `:id` and `:user_id` are not transformed. Controllers and params remain underscore
internally.

With `:kebab`, `/api/user_profiles/:id` becomes `/api/user-profiles/:id`.
With `:pascal`, `/api/user_profiles/:id` becomes `/api/UserProfiles/:id`.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `format` | `Symbol<:camel, :kebab, :keep, :pascal, :underscore>`, `nil` | `nil` | The path format. Default is `:keep`. |

</div>

**Returns**

`Symbol`, `nil`

**Example: kebab-case paths**

```ruby
path_format :kebab

resources :user_profiles
# URL: /user-profiles/:id
# Controller: UserProfilesController
# Params: params[:user_profile]
```

---

### .raises

`.raises(*error_code_keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L372)

API-wide error codes.

Included in generated specs (OpenAPI, etc.) as possible error responses.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`error_code_keys`** | `Array<Symbol>` |  | The registered error code keys. |

</div>

**Returns**

`Array<Symbol>`

**Example**

```ruby
raises :unauthorized, :forbidden, :not_found
api_class.raises # => [:unauthorized, :forbidden, :not_found]
```

---

### .resource

`.resource(name, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L526)

Defines a singular resource (no index action, no :id in URL).

Useful for resources where only one instance exists,
like user profile or application settings.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The resource name (singular). |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | The concerns to include. |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | The route constraints (regex, lambdas). |
| `contract` | `String`, `nil` | `nil` | The custom contract path. |
| `controller` | `String`, `nil` | `nil` | The custom controller path. |
| `defaults` | `Hash`, `nil` | `nil` | The default parameters for routes. |
| `except` | `Array<Symbol>`, `nil` | `nil` | The CRUD actions to exclude. |
| `only` | `Array<Symbol>`, `nil` | `nil` | The CRUD actions to include. |
| `param` | `Symbol`, `nil` | `nil` | The custom parameter name for ID. |
| `path` | `String`, `nil` | `nil` | The custom URL path segment. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L459)

Defines a RESTful resource with standard CRUD actions.

This is the main method for declaring API endpoints. Creates
routes for index, show, create, update, destroy actions.
Nested resources and custom actions can be defined in the block.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The resource name (plural). |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | The concerns to include. |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | The route constraints (regex, lambdas). |
| `contract` | `String`, `nil` | `nil` | The custom contract path. |
| `controller` | `String`, `nil` | `nil` | The custom controller path. |
| `defaults` | `Hash`, `nil` | `nil` | The default parameters for routes. |
| `except` | `Array<Symbol>`, `nil` | `nil` | The CRUD actions to exclude. |
| `only` | `Array<Symbol>`, `nil` | `nil` | The CRUD actions to include. |
| `param` | `Symbol`, `nil` | `nil` | The custom parameter name for ID. |
| `path` | `String`, `nil` | `nil` | The custom URL path segment. |

</div>

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

`.union(name, deprecated: false, description: nil, discriminator: nil, example: nil, scope: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L336)

Defines a discriminated union type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The union name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `scope` | `Class<Contract::Base>`, `nil` | `nil` | The contract scope for type prefixing. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L613)

Applies options to all nested resource definitions.

Useful for applying common configuration to a group of resources.
Accepts the same options as [#resources](#resources): only, except, defaults,
constraints, controller, param, path.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `options` | `Hash` | `{}` | The options to apply to nested resources. |

</div>

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
