---
order: 14
prev: false
next: false
---

# Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Base class for API contracts.

Contracts define request/response structure for a resource.
Link to a schema with [.schema!](#schema!) for automatic serialization.
Define actions with [.action](#action) for custom validation and response shapes.

**Example: Basic contract**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema! InvoiceSchema
end
```

**Example: With custom actions**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema! InvoiceSchema

  action :create do
    request do
      body do
        param :title, type: :string
        param :amount, type: :decimal, min: 0
      end
    end
  end
end
```

## Class Methods

### .abstract!

`.abstract!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Marks this contract as abstract.

Abstract contracts serve as base classes for other contracts.
Use this when creating application-wide base contracts that define
shared imports or configuration. Subclasses automatically become non-abstract.

**Returns**

`void`

**Example: Application base contract**

```ruby
class ApplicationContract < Apiwork::Contract::Base
  abstract!
end
```

---

### .abstract?

`.abstract?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Returns whether this contract is abstract.

**Returns**

`Boolean` — true if abstract

---

### .action

`.action(action_name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L422)

Defines an action (endpoint) for this contract.

Actions describe the request/response contract for a specific
controller action. Use the block to define request parameters,
response format, and documentation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_name` | `Symbol` | the controller action name (:index, :show, :create, :update, :destroy, or custom) |
| `replace` | `Boolean` | replace existing action definition (default: false) |

**Returns**

[ActionDefinition](contract-action-definition) — the action definition

**See also**

- [Contract::ActionDefinition](contract-action-definition)

**Example: Basic CRUD action**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :show do
    request do
      query do
        param :include, type: :string, optional: true
      end
    end
    response do
      body do
        param :id
      end
    end
  end
end
```

**Example: Action with full request/response**

```ruby
action :create do
  summary 'Create a new invoice'
  tags :billing

  request do
    body do
      param :customer_id, type: :integer
      param :amount, type: :decimal
    end
  end

  response do
    body do
      param :id
      param :status
    end
  end

  raises :not_found
  raises :unprocessable_entity
end
```

---

### .enum

`.enum(name, values: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L287)

Defines an enum scoped to this contract.

Enums define a set of allowed string values. In introspection
output, enums are namespaced with the contract's scope prefix.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | enum name |
| `values` | `Array<String>` | allowed string values |
| `description` | `String` | documentation description |
| `example` | `String` | example value for docs |
| `deprecated` | `Boolean` | mark as deprecated |

**See also**

- [API::Base](api-base)

**Example: Status enum**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  enum :status, values: %w[draft sent paid]

  action :update do
    request do
      body do
        param :status, enum: :status
      end
    end
  end
end
```

---

### .identifier

`.identifier(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L123)

Sets the scope prefix for contract-scoped types.

Types, enums, and unions defined in this contract are namespaced
with this prefix in introspection output. For example, a type
`:address` becomes `:invoice_address` when identifier is `:invoice`.

If not set, prefix is derived from schema's root_key or class name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, String` | scope prefix (optional) |

**Returns**

`String`, `nil` — the scope prefix

**Example: Custom scope prefix**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  identifier :billing

  type :address do
    param :street, type: :string
  end
  # In introspection: type is named :billing_address
end
```

---

### .import

`.import(contract_class, as:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L349)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.
If UserContract defines a type `:address`, importing it as `:user`
makes it available as `:user_address`.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `contract_class` | `Class` | a [Contract::Base](contract-base) subclass to import from |
| `as` | `Symbol` | alias prefix for imported types |

**See also**

- [Contract::Base](contract-base)

**Example: Import types from another contract**

```ruby
# UserContract has: type :address, enum :role
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        param :shipping, type: :user_address   # user_ prefix
        param :role, enum: :user_role          # user_ prefix
      end
    end
  end
end
```

---

### .introspect

`.introspect(expand: false, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L464)

Returns a hash representation of this contract's structure.

Includes all actions with their request/response definitions.
Useful for generating documentation or client code.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locale` | `Symbol` | optional locale for translated descriptions |
| `expand` | `Boolean` | resolve all referenced types (local, imported, global) |

**Returns**

`Hash` — contract structure with :actions key

**Example**

```ruby
InvoiceContract.introspect
# => { actions: { create: { request: {...}, response: {...} } } }
```

**Example: With all available types**

```ruby
InvoiceContract.introspect(expand: true)
# => { actions: {...}, types: { local: {...}, imported: {...}, global: {...} } }
```

---

### .schema!

`.schema!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L160)

Links this contract to its schema using naming convention.

Looks up the schema class by replacing "Contract" with "Schema"
in the class name. Both must be in the same namespace.
For example, `Api::V1::UserContract.schema!` finds `Api::V1::UserSchema`.

Call this method to enable auto-generation of request/response
types based on the schema's attributes.

**Returns**

`Class` — a [Schema::Base](schema-base) subclass

**See also**

- [Schema::Base](schema-base)

**Example**

```ruby
class Api::V1::UserContract < Apiwork::Contract::Base
  schema!  # Links to Api::V1::UserSchema

  action :create do
    request do
      body do
        param :name
      end
    end
    response do
      body do
        param :id
      end
    end
  end
end
```

---

### .type

`.type(name, description: nil, example: nil, format: nil, deprecated: false, schema_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L241)

Defines a reusable type scoped to this contract.

Types are named parameter structures that can be referenced in
param definitions. In introspection output, types are namespaced
with the contract's scope prefix (e.g., `:order_address`).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | type name |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint for docs |
| `deprecated` | `Boolean` | mark as deprecated |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass for type inference |

**See also**

- [API::Base](api-base)

**Example: Reusable address type**

```ruby
class OrderContract < Apiwork::Contract::Base
  type :address do
    param :street, type: :string
    param :city, type: :string
  end

  action :create do
    request do
      body do
        param :shipping, type: :address
        param :billing, type: :address  # Reuse same type
      end
    end
  end
end
```

---

### .union

`.union(name, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L320)

Defines a discriminated union type scoped to this contract.

A union is a type that can be one of several variants,
distinguished by a discriminator field. In introspection
output, unions are namespaced with the contract's scope prefix.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name |
| `discriminator` | `Symbol` | field that identifies the variant |

**See also**

- [API::Base](api-base)

**Example: Payment method union**

```ruby
class PaymentContract < Apiwork::Contract::Base
  union :method, discriminator: :type do
    variant tag: 'card', type: :object do
      param :last_four, type: :string
    end
    variant tag: 'bank', type: :object do
      param :account_number, type: :string
    end
  end
end
```

---

## Instance Methods

### #action_name

`#action_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L71)

**Returns**

`Symbol` — the current action name

---

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L63)

**Returns**

`Hash` — parsed and validated request body

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L91)

Returns whether the contract has validation issues.

**Returns**

`Boolean` — true if any validation issues

---

### #issues

`#issues`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L67)

**Returns**

Array&lt;[Issue](issue)&gt; — validation issues (empty if valid)

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L59)

**Returns**

`Hash` — parsed and validated query parameters

---

### #valid?

`#valid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L84)

Returns whether the contract passed validation.

**Returns**

`Boolean` — true if no validation issues

---
