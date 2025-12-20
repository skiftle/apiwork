---
order: 34
prev: false
next: false
---

# Contract::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L25)

## Class Methods

### .abstract!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L25)

Marks this contract as abstract.

Abstract contracts serve as base classes for other contracts.
Use this when creating application-wide base contracts that define
shared imports or configuration. Subclasses automatically become non-abstract.

**Returns**

`void` — 

**Example: Application base contract**

```ruby
class ApplicationContract < Apiwork::Contract::Base
  abstract!
end
```

---

### .abstract?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L25)

Returns whether this contract is abstract.

**Returns**

`Boolean` — true if abstract

---

### .action(action_name, replace: = false, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L340)

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

`ActionDefinition` — the action definition

**Example: Basic CRUD action**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :show do
    request { query { param :include, type: :string, optional: true } }
    response { body { param :id } }
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

### .enum(name, values: = nil, description: = nil, example: = nil, deprecated: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L225)

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

**Example: Status enum**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  enum :status, values: %w[draft sent paid]

  action :update do
    request { body { param :status, enum: :status } }
  end
end
```

---

### .identifier(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L84)

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

`String, nil` — the scope prefix

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

### .import(contract_class, as:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L279)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.
If UserContract defines a type `:address`, importing it as `:user`
makes it available as `:user_address`.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `contract_class` | `Class` | the contract class to import from |
| `as` | `Symbol` | alias prefix for imported types |

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

### .inherited(subclass)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L57)

---

### .resolve_custom_type(type_name, visited: = Set.new)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L349)

---

### .schema!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L112)

Links this contract to its schema using naming convention.

Looks up the schema class by replacing "Contract" with "Schema"
in the class name. For example, `UserContract.schema!` finds
`UserSchema`.

Call this method to enable auto-generation of request/response
types based on the schema's attributes.

**Returns**

`Class` — the associated schema class

**Example**

```ruby
class UserContract < Apiwork::Contract::Base
  schema!  # Links to UserSchema

  action :create do
    request { body { param :name } }
    response { body { param :id } }
  end
end
```

---

### .schema?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L150)

**Returns**

`Boolean` — 

---

### .type(name, description: = nil, example: = nil, format: = nil, deprecated: = false, schema_class: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L199)

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
| `schema_class` | `Class` | associate with schema for inference |

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

### .union(name, discriminator: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L251)

Defines a discriminated union type scoped to this contract.

A union is a type that can be one of several variants,
distinguished by a discriminator field. In introspection
output, unions are namespaced with the contract's scope prefix.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name |
| `discriminator` | `Symbol` | field that identifies the variant |

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

### #initialize(query:, body:, action_name:, coerce: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L38)

**Returns**

`Base` — a new instance of Base

---

### #invalid?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L52)

**Returns**

`Boolean` — 

---

### #valid?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L47)

**Returns**

`Boolean` — 

---
