---
order: 2
prev: false
next: false
---

# API::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L19)

Base class for API definitions.

Created via [API.define](introspection-api#define). Configure resources, types, enums,
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L140)

The adapter.

Defaults to `:standard` if no name is given.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | adapter name |

**Returns**

[Adapter::Base](adapter-base)

**See also**

- [Adapter::Base](adapter-base)

**Example: Configure default adapter**

```ruby
adapter do
  pagination do
    default_size 25
  end
end
```

**Example: Custom adapter**

```ruby
adapter :custom
```

**Example: Custom adapter with configuration**

```ruby
adapter :custom do
  pagination do
    default_size 25
  end
end
```

**Example: Getting**

```ruby
api_class.adapter  # => #<Apiwork::Adapter::Standard:...>
```

---

### .concern

`.concern(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L466)

Defines a reusable concern for resources.

Concerns are reusable blocks of resource configuration that can
be included in multiple resources via the `concerns` option.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | concern name |

**Example: Define and use a concern**

```ruby
Apiwork::API.define '/api/v1' do
  concern :archivable do
    member do
      post :archive
      post :unarchive
    end
  end

  resources :posts, concerns: [:archivable]
  resources :comments, concerns: [:archivable]
end
```

---

### .enum

`.enum(name, values: nil, scope: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L220)

Defines a reusable enumeration type.

Enums can be referenced by name in `param` definitions using
the `enum:` option.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | enum name for referencing |
| `values` | `Array<String>` | allowed values |
| `scope` | `Class` | a [Contract::Base](contract-base) subclass for scoping (nil for global) |
| `description` | `String` | documentation description |
| `example` | `String` | example value for docs |
| `deprecated` | `Boolean` | mark as deprecated |

**See also**

- [Contract::Base](contract-base)

**Example**

```ruby
enum :status, values: %w[draft sent paid]
```

**Example: Reference in contract**

```ruby
string :status, enum: :status
```

---

### .export

`.export(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L92)

Enables an export for this API.

Exports generate client code and documentation from your contracts.
Available exports: :openapi, :typescript, :zod.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | export name to enable |

**See also**

- [Export::Base](export-base)

**Example: Enable OpenAPI export**

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
end
```

**Example: With custom path**

```ruby
export :typescript do
  path '/types.ts'
end
```

---

### .info

`.info(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L328)

API info.

**Returns**

[Info](api-info), `nil`

**See also**

- [API::Info](api-info)

**Example**

```ruby
info do
  title 'My API'
  version '1.0.0'
end
api_class.info.title  # => "My API"
```

---

### .key_format

`.key_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L46)

The key format used for request/response transformation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | `Symbol` | :keep, :camel, :underscore, or :kebab |

**Returns**

`Symbol`

**Example**

```ruby
key_format :camel
api_class.key_format  # => :camel
```

---

### .object

`.object(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false, schema_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L178)

Defines a reusable object type (object shape).

Object types can be referenced by name in `param` definitions.
Scoped types are namespaced to a contract class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | type name for referencing |
| `scope` | `Class` | a [Contract::Base](contract-base) subclass for scoping (nil for global) |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint for docs |
| `deprecated` | `Boolean` | mark as deprecated |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass for type inference |

**See also**

- [API::Object](api-object)

**Example: Define a reusable type**

```ruby
object :item do
  string :description
  decimal :amount
end
```

**Example: Reference in contract**

```ruby
array :items do
  reference :item
end
```

---

### .path

`.path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L35)

The API mount path.

**Returns**

`String`

**Example**

```ruby
api_class.path  # => "/api/v1"
```

---

### .path_format

`.path_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L64)

The path format used for URL path segments.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | `Symbol` | :keep, :kebab, :camel, or :underscore |

**Returns**

`Symbol`

**Example**

```ruby
path_format :kebab
api_class.path_format  # => :kebab
```

---

### .raises

`.raises(*error_code_keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L296)

API-wide error codes.

Included in generated specs (OpenAPI, etc.) as possible error responses.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error_code_keys` | `Array<Symbol>` | registered error code keys |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L417)

Defines a singular resource (no index action, no :id in URL).

Useful for resources where only one instance exists,
like user profile or application settings.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (singular) |
| `concerns` | `Array<Symbol>` | concerns to include |
| `constraints` | `Hash, Proc` | route constraints (regex, lambdas) |
| `contract` | `String` | custom contract path |
| `controller` | `String` | custom controller path |
| `defaults` | `Hash` | default parameters for routes |
| `except` | `Array<Symbol>` | exclude specific CRUD actions |
| `only` | `Array<Symbol>` | limit to specific CRUD actions |
| `param` | `Symbol` | custom parameter name for ID |
| `path` | `String` | custom URL path segment |

**See also**

- [Contract::Base](contract-base)

**Example**

```ruby
Apiwork::API.define '/api/v1' do
  resource :profile
  # Routes: GET /profile, PATCH /profile (no index, no :id)
end
```

---

### .resources

`.resources(name, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L365)

Defines a RESTful resource with standard CRUD actions.

This is the main method for declaring API endpoints. Creates
routes for index, show, create, update, destroy actions.
Nested resources and custom actions can be defined in the block.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (plural) |
| `concerns` | `Array<Symbol>` | concerns to include |
| `constraints` | `Hash, Proc` | route constraints (regex, lambdas) |
| `contract` | `String` | custom contract path |
| `controller` | `String` | custom controller path |
| `defaults` | `Hash` | default parameters for routes |
| `except` | `Array<Symbol>` | exclude specific CRUD actions |
| `only` | `Array<Symbol>` | limit to specific CRUD actions |
| `param` | `Symbol` | custom parameter name for ID |
| `path` | `String` | custom URL path segment |

**See also**

- [Contract::Base](contract-base)

**Example: Basic resource**

```ruby
Apiwork::API.define '/api/v1' do
  resources :invoices
end
```

**Example: With options and nested resources**

```ruby
resources :invoices, only: [:index, :show] do
  member { post :archive }
  resources :items
end
```

---

### .union

`.union(name, discriminator: nil, scope: nil, description: nil, deprecated: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L263)

Defines a discriminated union type.

Unions allow a field to accept one of several shapes, distinguished
by a discriminator field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name for referencing |
| `scope` | `Class` | a [Contract::Base](contract-base) subclass for scoping (nil for global) |
| `discriminator` | `Symbol` | field name that identifies the variant |

**Example**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
  variant tag: 'bank' do
    object do
      string :account_number
    end
  end
end
```

---

### .with_options

`.with_options(options = {}, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L487)

Applies options to all nested resource definitions.

Useful for applying common configuration to a group of resources.
Accepts the same options as [#resources](#resources): only, except, defaults,
constraints, controller, param, path.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options` | `Hash` | options to apply to nested resources |

**Example: Read-only resources**

```ruby
Apiwork::API.define '/api/v1' do
  with_options only: [:index, :show] do
    resources :reports
    resources :analytics
  end
end
```

---
