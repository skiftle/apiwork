---
order: 9
---

# Validation

The standard adapter automatically converts ActiveRecord validation errors to domain errors when `expose` is called.

## How It Works

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  expose invoice
end
```

When domain rules fail, the adapter converts each violation to an Issue and raises `DomainError` with a 422 response containing all issues.

## Rails Validation Mapping

Rails validations use internal error types like `blank`, `taken`, `too_short`. The adapter maps these to semantic codes that work better for API clients:

- `blank`, `empty` becomes `required` — field must have a value
- `taken` becomes `unique` — value already exists
- `too_short`, `too_long` becomes `min`, `max` — length constraints
- `greater_than` becomes `gt` — numeric constraints

This keeps the API separate from Rails internals. Multiple Rails types map to one code (`blank` and `empty` both become `required`). Constraint values go in `meta`:

```json
{
  "code": "gt",
  "meta": { "gt": 0 }
}
```

Clients format this however they want: "must be greater than 0", "minimum: 1", or a localized equivalent.

### Mapping Table

| Rails Type                   | Code        | Detail            |
| ---------------------------- | ----------- | ----------------- |
| `blank`                      | `required`  | Required          |
| `empty`                      | `required`  | Required          |
| `present`                    | `forbidden` | Must be blank     |
| `taken`                      | `unique`    | Already taken     |
| `accepted`                   | `accepted`  | Must be accepted  |
| `confirmation`               | `confirmed` | Does not match    |
| `too_short`                  | `min`       | Too short         |
| `too_long`                   | `max`       | Too long          |
| `wrong_length`               | `length`    | Wrong length      |
| `not_a_number`               | `number`    | Not a number      |
| `not_an_integer`             | `integer`   | Not an integer    |
| `greater_than`               | `gt`        | Too small         |
| `greater_than_or_equal_to`   | `gte`       | Too small         |
| `less_than`                  | `lt`        | Too large         |
| `less_than_or_equal_to`      | `lte`       | Too large         |
| `equal_to`                   | `eq`        | Wrong value       |
| `other_than`                 | `ne`        | Reserved value    |
| `odd`                        | `odd`       | Must be odd       |
| `even`                       | `even`      | Must be even      |
| `inclusion`                  | `in`        | Invalid value     |
| `in`                         | `in`        | Invalid value     |
| `exclusion`                  | `not_in`    | Reserved value    |
| `invalid`                    | `invalid`   | Invalid           |
| `restrict_dependent_destroy` | `associated`| Invalid           |

## Custom Codes

Custom error types pass through as-is:

```ruby
errors.add(:email, :disposable)
errors.add(:account, :suspended)
errors.add(:transfer, :insufficient_funds)
```

```json
{
  "code": "disposable",
  "detail": "Disposable",
  "path": ["user", "email"]
}
```

The `detail` defaults to the code humanized (`:insufficient_funds` becomes `"Insufficient funds"`).

### Translating Custom Codes

To control the detail text, add translations under the Apiwork namespace. The adapter checks two levels:

1. **API-specific** — for one API only
2. **Global** — for all APIs using the standard adapter

```yaml
# config/locales/en.yml
en:
  apiwork:
    apis:
      billing:                          # API-specific (locale_key)
        adapters:
          standard:
            capabilities:
              writing:
                issues:
                  insufficient_funds:
                    detail: "Insufficient funds"
    adapters:
      standard:                         # Global fallback
        capabilities:
          writing:
            issues:
              insufficient_funds:
                detail: "Insufficient funds"
```

```yaml
# config/locales/sv.yml
sv:
  apiwork:
    adapters:
      standard:
        capabilities:
          writing:
            issues:
              insufficient_funds:
                detail: "Otillräckliga medel"
              disposable:
                detail: "Engångsadress tillåts inte"
