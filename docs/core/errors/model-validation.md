---
order: 3
---

# Model Validation

When ActiveRecord validations fail, Apiwork converts them into the same issue format used by contract errors. This gives clients a unified error structure regardless of where validation happened.

## How It Works

When `respond_with` receives a record with validation errors, Apiwork intercepts the response:

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end
```

If `Invoice.create` fails validation, Apiwork:

1. Detects that `invoice.errors` is not empty
2. Converts each Rails error into an Issue
3. Raises a `ValidationError` with those issues
4. The controller concern catches it and renders a 422 response

You don't need to check `invoice.valid?` or handle errors manually — `respond_with` does it automatically.

## Error Conversion

Rails validation errors map to Apiwork issues:

| Rails Error | Issue Code | Detail |
|-------------|------------|--------|
| `blank` | `:blank` | "can't be blank" |
| `too_short` | `:too_short` | "is too short (minimum is X characters)" |
| `too_long` | `:too_long` | "is too long (maximum is X characters)" |
| `invalid` | `:invalid` | "is invalid" |
| `taken` | `:taken` | "has already been taken" |
| `greater_than` | `:greater_than` | "must be greater than X" |
| `less_than` | `:less_than` | "must be less than X" |

The `code` comes directly from Rails' error type. The `detail` is the human-readable message.

## Path Building

Paths are built from the schema's root key:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, writable: true
end
```

A validation error on `number`:

```json
{
  "code": "blank",
  "detail": "can't be blank",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": { "attribute": "number" }
}
```

The root key (`invoice`) comes from the schema class name, matching the request body structure.

## Metadata

Rails validation options are preserved in the `meta` field:

```ruby
class Invoice < ApplicationRecord
  validates :number, length: { minimum: 3, maximum: 50 }
  validates :total, numericality: { greater_than: 0 }
end
```

```json
{
  "code": "too_short",
  "detail": "is too short (minimum is 3 characters)",
  "path": ["invoice", "number"],
  "pointer": "/invoice/number",
  "meta": { "attribute": "number", "minimum": 3, "count": 2 }
}
```

Available metadata fields:

| Validation | Meta Fields |
|------------|-------------|
| `length: { minimum: X }` | `minimum`, `count` |
| `length: { maximum: X }` | `maximum`, `count` |
| `length: { is: X }` | `is`, `count` |
| `length: { in: X..Y }` | `in`, `count` |
| `numericality: { greater_than: X }` | `count` |
| `inclusion: { in: [...] }` | `in` |

## Nested Associations

The real power emerges with nested saves. When a parent and its associations save together, errors from any level are collected with accurate paths.

Given these models:

```ruby
class Invoice < ApplicationRecord
  has_many :lines
  accepts_nested_attributes_for :lines

  validates :number, presence: true
end

class Line < ApplicationRecord
  belongs_to :invoice

  validates :quantity, numericality: { greater_than: 0 }
  validates :description, presence: true
end
```

And schemas with `writable: true`:

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

A request that violates multiple validations:

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

Returns errors with precise paths:

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

The path `["invoice", "lines", 1, "quantity"]` tells the client exactly which line failed — the second one (index 1).

## Association Types

Errors are collected from all association types:

### has_many

Each record is indexed:

```json
{
  "path": ["invoice", "lines", 2, "quantity"],
  "pointer": "/invoice/lines/2/quantity"
}
```

### has_one

The association name appears directly:

```json
{
  "path": ["user", "profile", "bio"],
  "pointer": "/user/profile/bio"
}
```

### belongs_to

Foreign key errors use the `_id` suffix:

```json
{
  "path": ["line", "invoice_id"],
  "pointer": "/line/invoice_id"
}
```

## Deep Nesting

Validation works recursively through any depth. If invoices have lines, and lines have adjustments:

```ruby
class Line < ApplicationRecord
  has_many :adjustments
  accepts_nested_attributes_for :adjustments
end

class Adjustment < ApplicationRecord
  validates :reason, presence: true
end
```

An error three levels deep:

```json
{
  "code": "blank",
  "detail": "can't be blank",
  "path": ["invoice", "lines", 0, "adjustments", 2, "reason"],
  "pointer": "/invoice/lines/0/adjustments/2/reason",
  "meta": { "attribute": "reason" }
}
```

## Enabling Nested Validation

For nested validation to work, mark associations as `writable: true` in the schema:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  has_many :lines, writable: true
end
```

Without `writable: true`, the association won't accept nested attributes and validation errors won't be collected from it.

## HTTP Status

Model validation errors return **422 Unprocessable Entity**. This indicates the request was well-formed (passed contract validation) but couldn't be processed due to business rules.

## ActiveRecord Adapter

This behavior is provided by the built-in ActiveRecord adapter. The adapter:

1. Detects when a record has errors after save
2. Walks through the record's associations
3. Recursively collects errors from nested records
4. Builds accurate paths using association names and indexes

If you're using a custom adapter, you may need to implement similar logic for your ORM.
