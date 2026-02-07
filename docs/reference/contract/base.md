---
order: 39
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L49)

Base class for API contracts.

Contracts define request/response structure for a resource.
Link to a representation with [.representation](#representation) for automatic serialization.
Define actions with [.action](#action) for custom validation and response shapes.

**Example: Basic contract**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

**Example: With custom actions**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation

  action :create do
    request do
      body do
        string :title
        decimal :amount, min: 0
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

`Boolean`

---

### .action

`.action(action_name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L355)

Defines an action on this contract.

Actions describe the request/response contract for a specific
controller action. Use the block to define request parameters,
response format, and documentation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_name` | `Symbol` | the controller action name (:index, :show, :create, :update, :destroy, or custom) |
| `replace` | `Boolean` | replace existing action definition (default: false) |

**Returns**

[Contract::Action](/reference/contract/action/)

**See also**

- [Contract::Action](/reference/contract/action/)

**Example: instance_eval style**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :show do
    request do
      query do
        string? :include
      end
    end
    response do
      body do
        uuid :id
      end
    end
  end
end
```

**Example: yield style**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :show do |action|
    action.request do |request|
      request.query do |query|
        query.string? :include
      end
    end
    action.response do |response|
      response.body do |body|
        body.uuid :id
      end
    end
  end
end
```

---

### .enum

`.enum(name, values: nil, description: nil, example: nil, deprecated: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L213)

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

- [API::Base](/reference/api/base)

**Example**

```ruby
enum(:status, values: %w[draft sent paid])
```

**Example: Reference in contract**

```ruby
string(:status, enum: :status)
```

---

### .identifier

`.identifier(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L112)

The identifier for this contract.

Types, enums, and unions defined on this contract are namespaced
with this prefix in introspection output. For example, a type
:address becomes :invoice_address when identifier is :invoice.

If not set, prefix is derived from representation's root_key or class name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, String, nil` | the scope prefix |

**Returns**

`String`, `nil`

**Example: Custom scope prefix**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  identifier :billing

  object :address do
    string :street
  end
  # In introspection: object is named :billing_address
end
```

---

### .import

`.import(contract_class, as:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L278)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.
If UserContract defines a type `:address`, importing it as `:user`
makes it available as `:user_address`.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `contract_class` | `Class<Contract::Base>` | the contract class to import from |
| `as` | `Symbol` | alias prefix for imported types |

**Returns**

`void`

**See also**

- [Contract::Base](/reference/contract/base)

**Example: Import types from another contract**

```ruby
# UserContract has: object :address, enum :role
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        reference :shipping, to: :user_address  # user_ prefix
        string :role, enum: :user_role          # user_ prefix
      end
    end
  end
end
```

---

### .introspect

`.introspect(expand: false, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L384)

The introspection data for this contract.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `locale` | `Symbol` | optional locale for translated descriptions |
| `expand` | `Boolean` | resolve all referenced types (local, imported, global) |

**Returns**

`Hash`

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

### .object

`.object(name, description: nil, example: nil, format: nil, deprecated: false, representation_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L174)

Defines a reusable object type scoped to this contract.

Objects are named parameter structures that can be referenced in
param definitions. In introspection output, objects are namespaced
with the contract's scope prefix (e.g., `:order_address`).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | object name |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint for docs |
| `deprecated` | `Boolean` | mark as deprecated |
| `representation_class` | `Class<Representation::Base>` | the representation class for type inference |

**See also**

- [API::Object](/reference/api/object)

**Example: Define a reusable type**

```ruby
object(:item) do |object|
  object.string(:description)
  object.decimal(:amount)
end
```

**Example: Reference in contract**

```ruby
array(:items) do |array|
  array.reference(:item)
end
```

---

### .representation

`.representation(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L139)

Sets the representation class for this contract.

The representation defines the attributes and associations that
are serialized in responses. Adapters use the representation to
auto-generate request/response types.

To retrieve the representation class, use [#representation_class](#representation-class) instead.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class<Representation::Base>` | the representation class |

**Returns**

`void`

**See also**

- [Representation::Base](/reference/representation/base)

**Example**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation

  action :show
  action :create
end
```

---

### .union

`.union(name, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L246)

Defines a discriminated union type scoped to this contract.

A union is a type that can be one of several variants,
distinguished by a discriminator field. In introspection
output, unions are namespaced with the contract's scope prefix.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | union name |
| `discriminator` | `Symbol` | field that identifies the variant |

**Example**

```ruby
union(:payment_method, discriminator: :type) do
  variant(tag: 'card') do
    object do |object|
      object.string(:last_four)
    end
  end
  variant(tag: 'bank') do
    object do |object|
      object.string(:account_number)
    end
  end
end
```

---

## Instance Methods

### #action_name

`#action_name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L76)

The action name for this contract.

**Returns**

`Symbol`

---

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L88)

The body for this contract.

**Returns**

`Hash`

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L545)

Whether this contract is invalid.

**Returns**

`Boolean`

---

### #issues

`#issues`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L70)

The issues for this contract.

**Returns**

Array&lt;[Issue](/reference/issue)&gt;

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L82)

The query for this contract.

**Returns**

`Hash`

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L64)

The request for this contract.

**Returns**

[Request](/reference/request)

---

### #valid?

`#valid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L537)

Whether this contract is valid.

**Returns**

`Boolean`

---