```

Detail resolution order:

1. API-specific translation (`apiwork.apis.<locale_key>.adapters.standard...`)
2. Global translation (`apiwork.adapters.standard...`)
3. Built-in detail (covers the 23 standard codes like `required`, `unique`, `max`)
4. Humanized code (`:insufficient_funds` becomes `"Insufficient funds"`)

The humanized fallback works well during development. Translations can be added for localization or more precise wording.

### Why Not Rails Messages?

Rails `errors.add` accepts an optional `message:` parameter:

```ruby
errors.add(:email, :disposable, message: "can't be a disposable address")
```

The adapter ignores `message:`. The `message:` text is a Rails display concept — designed for `full_messages`, form helpers, and flash notices. API details are a separate concern with different requirements:

- Rails messages are sentence fragments ("can't be blank") meant to follow an attribute name
- API details are standalone labels ("Required") for client-side formatting
- Rails messages use `activerecord.errors.*` translations; API details use `apiwork.*` translations
- Mixing the two systems makes neither work well for multilingual apps

## Record-Level Errors

Errors on `:base` preserve the error type as the code:

```ruby
errors.add(:base, :insufficient_funds)
```

```json
{
  "code": "insufficient_funds",
  "detail": "Insufficient funds",
  "path": ["invoice"],
  "pointer": "/invoice"
}
```

No field name in path indicates a record-level error.

## String Messages

When `errors.add` receives a string instead of a symbol, the adapter produces `code: "invalid"`:

```ruby
errors.add(:base, "Something went wrong")   # code: "invalid"
errors.add(:email, "Must be corporate")      # code: "invalid"
```

Strings are display messages, not type identifiers. The adapter cannot derive a meaningful machine-readable code from free-form text, so it falls back to `invalid`.

Symbols produce meaningful codes:

```ruby
errors.add(:base, :payment_failed)           # code: "payment_failed"
errors.add(:email, :corporate_required)      # code: "corporate_required"
```

## Error Codes

All 23 domain error codes:

| Code        | Detail            | Meta                           |
| ----------- | ----------------- | ------------------------------ |
| `required`  | Required          | —                              |
| `forbidden` | Must be blank     | —                              |
| `unique`    | Already taken     | —                              |
| `accepted`  | Must be accepted  | —                              |
| `confirmed` | Does not match    | —                              |
| `min`       | Too short         | `min`                          |
| `max`       | Too long          | `max`                          |
| `length`    | Wrong length      | `exact`                        |
| `number`    | Not a number      | —                              |
| `integer`   | Not an integer    | —                              |
| `gt`        | Too small         | `gt`                           |
| `gte`       | Too small         | `gte`                          |
| `lt`        | Too large         | `lt`                           |
| `lte`       | Too large         | `lte`                          |
| `eq`        | Wrong value       | `eq`                           |
| `ne`        | Reserved value    | `ne`                           |
| `odd`       | Must be odd       | —                              |
| `even`      | Must be even      | —                              |
| `in`        | Invalid value     | `min`, `max`, `max_exclusive`  |
| `not_in`    | Reserved value    | —                              |
| `format`    | Invalid format    | —                              |
| `associated`| Invalid           | —                              |
| `invalid`   | Invalid           | —                              |

## Examples

Constraints that are safe to expose go in `meta` — they help clients build better error messages without leaking implementation details:

### Length Constraints

```ruby
validates :number, length: { minimum: 3 }
```

```json
{
  "code": "min",
  "detail": "Too short",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": { "min": 3 }
}
```

### Exact Length

```ruby
validates :code, length: { is: 6 }
```

```json
{
  "meta": { "exact": 6 }
}
```

### Numericality

```ruby
validates :quantity, numericality: { greater_than: 0 }
```

```json
{
  "code": "gt",
  "detail": "Too small",
  "path": ["line", "quantity"],
  "pointer": "/line/quantity",
  "meta": { "gt": 0 }
}
```

### Inclusion with Range

```ruby
validates :rating, inclusion: { in: 1..5 }
```

```json
{
  "code": "in",
  "detail": "Invalid value",
  "path": ["review", "rating"],
  "pointer": "/review/rating",
  "meta": {
    "min": 1,
    "max": 5,
    "max_exclusive": false
  }
}
```

For exclusive ranges (`1...5`), `max_exclusive` is `true`.

## Paths

Paths start with the representation's root key:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number, writable: true
end
```

