---
order: 1
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L6)

## Class Methods

### .adapter(name = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L168)

Configures the adapter for this API.

Adapters control serialization, pagination, filtering, and response
formatting. Default adapter is :apiwork.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | adapter name (:apiwork, or custom) |

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

### .adapter_config()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .built_contracts()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .concern(name, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L374)

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

### .enum(name, values: = nil, scope: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L233)

Defines a reusable enumeration type.

Enums can be referenced by name in `param` definitions using
the `enum:` option.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | enum name for referencing |
| `values` | `Array<String>` | allowed values |
| `scope` | `Class` | contract class for scoping (nil for global) |
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

### .info(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L298)

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

### .key_format(format = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L50)

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

### .metadata()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .mount_path()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .namespaces()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .raises(*error_code_keys)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L132)

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

### .recorder()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .resource(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L349)

Defines a singular resource (no index action, no :id in URL).

Useful for resources where only one instance exists,
like user profile or application settings.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (singular) |
| `options` | `Hash` | resource options (same as resources) |

**Example**

```ruby
Apiwork::API.define '/api/v1' do
  resource :profile
  # Routes: GET /profile, PATCH /profile (no index, no :id)
end
```

---

### .resources(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L330)

Defines a RESTful resource with standard CRUD actions.

This is the main method for declaring API endpoints. Creates
routes for index, show, create, update, destroy actions.
Nested resources and custom actions can be defined in the block.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (plural) |
| `options` | `Hash` | resource options |

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

### .spec(type, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L85)

Enables a spec generator for this API.

Specs generate client code and documentation from your contracts.
Available specs: :openapi, :typescript, :zod, :introspection.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | spec type to enable |

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

### .spec_configs()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .specs()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .type(name, scope: = nil, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L209)

Defines a reusable custom type (object shape).

Custom types can be referenced by name in `param` definitions.
Scoped types are namespaced to a contract class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | type name for referencing |
| `scope` | `Class` | contract class for scoping (nil for global) |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint for docs |
| `deprecated` | `Boolean` | mark as deprecated |
| `schema_class` | `Class` | associate with a schema for type inference |

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

### .type_system()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L8)

---

### .union(name, scope: = nil, discriminator: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L259)

Defines a discriminated union type.

Unions allow a field to accept one of several shapes, distinguished
by a discriminator field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name for referencing |
| `scope` | `Class` | contract class for scoping (nil for global) |
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

### .with_options(options = {}, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/base.rb#L393)

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
