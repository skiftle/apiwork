---
order: 99
---

# Cheat Sheet

Quick reference for query parameters, request formats, and configuration.

---

## Filtering

### Enable

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :status, filterable: true
  attribute :amount, filterable: true
  attribute :issued_on, filterable: true
  belongs_to :customer, filterable: true
end
```

### Operators

| Operator | Query | SQL |
|----------|-------|-----|
| `eq` | `?filter[status][eq]=sent` | `= 'sent'` |
| `neq` | `?filter[status][neq]=draft` | `!= 'draft'` |
| `gt` | `?filter[amount][gt]=100` | `> 100` |
| `gte` | `?filter[amount][gte]=100` | `>= 100` |
| `lt` | `?filter[amount][lt]=100` | `< 100` |
| `lte` | `?filter[amount][lte]=100` | `<= 100` |
| `between` | `?filter[amount][between][from]=10&filter[amount][between][to]=100` | `BETWEEN 10 AND 100` |
| `in` | `?filter[status][in]=draft,sent` | `IN ('draft', 'sent')` |
| `not_in` | `?filter[status][not_in]=paid` | `NOT IN ('paid')` |
| `null` | `?filter[deleted_at][null]=true` | `IS NULL` |
| `null` | `?filter[deleted_at][null]=false` | `IS NOT NULL` |
| `contains` | `?filter[title][contains]=invoice` | `LIKE '%invoice%'` |
| `not_contains` | `?filter[title][not_contains]=test` | `NOT LIKE '%test%'` |
| `starts_with` | `?filter[number][starts_with]=INV` | `LIKE 'INV%'` |
| `ends_with` | `?filter[email][ends_with]=@acme.com` | `LIKE '%@acme.com'` |
| `matches` | `?filter[code][matches]=^[A-Z]{3}$` | `~ '^[A-Z]{3}$'` |

### Array Syntax for `in`

```
?filter[status][in][]=draft&filter[status][in][]=sent
```

### Operators by Type

Not all operators work with all types:

| Type | Operators |
|------|-----------|
| String | `eq`, `neq`, `in`, `not_in`, `null`, `contains`, `not_contains`, `starts_with`, `ends_with`, `matches` |
| Numeric | `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `between`, `in`, `not_in`, `null` |
| Date/DateTime | `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `between`, `in`, `not_in`, `null` |
| Boolean | `eq`, `null` |
| UUID | `eq`, `in`, `null` |
| Enum | `eq`, `in` |

### Logical Operators

```
# AND (default) - status is sent AND amount > 100
?filter[status][eq]=sent&filter[amount][gt]=100

# AND (explicit)
?filter[AND][0][status][eq]=sent&filter[AND][1][amount][gt]=100

# OR - status is draft OR status is sent
?filter[OR][0][status][eq]=draft&filter[OR][1][status][eq]=sent

# NOT - exclude drafts
?filter[NOT][status][eq]=draft

# Complex: (status=sent AND amount>100) OR (status=draft)
?filter[OR][0][status][eq]=sent&filter[OR][0][amount][gt]=100&filter[OR][1][status][eq]=draft

# Nested: (status=draft OR status=published) AND views > 100
?filter[AND][0][OR][0][status][eq]=draft&filter[AND][0][OR][1][status][eq]=published&filter[AND][1][views][gt]=100
```

### Association Filtering

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  belongs_to :customer, filterable: true  # Enable
end

class CustomerSchema < Apiwork::Schema::Base
  attribute :name, filterable: true
  attribute :country, filterable: true
  belongs_to :account_manager, filterable: true
end

class AccountManagerSchema < Apiwork::Schema::Base
  attribute :region, filterable: true
end
```

```
# Filter invoices by customer name
?filter[customer][name][eq]=Acme

# Filter invoices by customer country
?filter[customer][country][in]=SE,NO,DK

# Deep nesting: invoices where customer's account manager is in EU region
?filter[customer][account_manager][region][eq]=EU
```

---

## Sorting

### Enable

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :issued_on, sortable: true
  attribute :amount, sortable: true
  attribute :number, sortable: true
  belongs_to :customer, sortable: true
end
```

### Syntax

```
# Single field
?sort[issued_on]=desc

# Multiple fields (ordered)
?sort[status]=asc&sort[issued_on]=desc

# Multiple fields (explicit ordering with array notation)
?sort[0][status]=asc&sort[1][issued_on]=desc

# Association field
?sort[customer][name]=asc

