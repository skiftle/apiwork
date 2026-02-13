---
order: 40
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L47)

Base class for contracts.

Validates requests and defines response shapes. Drives type generation and
request parsing. Types are defined manually per action or auto-generated
from a linked representation.

**Example: Manual contract**

```ruby
class InvoiceContract < Apiwork::Contract::Base
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

**Example: With representation**

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

## Class Methods

### .abstract!

`.abstract!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L47)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L47)

Whether this contract is abstract.

**Returns**

`Boolean`

---

### .action

`.action(name, replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L452)

Defines or extends an action on this contract.

Multiple calls with the same name merge definitions (declaration merging).

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The action name. Matches your controller action. |
| `replace` | `Boolean` | `false` | Whether to discard any existing definition and start fresh. Use when overriding auto-generated actions from representation. |

</div>

**Returns**

[Contract::Action](/reference/contract/action/)

**Yields** [Contract::Action](/reference/contract/action/)

**Example: Query parameters**

```ruby
action :index do
  request do
    query do
      string? :search
      integer? :page
    end
  end
end
```

**Example: Request body with custom type**

```ruby
action :create do
  request do
    body do
      reference :invoice, to: :invoice_payload
    end
  end
  response do
    body do
      reference :invoice
    end
  end
end
```

**Example: Override auto-generated action**

```ruby
action :destroy, replace: true do
  response do
    body do
      reference :invoice
    end
  end
end
```

**Example: No content response**

```ruby
action :destroy do
  response { no_content! }
end
```

---

### .enum

`.enum(name, deprecated: false, description: nil, example: nil, values: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L277)

Defines or extends an enum for this contract.

Subclasses inherit parent enums. In introspection, enums are prefixed with the
contract's [.identifier](#identifier) (e.g., `:status` in `InvoiceContract` becomes `:invoice_status`).

Multiple calls with the same name merge values (declaration merging).

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

**Example: Define and reference**

```ruby
enum :status, values: %w[draft sent paid]

action :update do
  request do
    body do
      string :status, enum: :status
    end
  end
end
```

**Example: Inline values (without separate definition)**

```ruby
action :index do
  request do
    query do
      string? :priority, enum: %w[low medium high]
    end
  end
end
```

---

### .identifier

`.identifier(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L121)

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

`.import(klass, as:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L370)

Imports types from another contract for reuse.

Imported types are accessed with a prefix matching the alias.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`klass`** | `Class<Contract::Base>` |  | The contract class to import types from. |
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L478)

Returns introspection data for this contract.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `expand` | `Boolean` | `false` | Whether to expand all types inline. |
| `locale` | `Symbol`, `nil` | `nil` | The locale for translations. |

</div>

**Returns**

[Introspection::Contract](/reference/introspection/contract)

**Example**

```ruby
InvoiceContract.introspect
```

---

### .object

`.object(name, deprecated: false, description: nil, example: nil, fragment: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L219)

Defines or extends an object type for this contract.

Subclasses inherit parent types. In introspection, types are prefixed with the
contract's [.identifier](#identifier) (e.g., `:item` in `InvoiceContract` becomes `:invoice_item`).

Multiple calls with the same name merge fields (declaration merging).

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The object name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `fragment` | `Boolean` | `false` | Whether this type is a fragment. Fragments are only available for merging into other types and never appear as standalone types. |

</div>

**Returns**

`void`

**Yields** [API::Object](/reference/api/object)

**Example: Define and reference**

```ruby
object :item do
  string :description
  decimal :amount
end

action :create do
  request do
    body do
      array :items do
        reference :item
      end
    end
  end
end
```

**Example: Different shapes for request and response**

```ruby
object :invoice do
  uuid :id
  string :number
  string :status
end

object :invoice_payload do
  string :number
  string :status
end

action :create do
  request do
    body do
      reference :invoice, to: :invoice_payload
    end
  end
  response do
    body do
      reference :invoice
    end
  end
end
```

---

### .representation

`.representation(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L142)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L97)

The representation class for this contract.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

**See also**

- [.representation](#representation)

---

### .union

`.union(name, deprecated: false, description: nil, discriminator: nil, example: nil, fragment: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L333)

Defines or extends a discriminated union for this contract.

Subclasses inherit parent unions. In introspection, unions are prefixed with the
contract's [.identifier](#identifier) (e.g., `:payment_method` in `InvoiceContract` becomes `:invoice_payment_method`).

Multiple calls with the same name merge variants (declaration merging).

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The union name. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. |
| `example` | `Object`, `nil` | `nil` | The example. Metadata included in exports. |
| `fragment` | `Boolean` | `false` | Whether this type is a fragment. Fragments are only available for merging into other types and never appear as standalone types. |

</div>

**Returns**

`void`

**Yields** [API::Union](/reference/api/union)

**Example: Define and reference**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
  variant tag: 'bank_transfer' do
    object do
      string :bank_name
      string :account_number
    end
  end
end

action :create do
  request do
    body do
      reference :payment_method
    end
  end
end
```

---

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L87)

The body for this contract.

Use this in controller actions to access validated request data.
Contains type-coerced values matching your contract definition.
Invalid requests are rejected before the action runs.

**Returns**

`Hash`

**Example**

```ruby
def create
  Invoice.create!(contract.body[:invoice])
end
```

---

### #invalid?

`#invalid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L673)

Whether this contract is invalid.

**Returns**

`Boolean`

---

### #issues

`#issues`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L54)

The issues for this contract.

**Returns**

Array&lt;[Issue](/reference/issue)&gt;

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L87)

The query for this contract.

Use this in controller actions to access validated request data.
Contains type-coerced values matching your contract definition.
Invalid requests are rejected before the action runs.

**Returns**

`Hash`

**Example**

```ruby
def index
  Invoice.where(status: contract.query[:status])
end
```

---

### #valid?

`#valid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/base.rb#L665)

Whether this contract is valid.

**Returns**

`Boolean`

---