`InvoiceRepresentation` produces key `invoice`, so path is `["invoice", "number"]`.

Matches the request body. Client sent `{ "invoice": { "number": "" } }`, error points to `["invoice", "number"]`.

## Nested Writes

Errors from nested writes get full paths with array indexes.

```ruby
class Invoice < ApplicationRecord
  has_many :lines
  accepts_nested_attributes_for :lines
end

class Line < ApplicationRecord
  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
```

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number, writable: true
  has_many :lines, writable: true
end

class LineRepresentation < Apiwork::Representation::Base
  attribute :description, writable: true
  attribute :quantity, writable: true
end
```

Request:

```json
{
  "invoice": {
    "number": "",
    "lines": [
      { "description": "Widget", "quantity": 5 },
      { "description": "", "quantity": -1 }
    ]
  }
}
```

Response:

```json
{
  "layer": "domain",
  "issues": [
    {
      "code": "required",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": {}
    },
    {
      "code": "required",
      "detail": "Required",
      "path": ["invoice", "lines", 1, "description"],
      "pointer": "/invoice/lines/1/description",
      "meta": {}
    },
    {
      "code": "gt",
      "detail": "Too small",
      "path": ["invoice", "lines", 1, "quantity"],
      "pointer": "/invoice/lines/1/quantity",
      "meta": { "gt": 0 }
    }
  ]
}
```

`["invoice", "lines", 1, "quantity"]` — second line (index 1), quantity field. A form knows exactly which input to highlight.

### Association Types

**has_many** — indexed:

```json
["invoice", "lines", 0, "description"]
["invoice", "lines", 1, "description"]
```

**has_one** — no index:

```json
["user", "profile", "bio"]
```

**belongs_to** — foreign key:

```json
["line", "invoice_id"]
```

### Record-Level

Errors on `:base` get the record path without a field name:

**has_one:**

```json
["user", "profile"]
```

**has_many:**

```json
["invoice", "lines", 1]
```

### Any Depth

The adapter walks associations recursively:

```ruby
class Line < ApplicationRecord
  has_many :adjustments
  accepts_nested_attributes_for :adjustments
end

class Adjustment < ApplicationRecord
  validates :reason, presence: true
end
```

```json
{
  "code": "required",
  "path": ["invoice", "lines", 0, "adjustments", 2, "reason"],
  "pointer": "/invoice/lines/0/adjustments/2/reason",
  "detail": "Required",
  "meta": {}
}
```

First line, third adjustment, reason field.

### Requirements

For nested errors:

1. Representation association is writable:

   ```ruby
   has_many :lines, writable: true
   ```

2. Model accepts nested attributes:
   ```ruby
   accepts_nested_attributes_for :lines
   ```

## Custom Actions

The adapter checks on every action, including custom ones.

```ruby
return unless record.respond_to?(:errors) && record.errors.any?
```

If the record has errors, they become API errors regardless of which action was called.

### State Transitions

```ruby
class Order < ApplicationRecord
  def ship
    unless shippable?
      errors.add(:base, :not_shippable)
      errors.add(:address, :blank) if address.blank?
      return false
    end
    update(status: 'shipped')
  end
end
```

```ruby
def ship
  order.ship
  expose order
end
```

`ship` returns false, order has errors, `expose` handles it.

### Manual Errors

Add errors anywhere:

```ruby
def transfer
  account = Account.find(contract.body[:from_account_id])
  amount = contract.body[:amount]

  if amount > account.balance
    account.errors.add(:balance, :insufficient_funds)
  end

  expose account
end
```

The controller does not need to check for errors. Add errors to the record, then call `expose`.

## The Pattern

1. Do the operation
2. Add errors if something fails
3. Call `expose`

If the record has errors, the response is 422 with the errors. Otherwise, the record is serialized.

#### See also

- [Domain Errors](../../errors/domain-errors.md) — domain layer concept
- [Issue reference](../../../reference/issue.md) — issue object shape