# Deep nesting
?sort[customer][account_manager][name]=asc
```

### Values

| Value | Order |
|-------|-------|
| `asc` | Ascending (A-Z, 0-9, oldest first) |
| `desc` | Descending (Z-A, 9-0, newest first) |

---

## Pagination

### Offset (Default)

```ruby
# API-level default
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      default_size 20
      max_size 100
    end
  end
end

# Schema-level override
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      default_size 50
    end
  end
end
```

```
# Page 1 with 20 items
?page[number]=1&page[size]=20

# Page 3
?page[number]=3&page[size]=20
```

**Response:**

```json
{
  "invoices": [...],
  "pagination": {
    "current": 1,
    "next": 2,
    "prev": null,
    "total": 5,
    "items": 100
  }
}
```

### Cursor

```ruby
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
      max_size 100
    end
  end
end
```

```
# First page
?page[size]=20

# Next page (use cursor from response)
?page[after]=eyJpZCI6MTAwfQ&page[size]=20

# Previous page
?page[before]=eyJpZCI6ODF9&page[size]=20
```

**Response:**

```json
{
  "activities": [...],
  "pagination": {
    "next": "eyJpZCI6MTAwfQ",
    "prev": null
  }
}
```

---

## Includes

### Enable

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  belongs_to :customer                         # include: :optional (default)
  has_many :lines, include: :optional
  has_one :payment, include: :always           # Always included
end

class CustomerSchema < Apiwork::Schema::Base
  belongs_to :account_manager
  has_many :contacts
end

class LineSchema < Apiwork::Schema::Base
  belongs_to :product
end
```

### Syntax

```
# Single
?include[customer]=true

# Multiple
?include[customer]=true&include[lines]=true

# Nested (include customer and customer's account_manager)
?include[customer][account_manager]=true

# Deep nesting
?include[lines][product][category]=true

# Multiple nested
?include[customer][account_manager]=true&include[customer][contacts]=true&include[lines][product]=true
```

### Max Depth

Default: 3 levels. Deeper requests return an error.

---

## Nested Writes

### Enable

```ruby
# Schema
class InvoiceSchema < Apiwork::Schema::Base
  has_many :lines, writable: true
  has_one :shipping_address, writable: true
end

class LineSchema < Apiwork::Schema::Base
  attribute :description, writable: true
  attribute :quantity, writable: true
  attribute :unit_price, writable: true
  belongs_to :product, writable: true
end

# Model (required)
class Invoice < ApplicationRecord
  has_many :lines
  has_one :shipping_address
  accepts_nested_attributes_for :lines, allow_destroy: true
  accepts_nested_attributes_for :shipping_address
end

class Line < ApplicationRecord
  belongs_to :product
  accepts_nested_attributes_for :product
end
```

### Create Nested Records

No `id` field = create new record.

```json
{
  "invoice": {
    "number": "INV-001",
    "lines": [
      {
        "description": "Consulting",
        "quantity": 10,
        "unit_price": "150.00"
      },
      {
        "description": "Development",
        "quantity": 20,
        "unit_price": "200.00"
      }
    ],
    "shipping_address": {
      "street": "123 Main St",
      "city": "Stockholm"
    }
  }
}
```

### Update Nested Records

Include `id` = update existing record.

```json
{
  "invoice": {
    "lines": [
      {
        "id": "5",
        "quantity": 15
      }
    ]
  }
}
```

### Delete Nested Records

Include `id` + `_destroy: true`. Requires `allow_destroy: true` in model.

```json
{
  "invoice": {
    "lines": [
      {
        "id": "5",
        "_destroy": true
      }
    ]
  }
}
```

### Mixed Operations

Create, update, and delete in one request:

```json
{
  "invoice": {
    "number": "INV-001-UPDATED",
    "lines": [
      {
        "id": "5",
        "quantity": 15
      },
      {
        "description": "New line",
        "quantity": 1,
        "unit_price": "50.00"
      },
      {
        "id": "3",
        "_destroy": true
      }
    ]
  }
}
```

### Deep Nesting

Create invoice with lines, and each line creates its product:

```json
{
  "invoice": {
    "number": "INV-002",
    "lines": [
      {
        "description": "Custom Widget",
        "quantity": 5,
        "unit_price": "99.00",
        "product": {
          "name": "Widget Pro",
          "sku": "WGT-PRO-001"
        }
      }
    ],
    "shipping_address": {
      "street": "456 Oak Ave",
      "city": "Gothenburg",
      "country": "Sweden"
    }
  }
}
```

