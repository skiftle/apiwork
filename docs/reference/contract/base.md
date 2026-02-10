---
order: 40
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

Whether this contract is abstract.

**Returns**

`Boolean`

---

### .action

`.action(action_name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L303)

Defines an action on this contract.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_name`** | `Symbol` |  | The action name. Standard actions: `:index`, `:show`, `:create`, `:update`, `:destroy`. |
| `replace` | `Boolean` | `false` | Whether to replace an existing action definition. |

</div>

**Returns**

[Contract::Action](/reference/contract/action/)

**Yields** [Contract::Action](/reference/contract/action/)

**Example**

```ruby
action :show do
  request do
    query do
      string? :include
    end
  end
end
```

---

### .enum

`.enum(name, deprecated: false, description: nil, example: nil, values: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L205)

Defines an enum scoped to this contract.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The enum name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example. Metadata included in exports. |
| `values` | `Array<String>`, `nil` | `nil` | The allowed values. |

</div>

**Returns**

`void`

**Example**

```ruby
enum :status, values: %w[draft sent paid]
```

---

### .identifier

`.identifier(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L113)

Prefixes types, enums, and unions in introspection output.

Must be unique within the API. Derived from the contract class
name when not set (e.g., `RecurringInvoiceContract` becomes
`recurring_invoice`).

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Symbol`, `String`, `nil` | `nil` | The identifier prefix. |

</div>

**Returns**

`String`, `nil`

**Example**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  identifier :billing

  object :address do
    string :street
  end
  # In introspection: :address becomes :billing_address
end
```

---

### .import

`.import(contract_class, as:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L253)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`contract_class`** | `Class<Contract::Base>` |  | The contract class to import types from. |
| **`as`** | `Symbol` |  | The alias prefix. |

</div>

**Returns**

`void`

**Example**

```ruby
import UserContract, as: :user
# UserContract's :address becomes :user_address
```

---

### .introspect

`.introspect(expand: false, locale: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L329)

Returns introspection data for this contract.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `expand` | `Boolean` | `false` | Whether to expand all types inline. |
| `locale` | `Symbol`, `nil` | `nil` | The locale for translations. |

</div>

**Returns**

`Hash`

**Example**

```ruby
InvoiceContract.introspect
```

---

### .object

`.object(name, description: nil, example: nil, format: nil, deprecated: false, representation_class: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L167)

Defines a reusable object type scoped to this contract.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The type name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `format` | `String`, `nil` | `nil` | The format. Metadata included in exports. |
| `representation_class` | `Class<Representation::Base>`, `nil` | `nil` | The representation class for auto-generating fields. |

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

### .representation

`.representation(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L134)

Configures the representation class for this contract.

Adapters use the representation to auto-generate request/response
types. Use [.representation_class](#representation-class) to retrieve.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`klass`** | `Class<Representation::Base>` |  | The representation class. |

</div>

**Returns**

`void`

**Example**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

---

### .representation_class

`.representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L367)

The representation class for this contract.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

**See also**

- [.representation](#representation)

---

### .union

`.union(name, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L233)

Defines a discriminated union type scoped to this contract.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The union name. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L90)

The body for this contract.

**Returns**

`Hash`

**See also**

- [Request#body](/reference/request#body)

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L493)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L83)

The query for this contract.

**Returns**

`Hash`

**See also**

- [Request#query](/reference/request#query)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L485)

Whether this contract is valid.

**Returns**

`Boolean`

---
