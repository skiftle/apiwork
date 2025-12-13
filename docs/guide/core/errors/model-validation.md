---
order: 3
---

# Model Validation

ActiveRecord validation errors become Issues automatically. Same format as contract errors. Your API returns consistent errors whether they come from contracts, models, or nested associations.

Requires:

- A schema (`schema!`)
- The built-in adapter (default)
- ActiveRecord

## How It Works

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  render_with_contract invoice
end
```

If validation fails, the adapter sees `invoice.errors`, converts each to an Issue, and raises `ValidationError`. You get a 422 with all issues. No conditionals needed.

## Issue Format

```json
{
  "code": "blank",
  "detail": "can't be blank",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": { "attribute": "number" }
}
```

| Field     | Source                                              |
| --------- | --------------------------------------------------- |
| `code`    | Rails error type (`:blank`, `:too_short`, `:taken`) |
| `detail`  | Human-readable message                              |
| `path`    | Schema root key + attribute                         |
| `pointer` | JSON Pointer from path                              |
| `meta`    | Constraints and context                             |

## Error Mapping

| Rails Validation                    | Code           | Detail                                    |
| ----------------------------------- | -------------- | ----------------------------------------- |
| `presence: true`                    | `blank`        | "can't be blank"                          |
| `uniqueness: true`                  | `taken`        | "has already been taken"                  |
| `length: { minimum: 3 }`            | `too_short`    | "is too short (minimum is 3 characters)"  |
| `length: { maximum: 100 }`          | `too_long`     | "is too long (maximum is 100 characters)" |
| `numericality: { greater_than: 0 }` | `greater_than` | "must be greater than 0"                  |
| `format: { with: /.../ }`           | `invalid`      | "is invalid"                              |
| `inclusion: { in: [...] }`          | `inclusion`    | "is not included in the list"             |

## Metadata

Constraints end up in `meta`:

```ruby
validates :number, length: { minimum: 3, maximum: 50 }
```

```json
{
  "code": "too_short",
  "path": ["invoice", "number"],
  "meta": {
    "attribute": "number",
    "minimum": 3,
    "count": 1
  }
}
```

`count` is the actual length. The client can show "1 character entered, 3 required."

| Validation                 | Meta                   |
| -------------------------- | ---------------------- |
| `length: { minimum: X }`   | `minimum`, `count`     |
| `length: { maximum: X }`   | `maximum`, `count`     |
| `length: { is: X }`        | `is`, `count`          |
| `numericality`             | `count` (actual value) |
| `inclusion: { in: [...] }` | `in`                   |

## Paths

Paths start with the schema's root key:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, writable: true
end
```

`InvoiceSchema` → `invoice` → `["invoice", "number"]`

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
  "issues": [
    {
      "code": "blank",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number"
    },
    {
      "code": "blank",
      "path": ["invoice", "lines", 1, "description"],
      "pointer": "/invoice/lines/1/description"
    },
    {
      "code": "greater_than",
      "path": ["invoice", "lines", 1, "quantity"],
      "pointer": "/invoice/lines/1/quantity"
    }
  ]
}
```

`["invoice", "lines", 1, "quantity"]` — second line (index 1), quantity field. A form knows exactly which input to highlight.

### Association Types

**has_many** — indexed:

```
["invoice", "lines", 0, "description"]
["invoice", "lines", 1, "description"]
```

**has_one** — no index:

```
["user", "profile", "bio"]
```

**belongs_to** — foreign key:

```
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
  "path": ["invoice", "lines", 0, "adjustments", 2, "reason"]
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

## HTTP Status

- **400** — Contract error (malformed request)
- **422** — Validation error (business rules)

The request parsed correctly but failed validation.

## Works on Any Action

The adapter checks `respond_with` every time. Not just `create` or `update`.

```ruby
return unless record.respond_to?(:errors) && record.errors.any?
```

If the record has errors, they become issues. Doesn't matter which action.

### Custom Actions

A `publish` action with its own validations:

```ruby
class Invoice < ApplicationRecord
  validate :publishable?, on: :publish

  private

  def publishable?
    errors.add(:status, "already published") if published?
    errors.add(:lines, "needs at least one line") if lines.empty?
  end
end
```

```ruby
def publish
  invoice.status = 'published'
  invoice.save(context: :publish)
  render_with_contract invoice
end
```

If `save` fails, errors are there. `respond_with` returns 422 with issues.

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
  render_with_contract order
end
```

`ship!` returns false, order has errors, `respond_with` handles it.

### Manual Errors

Add errors anywhere:

```ruby
def transfer
  account = Account.find(contract.body[:from_account_id])
  amount = contract.body[:amount]

  if amount > account.balance
    account.errors.add(:balance, "insufficient funds")
  end

  render_with_contract account
end
```

No conditionals. Add errors, call `respond_with`.

### The Pattern

1. Do the operation
2. Add errors if something fails
3. Call `respond_with`

Errors exist? 422 with issues. No errors? Serialized record.

## Adapter-Specific

This is built into the Apiwork adapter. It:

1. Checks for errors before rendering
2. Walks associations recursively
3. Builds paths with indexes
4. Raises `ValidationError`

Custom adapters need their own implementation.

---

## Examples

See [Model Validation Errors](../../examples/model-validation-errors.md) for complete examples of validation error responses including nested associations.