### Context-Specific Writing

```ruby
has_many :lines, writable: :create        # Only on create
has_many :lines, writable: :update        # Only on update
has_many :lines, writable: true           # Both create and update
```

---

## Key Format

### Configure

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel  # All requests/responses use camelCase
end
```

### Options

| Value | Input | Output |
|-------|-------|--------|
| `:keep` | `issued_on` | `issued_on` |
| `:camel` | `issuedOn` | `issuedOn` |
| `:kebab` | `issued-on` | `issued-on` |
| `:underscore` | `issued_on` | `issued_on` |

### With camelCase

Query parameters:

```
?filter[issuedOn][gte]=2024-01-01&sort[issuedOn]=desc
```

Request body:

```json
{
  "invoice": {
    "issuedOn": "2024-01-15",
    "shippingAddress": {
      "streetName": "Main St"
    }
  }
}
```

Response:

```json
{
  "invoice": {
    "id": "1",
    "issuedOn": "2024-01-15",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

---

## Path Format

### Configure

```ruby
Apiwork::API.define '/api/v1' do
  path_format :kebab

  resources :line_items        # becomes /api/v1/line-items
  resources :shipping_addresses  # becomes /api/v1/shipping-addresses
end
```

### Options

| Value | Resource | Path |
|-------|----------|------|
| `:keep` | `:line_items` | `/line_items` |
| `:kebab` | `:line_items` | `/line-items` |
| `:camel` | `:line_items` | `/lineItems` |

---

## Error Responses

### Contract Error (400)

Invalid request shape or type:

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_missing",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": {}
    }
  ]
}
```

### Domain Error (422)

Valid request but business rule failed:

```json
{
  "layer": "domain",
  "issues": [
    {
      "code": "unique",
      "detail": "Already taken",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": {}
    }
  ]
}
```

### HTTP Error (4xx/5xx)

```json
{
  "layer": "http",
  "issues": [
    {
      "code": "not_found",
      "detail": "Not found",
      "path": [],
      "pointer": "",
      "meta": {}
    }
  ]
}
```

---

## Generated Types

### TypeScript

```typescript
// Request types
interface InvoiceCreateRequestBody {
  invoice: {
    number: string;
    issuedOn: string;
    lines?: LineNestedPayload[];
  };
}

// Nested payload (discriminated union)
type LineNestedPayload =
  | { _type: 'create'; description: string; quantity: number }
  | { _type: 'update'; id: string; description?: string; _destroy?: boolean };

// Response types
interface InvoiceShowResponse {
  invoice: Invoice;
}

interface InvoiceIndexResponse {
  invoices: Invoice[];
  pagination: OffsetPagination;
}

interface OffsetPagination {
  current: number;
  next: number | null;
  prev: number | null;
  total: number;
  items: number;
}

// Filter types
interface InvoiceFilter {
  status?: { eq?: string; in?: string[] };
  amount?: { gt?: number; lte?: number };
  customer?: CustomerFilter;
}
```

### Zod

```typescript
export const InvoiceCreateRequestBodySchema = z.object({
  invoice: z.object({
    number: z.string(),
    issuedOn: z.string(),
    lines: z.array(LineNestedPayloadSchema).optional(),
  }),
});

export const LineNestedPayloadSchema = z.discriminatedUnion('_type', [
  z.object({ _type: z.literal('create'), description: z.string(), quantity: z.number() }),
  z.object({ _type: z.literal('update'), id: z.string(), description: z.string().optional(), _destroy: z.boolean().optional() }),
]);

export const InvoiceFilterSchema = z.object({
  status: z.object({ eq: z.string().optional(), in: z.array(z.string()).optional() }).optional(),
  amount: z.object({ gt: z.number().optional(), lte: z.number().optional() }).optional(),
  customer: CustomerFilterSchema.optional(),
}).optional();
```

---

#### See also

- [Filtering](guide/core/adapters/standard-adapter/filtering.md) — operators, types, validation
- [Sorting](guide/core/adapters/standard-adapter/sorting.md) — multi-field, associations
- [Pagination](guide/core/adapters/standard-adapter/pagination.md) — offset vs cursor strategies
- [Includes](guide/core/adapters/standard-adapter/includes.md) — eager loading, nesting
- [Associations](guide/core/representations/associations.md) — writable, filterable, polymorphic
- [Error Responses](guide/core/errors/introduction.md) — contract, domain, HTTP layers
