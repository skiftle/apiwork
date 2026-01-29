---
order: 30
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
    invoice = Invoice.create!(contract.body)
    expose invoice, status: :created
  end
end
```

## Class Methods

### .skip_contract_validation!

`.skip_contract_validation!(only: nil, except: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L53)

Skips contract validation for specified actions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `only` | `Array<Symbol>` | skip only for these |
| `except` | `Array<Symbol>` | skip for all except these |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L205)

The serialization context passed to representations.

Override this method to provide context data to your representations.
Common uses: current user, permissions, locale, feature flags.

**Returns**

`Hash` — context data available in representation serialization

**Example: Provide current user context**

```ruby
def context
  { current_user: current_user }
end
```

---

### #contract

`#contract`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L81)

The parsed and validated request contract.

The contract contains parsed query parameters and request body,
with type coercion applied. Access parameters via [Contract::Base#query](contract-base#query)
and [Contract::Base#body](contract-base#body).

**Returns**

[Contract::Base](contract-base) — the contract instance

**See also**

- [Contract::Base](contract-base)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L120)

Exposes data as an API response.

When a representation is linked via [Contract::Base.representation](contract-base#representation), data is serialized
through the representation. Otherwise, data is rendered as-is. The adapter applies
response transformations (key casing, wrapping, etc.).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `Object, Array` | the record(s) to expose |
| `meta` | `Hash` | metadata to include in response (pagination, etc.) |
| `status` | `Symbol, Integer` | HTTP status (default: :ok, or :created for create action) |

**See also**

- [Representation::Base](representation-base)

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
  invoice = Invoice.create!(contract.body)
  expose invoice, status: :created
end
```

---

### #expose_error

`#expose_error(code_key, detail: nil, path: nil, meta: {})`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L174)

Exposes an error response using a registered error code.

Error codes are registered via [ErrorCode.register](introspection-error-code#register).
The detail message is looked up from I18n if not provided.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code_key` | `Symbol` | registered error code (:not_found, :unauthorized, etc.) |
| `detail` | `String` | custom error message (optional, uses I18n lookup) |
| `path` | `Array<String,Symbol>` | JSON path to the error (optional) |
| `meta` | `Hash` | additional metadata to include (optional) |

**See also**

- [ErrorCode](introspection-error-code)
- [Issue](issue)

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
