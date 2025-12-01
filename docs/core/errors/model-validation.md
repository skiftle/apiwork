---
order: 3
---

# Model Validation

When you use a schema with the built-in adapter, ActiveRecord validation errors are automatically converted into Issues — the same format used by contract errors. Your API returns a consistent error shape whether the failure comes from contract validation, model validation, or nested associations.

This feature requires:
- A schema attached to your contract (`schema!`)
- The built-in Apiwork adapter (default)
- ActiveRecord models

## Automatic Error Handling

Pass a record to `respond_with`. If it has validation errors, the adapter handles everything:

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end
```

That's it. If `Invoice.create` fails validation:

1. The adapter detects `invoice.errors` is not empty
2. Each Rails error becomes an Issue with path, code, and metadata
3. A `ValidationError` is raised
4. The controller renders a 422 response with all issues

No manual error checking. No conditional rendering. The adapter does the work.

## The Issue Format

Every validation error becomes an Issue:

```json
{
  "code": "blank",
  "detail": "can't be blank",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": { "attribute": "number" }
}
```

| Field | Source |
|-------|--------|
| `code` | Rails error type (`:blank`, `:too_short`, `:taken`, etc.) |
| `detail` | The human-readable message from Rails |
| `path` | Array built from schema root key + attribute name |
| `pointer` | JSON Pointer derived from path |
| `meta` | Validation constraints and context |

## Rails Error Mapping

Rails validation types map directly to issue codes:

| Rails Validation | Issue Code | Example Detail |
|-----------------|------------|----------------|
| `presence: true` | `blank` | "can't be blank" |
| `uniqueness: true` | `taken` | "has already been taken" |
| `length: { minimum: 3 }` | `too_short` | "is too short (minimum is 3 characters)" |
| `length: { maximum: 100 }` | `too_long` | "is too long (maximum is 100 characters)" |
| `numericality: { greater_than: 0 }` | `greater_than` | "must be greater than 0" |
| `numericality: { less_than: 100 }` | `less_than` | "must be less than 100" |
| `format: { with: /.../ }` | `invalid` | "is invalid" |
| `inclusion: { in: [...] }` | `inclusion` | "is not included in the list" |

## Rich Metadata

Validation constraints are preserved in `meta`:

```ruby
class Invoice < ApplicationRecord
  validates :number, length: { minimum: 3, maximum: 50 }
end
```

```json
{
  "code": "too_short",
  "detail": "is too short (minimum is 3 characters)",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": {
    "attribute": "number",
    "minimum": 3,
    "count": 1
  }
}
```

The `count` field shows the actual length. Clients can use this to build precise feedback: "1 character entered, 3 required."

Available metadata by validation type:

| Validation | Meta Fields |
|------------|-------------|
| `length: { minimum: X }` | `minimum`, `count` |
| `length: { maximum: X }` | `maximum`, `count` |
| `length: { is: X }` | `is`, `count` |
| `length: { in: X..Y }` | `in`, `count` |
| `numericality` | `count` (the actual value) |
| `inclusion: { in: [...] }` | `in` |

## Path Building

Paths start with the schema's root key — derived from the schema class name:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, writable: true
end
```

`InvoiceSchema` → root key `invoice` → path `["invoice", "number"]`

This matches your request body structure exactly. The client sent `{ "invoice": { "number": "" } }`, and the error points to `["invoice", "number"]`.

## Nested Associations

The real power: validation errors from nested records include their full path with array indexes.

Models:

```ruby
class Invoice < ApplicationRecord
  has_many :lines
  accepts_nested_attributes_for :lines
  validates :number, presence: true
end

class Line < ApplicationRecord
  belongs_to :invoice
  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
```

Schemas:

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

Request with multiple errors:

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
      "detail": "can't be blank",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": { "attribute": "number" }
    },
    {
      "code": "blank",
      "detail": "can't be blank",
      "path": ["invoice", "lines", 1, "description"],
      "pointer": "/invoice/lines/1/description",
      "meta": { "attribute": "description" }
    },
    {
      "code": "greater_than",
      "detail": "must be greater than 0",
      "path": ["invoice", "lines", 1, "quantity"],
      "pointer": "/invoice/lines/1/quantity",
      "meta": { "attribute": "quantity", "count": 0 }
    }
  ]
}
```

The path `["invoice", "lines", 1, "quantity"]` tells the client: second line item (index 1), quantity field. A form can highlight exactly the right input.

## Association Types

### has_many

Each record gets its index in the path:

```
["invoice", "lines", 0, "description"]
["invoice", "lines", 1, "description"]
["invoice", "lines", 2, "description"]
```

### has_one

The association name appears directly (no index):

```
["user", "profile", "bio"]
```

### belongs_to

Foreign key errors use the `_id` suffix:

```
["line", "invoice_id"]
```

## Unlimited Depth

The adapter walks associations recursively. Three levels deep? No problem:

```ruby
class Line < ApplicationRecord
  has_many :adjustments
  accepts_nested_attributes_for :adjustments
end

class Adjustment < ApplicationRecord
  validates :reason, presence: true
end
```

Error path:

```json
{
  "path": ["invoice", "lines", 0, "adjustments", 2, "reason"],
  "pointer": "/invoice/lines/0/adjustments/2/reason"
}
```

First line, third adjustment, reason field.

## Requirements

For nested validation to work:

1. **Schema association marked writable:**
   ```ruby
   has_many :lines, writable: true
   ```

2. **Model accepts nested attributes:**
   ```ruby
   accepts_nested_attributes_for :lines
   ```

Without `writable: true`, the association won't accept nested input and errors won't be collected.

## HTTP Status

Model validation errors return **422 Unprocessable Entity**.

- **400 Bad Request** → Contract error (malformed request)
- **422 Unprocessable Entity** → Validation error (business rules failed)

The request was syntactically correct (passed contract validation) but semantically invalid (failed model validation).

## Built-in Adapter Only

This automatic validation-to-issue conversion is provided by the built-in Apiwork adapter. It:

1. Checks if the record has errors before rendering
2. Walks `has_many` and `has_one` associations
3. Recursively collects errors from nested records
4. Builds paths using association names and array indexes
5. Raises `ValidationError` with all collected issues

If you implement a custom adapter for a different ORM, you'll need to provide equivalent logic for your persistence layer.
