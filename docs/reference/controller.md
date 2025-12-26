---
order: 14
prev: false
next: false
---

# Controller

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller.rb#L5)

## Class Methods

### .skip_contract_validation!(**options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/deserialization.rb#L35)

Skips contract validation for specified actions.

Use this when certain actions don't need request validation,
such as health checks or legacy endpoints.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options` | `Hash` | options passed to skip_before_action |

**Example: Skip for specific actions**

```ruby
class HealthController < ApplicationController
  skip_contract_validation! only: [:ping, :status]
end
```

**Example: Skip for all actions**

```ruby
class LegacyController < ApplicationController
  skip_contract_validation!
end
```

---

## Instance Methods

### #context()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/serialization.rb#L142)

Returns the serialization context passed to schemas.

Override this method to provide context data to your schemas.
Common uses: current user, permissions, locale, feature flags.

**Returns**

`Hash` — context data available in schema serialization

**Example: Provide current user context**

```ruby
def context
  { current_user: current_user }
end
```

---

### #contract()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/deserialization.rb#L62)

Returns the parsed and validated request contract.

The contract contains parsed query parameters and request body,
with type coercion applied. Access parameters via [Contract::Base#query](contract-base#query)
and [Contract::Base#body](contract-base#body).

**Returns**

`Contract::Base` — the contract instance

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

### #render_error(issues, layer:, status: = :bad_request)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/serialization.rb#L88)

Renders an error response with validation issues.

Use this for validation errors where you have a list of issues.
For standard HTTP errors, use `respond_with_error` instead.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `issues` | `Array<Issue>` | list of validation issues |
| `layer` | `String` | error layer ("http", "contract", or "domain") |
| `status` | `Symbol, Integer` | HTTP status (default: :bad_request) |

**Example: Render validation errors**

```ruby
def create
  unless record.valid?
    issues = record.errors.map do |error|
      Apiwork::Issue.new(code: :invalid, detail: error.message, path: [error.attribute], meta: {})
    end
    render_error issues, layer: 'domain', status: :unprocessable_entity
  end
end
```

---

### #respond(data, meta: = {}, status: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/serialization.rb#L42)

Renders a successful API response.

When a schema is linked via [Contract::Base.schema!](contract-base#schema!), data is serialized
through the schema. Otherwise, data is rendered as-is. The adapter applies
response transformations (key casing, wrapping, etc.).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `Object, Array` | the record(s) to render |
| `meta` | `Hash` | metadata to include in response (pagination, etc.) |
| `status` | `Symbol, Integer` | HTTP status (default: :ok, or :created for create action) |

**Example: Render a single record**

```ruby
def show
  invoice = Invoice.find(params[:id])
  respond invoice
end
```

**Example: Render a collection with metadata**

```ruby
def index
  invoices = Invoice.all
  respond invoices, meta: { total: invoices.count }
end
```

**Example: Custom status**

```ruby
def create
  invoice = Invoice.create!(contract.body)
  respond invoice, status: :created
end
```

---

### #respond_with_error(code_key, detail: = nil, path: = nil, meta: = {}, i18n: = {})

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/serialization.rb#L117)

Renders an error response using a registered error code.

Error codes are registered via [ErrorCode.register](error-code#register).
The detail message is looked up from I18n if not provided.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code_key` | `Symbol` | registered error code (:not_found, :unauthorized, etc.) |
| `detail` | `String` | custom error message (optional, uses I18n lookup) |
| `path` | `Array<String,Symbol>` | JSON path to the error (optional) |
| `meta` | `Hash` | additional metadata to include (optional) |
| `i18n` | `Hash` | interpolation values for I18n lookup (optional) |

**Example: Not found error**

```ruby
def show
  invoice = Invoice.find_by(id: params[:id])
  return respond_with_error :not_found unless invoice
  respond invoice
end
```

**Example: With custom message**

```ruby
respond_with_error :forbidden, detail: 'You cannot access this invoice'
```

**Example: With I18n interpolation**

```ruby
respond_with_error :not_found, i18n: { resource: 'Invoice' }
```

---
