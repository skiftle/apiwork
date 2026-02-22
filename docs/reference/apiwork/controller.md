---
order: 44
prev: false
next: false
---

# Controller

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L28)

Mixin for API controllers that provides request validation and response helpers.

Include in controllers to access [#contract](#contract), [#expose](#expose), and [#expose_error](#expose-error).
Automatically validates requests against the contract before actions run.

**Example: Basic controller**

```ruby
class InvoicesController < ApplicationController
  include Apiwork::Controller

  def index
    expose Invoice.all
  end

  def show
    invoice = Invoice.find(params[:id])
    expose invoice
  end

  def create
    invoice = Invoice.create(contract.body[:invoice])
    expose invoice
  end
end
```

## Class Methods

### .skip_contract_validation!

`.skip_contract_validation!(only: nil, except: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L55)

Skips contract validation for specified actions.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`except`** | `Array<Symbol>` |  | Skip for all except these actions. |
| **`only`** | `Array<Symbol>` |  | Skip only for these actions. |

</div>

**Example: Skip for specific actions**

```ruby
skip_contract_validation! only: [:ping, :status]
```

**Example: Skip for all actions**

```ruby
skip_contract_validation!
```

---

## Instance Methods

### #context

`#context`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L220)

The context for this controller.

Passed to representations during serialization. Override to provide
current user, permissions, locale, or feature flags.

**Returns**

`Hash`

**Example: Provide current user context**

```ruby
def context
  { current_user: current_user }
end
```

**Example: Access context in representation**

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :editable, type: :boolean

  def editable
    context[:current_user].admin?
  end
end
```

---

### #contract

`#contract`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L82)

The contract for this controller.

Contains parsed query parameters and request body with type coercion applied.
Access parameters via [Contract::Base#query](/reference/apiwork/contract/base#query) and [Contract::Base#body](/reference/apiwork/contract/base#body).

**Returns**

[Contract::Base](/reference/apiwork/contract/base)

**See also**

- [Contract::Base](/reference/apiwork/contract/base)

**Example: Access parsed parameters**

```ruby
def create
  invoice = Invoice.new(contract.body)
  # contract.body contains validated, coerced params
end
```

**Example: Check for specific parameters**

```ruby
def index
  if contract.query[:include]
    # handle include parameter
  end
end
```

---

### #expose

`#expose(data, meta: {}, status: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L124)

Exposes data as an API response.

When a representation is linked via [Contract::Base.representation](/reference/apiwork/contract/base#representation), data is serialized
through the representation. Otherwise, data is rendered as-is. Key transformation
is applied according to the API's [API::Base.key_format](/reference/apiwork/api/base#key-format).

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`data`** | `Object`, `Array` |  | The record(s) to expose. |
| `meta` | `Hash` | `{}` | The metadata to include in response (pagination, etc.). |
| `status` | `Symbol`, `Integer`, `nil` | `nil` | The HTTP status (:ok, or :created for create action). |

</div>

**See also**

- [Representation::Base](/reference/apiwork/representation/base)

**Example: Expose a single record**

```ruby
def show
  invoice = Invoice.find(params[:id])
  expose invoice
end
```

**Example: Expose a collection with metadata**

```ruby
def index
  invoices = Invoice.all
  expose invoices, meta: { total: invoices.count }
end
```

**Example: Custom status**

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  expose invoice, status: :created
end
```

---

### #expose_error

`#expose_error(code_key, detail: nil, path: nil, meta: {})`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L181)

Exposes an error response using a registered error code.

Defaults to I18n lookup when detail is not provided.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`code_key`** | `Symbol` |  | The registered error code (:not_found, :unauthorized, etc.). |
| `detail` | `String`, `nil` | `nil` | The custom error message (uses I18n lookup if nil). |
| `meta` | `Hash` | `{}` | The additional metadata to include. |
| `path` | `Array<String, Symbol>`, `nil` | `nil` | The JSON path to the error. |

</div>

**See also**

- [ErrorCode](/reference/apiwork/introspection/error-code)
- [Issue](/reference/apiwork/issue)

**Example: Not found error**

```ruby
def show
  invoice = Invoice.find_by(id: params[:id])
  return expose_error :not_found unless invoice
  expose invoice
end
```

**Example: With custom message**

```ruby
expose_error :forbidden, detail: 'You cannot access this invoice'
```

---
