---
order: 4
---

# Domain Issues

Domain issues occur when a valid request violates a domain rule. The request was structurally correct — but the data itself breaks a business constraint.

The client cannot avoid domain issues by changing the request shape — only by changing the data itself.

::: info
Layer describes **what kind of rule was broken** — not where the code lives.

A validation defined in a Rails model is still a *domain rule*. The model is just where the rule happens to be enforced. If the rule said "invoice numbers must be unique", that's domain logic — regardless of whether it's checked in a model, a service, or a database constraint.
:::

The built-in adapter automatically maps Rails model validation errors to domain issues when you call `expose`. You can also create domain issues manually for custom business logic.

**Requires:** A schema (`schema!`), the built-in adapter (default), and ActiveRecord.

## HTTP Status

**422 Unprocessable Entity** — The request was valid, but business rules failed.

## How It Works

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  expose invoice
end
```

When domain rules fail, the adapter converts each violation to an Issue and raises `DomainError`. You get a 422 with all issues. No conditionals needed.

## Rails Codes

Rails validations use internal error types like `blank`, `taken`, `too_short`. The adapter maps these to semantic codes that work better for API clients:

- `blank`, `empty` → `required` — field must have a value
- `taken` → `unique` — value already exists
- `too_short`, `too_long` → `min`, `max` — length constraints
- `greater_than` → `gt` — numeric constraints

This decouples your API from Rails internals. If Rails renamed `blank` to `missing`, your API stays stable.

**Consistency.** Rails has multiple types for similar concepts. Both `blank` and `empty` mean the same thing — the field is required. They both become `required`.

**Machine-readable.** Short codes are easier to switch on. Constraint values go in `meta`, not embedded in message text:

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

Custom error types are domain-specific — your own business vocabulary. They pass through as-is.

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

**Why not pass Rails messages?**

Messages are for humans, codes are for machines. Rails messages can contain interpolations, model names, or phrases that don't fit an API context.

You control the `detail` via [i18n](../../advanced/i18n.md#domain-issues). Default is the code titleized (`:insufficient_funds` → "Insufficient funds").

## Record-Level Errors

Errors on `:base` get the root path only:

```ruby
errors.add(:base, :invalid)
```

```json
{
  "code": "invalid",
  "detail": "Invalid",
  "path": ["invoice"],
  "pointer": "/invoice"
}
```

No field name in path indicates a record-level error.

## Error Codes

All 22 domain error codes:

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

::: tip
Translate detail messages via i18n. See [i18n](../../advanced/i18n.md#domain-issues).
:::

## Meta Reference

Constraints end up in `meta`:

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

Paths start with the schema's root key:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, writable: true
end
```

`InvoiceSchema` produces key `invoice`, so path is `["invoice", "number"]`.

Matches the request body. Client sent `{ "invoice": { "number": "" } }`, error points to `["invoice", "number"]`.

## Nested Records

Errors from nested records get full paths with array indexes.

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
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, writable: true
  has_many :lines, writable: true
end

class LineSchema < Apiwork::Schema::Base
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

1. Schema association is writable:

   ```ruby
   has_many :lines, writable: true
   ```

2. Model accepts nested attributes:
   ```ruby
   accepts_nested_attributes_for :lines
   ```

## Custom Actions

The adapter checks `expose` every time. Not just `create` or `update`.

```ruby
return unless record.respond_to?(:errors) && record.errors.any?
```

If the record has errors, they become API errors. Doesn't matter which action.

### State Transitions

```ruby
class Order < ApplicationRecord
  def ship!
    unless shippable?
      errors.add(:base, "cannot ship #{status} order")
      errors.add(:address, "required") if address.blank?
      return false
    end
    update!(status: 'shipped')
  end
end
```

```ruby
def ship
  order.ship!
  expose order
end
```

`ship!` returns false, order has errors, `expose` handles it.

### Manual Errors

Add errors anywhere:

```ruby
def transfer
  account = Account.find(contract.body[:from_account_id])
  amount = contract.body[:amount]

  if amount > account.balance
    account.errors.add(:balance, "insufficient funds")
  end

  expose account
end
```

No conditionals. Add errors, call `expose`.

## The Pattern

1. Do the operation
2. Add errors if something fails
3. Call `expose`

Errors exist? 422 with errors. No errors? Serialized record.
