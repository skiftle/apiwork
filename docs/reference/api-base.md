---
order: 2
prev: false
next: false
---

# API::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L6)

## Class Methods

### .adapter

`.adapter(name = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L201)

Configures the adapter for this API.

Adapters control serialization, pagination, filtering, and response
formatting. Without arguments, uses the built-in :apiwork adapter.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | adapter name (:apiwork, or a registered custom adapter) |

**Example: Use a custom adapter**

```ruby
Apiwork::API.define '/api/v1' do
  adapter :my_adapter
end
```

**Example: Configure pagination**

```ruby
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      strategy :offset
      default_size 25
      max_size 100
    end
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L279)

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

**Example**

```ruby
enum :status, values: %w[draft published archived]

# Later in contract:
param :status, enum: :status
```

---

### .info

`.info(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L356)

Defines information about this API.

Used to set title, version, contact, license,
and other API information for generated specs.

**Example**

```ruby
Apiwork::API.define '/api/v1' do
  info do
    title 'My API'
    version '1.0.0'
    contact do
      name 'Support'
      email 'support@example.com'
    end
  end
end
```

---

### .key_format

`.key_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L46)

Sets the key format for request/response transformation.

Controls how JSON keys are transformed between client and server.
Useful for JavaScript clients that prefer camelCase.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | `Symbol` | :keep (no transform), :camel (to/from camelCase), :underscore |

**Returns**

`Symbol` — the current key format

**Example: camelCase for JavaScript clients**

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel
  # { firstName: 'John' } ↔ { first_name: 'John' }
end
```

---

### .path_format

`.path_format(format = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L70)

Sets the path format for URL path segments.

Controls how resource names are transformed into URL paths.
Does not affect payload keys or internal identifiers.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | `Symbol` | :keep (no transform), :kebab (kebab-case), :camel (camelCase) |

**Returns**

`Symbol` — the current path format

**Example: kebab-case paths for REST conventions**

```ruby
Apiwork::API.define '/api/v1' do
  path_format :kebab
  resources :recurring_invoices
  # Routes: GET /api/v1/recurring-invoices
end
```

---

### .raises

`.raises(*error_code_keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L160)

Declares error codes that any action in this API may raise.

These are included in generated specs (OpenAPI, etc.) as possible
error responses. Use `raises` in action definitions for action-specific errors.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error_code_keys` | `Array<Symbol>` | registered error code keys |

**Example: Common API-wide errors**

```ruby
Apiwork::API.define '/api/v1' do
  raises :unauthorized, :forbidden, :not_found
end
```

---

### .resource

`.resource(name, concerns: nil, contract: nil, controller: nil, except: nil, only: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L428)

Defines a singular resource (no index action, no :id in URL).

Useful for resources where only one instance exists,
like user profile or application settings.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (singular) |
| `concerns` | `Array<Symbol>` | concerns to include |
| `contract` | `String` | custom contract path |
| `controller` | `String` | custom controller path |
| `except` | `Array<Symbol>` | exclude specific CRUD actions |
| `only` | `Array<Symbol>` | limit to specific CRUD actions |
| `path` | `String` | custom URL path segment |

**Example**

```ruby
Apiwork::API.define '/api/v1' do
  resource :profile
  # Routes: GET /profile, PATCH /profile (no index, no :id)
end
```

---

### .resources

`.resources(name, concerns: nil, contract: nil, controller: nil, except: nil, only: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L388)

Defines a RESTful resource with standard CRUD actions.

This is the main method for declaring API endpoints. Creates
routes for index, show, create, update, destroy actions.
Nested resources and custom actions can be defined in the block.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (plural) |
| `concerns` | `Array<Symbol>` | concerns to include |
| `contract` | `String` | custom contract path |
| `controller` | `String` | custom controller path |
| `except` | `Array<Symbol>` | exclude specific CRUD actions |
| `only` | `Array<Symbol>` | limit to specific CRUD actions |
| `path` | `String` | custom URL path segment |

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
  resources :line_items
end
```

---

### .spec

`.spec(name, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L116)

Enables a spec generator for this API.

Specs generate client code and documentation from your contracts.
Available specs: :openapi, :typescript, :zod, :introspection.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | spec name to enable |

**Example: Enable OpenAPI spec**

```ruby
Apiwork::API.define '/api/v1' do
  spec :openapi
end
```

**Example: With custom path**

```ruby
spec :typescript do
  path '/types.ts'
end
```

---

### .type

`.type(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false, schema_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L241)

Defines a reusable custom type (object shape).

Custom types can be referenced by name in `param` definitions.
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

**Example: Global type**

```ruby
type :address do
  param :street, type: :string
  param :city, type: :string
  param :zip, type: :string
end
```

**Example: Using in a contract**

```ruby
param :shipping_address, type: :address
```

---

### .union

`.union(name, discriminator: nil, scope: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L317)

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
  variant type: :card, tag: 'card' do
    param :last_four, type: :string
  end
  variant type: :bank, tag: 'bank' do
    param :account_number, type: :string
  end
end
```

---

### .with_options

`.with_options(options = {}, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L488)

Applies options to all nested resource definitions.

Useful for applying common configuration to a group of resources.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options` | `Hash` | options to apply to nested resources |

**Example: Namespace resources**

```ruby
Apiwork::API.define '/api/v1' do
  with_options namespace: :admin do
    resources :users
    resources :settings
  end
end
```

---
