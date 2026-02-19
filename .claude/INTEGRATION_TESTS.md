# Integration Testing

Rules for writing integration tests in this repository.

Integration tests verify cross-domain behavior: full HTTP pipelines, DSL definitions with introspection, and export generation.

For unit test rules, see `UNIT_TESTS.md`.

---

## Commands

```bash
bundle exec rspec spec/integration/                                              # all integration tests
bundle exec rspec spec/integration/adapter/standard/capability/filtering/        # subdirectory
bundle exec rspec spec/integration/adapter/standard/capability/sorting/          # capability
bundle exec rspec spec/integration/adapter/standard/capability/sorting/types_spec.rb    # single file
bundle exec rspec spec/integration/adapter/standard/capability/sorting/types_spec.rb:42 # single test
```

---

## File Structure

```
spec/integration/
├── adapter/
│   ├── configuration_spec.rb
│   ├── custom_adapter_spec.rb
│   ├── serializer/
│   │   ├── error/
│   │   │   └── types_spec.rb
│   │   └── resource/
│   │       └── types_spec.rb
│   ├── standard/
│   │   ├── action_restrictions_spec.rb
│   │   ├── capability/
│   │   │   ├── filtering/
│   │   │   │   ├── association_spec.rb
│   │   │   │   ├── boolean_enum_spec.rb
│   │   │   │   ├── datetime_spec.rb
│   │   │   │   ├── errors_spec.rb
│   │   │   │   ├── logical_spec.rb
│   │   │   │   ├── numeric_spec.rb
│   │   │   │   ├── string_spec.rb
│   │   │   │   ├── temporal_spec.rb
│   │   │   │   └── types_spec.rb
│   │   │   ├── including/
│   │   │   │   ├── request_spec.rb
│   │   │   │   └── types_spec.rb
│   │   │   ├── pagination/
│   │   │   │   ├── cursor_spec.rb
│   │   │   │   ├── offset_spec.rb
│   │   │   │   └── types_spec.rb
│   │   │   ├── sorting/
│   │   │   │   ├── request_spec.rb
│   │   │   │   └── types_spec.rb
│   │   │   └── writing/
│   │   │       ├── body_params_spec.rb
│   │   │       ├── custom_actions_spec.rb
│   │   │       ├── nested_attributes_spec.rb
│   │   │       └── types_spec.rb
│   │   ├── domain_errors_spec.rb
│   │   ├── nested_resources_spec.rb
│   │   ├── preload_spec.rb
│   │   ├── response_format_spec.rb
│   │   ├── singular_resource_spec.rb
│   │   ├── sti_spec.rb
│   │   └── validation_spec.rb
│   └── wrapper/
│       ├── collection/
│       │   └── types_spec.rb
│       └── member/
│           └── types_spec.rb
├── api/
│   ├── concerns_spec.rb
│   ├── controller_context_spec.rb
│   └── routing_spec.rb
├── contract/
│   ├── coercion_spec.rb
│   ├── constraints_spec.rb
│   ├── error_codes_spec.rb
│   ├── imports_spec.rb
│   ├── inheritance_spec.rb
│   ├── types_spec.rb
│   └── validation_spec.rb
├── export/
│   ├── key_format_spec.rb
│   ├── openapi_spec.rb
│   ├── type_merging_spec.rb
│   ├── typescript_spec.rb
│   └── zod_spec.rb
├── introspection/
│   ├── info_spec.rb
│   ├── introspection_spec.rb
│   └── param_types_spec.rb
└── representation/
    ├── associations_spec.rb
    ├── attributes_spec.rb
    ├── encode_decode_spec.rb
    ├── inline_types_spec.rb
    ├── nullable_spec.rb
    ├── polymorphic_spec.rb
    ├── sti_spec.rb
    └── writable_spec.rb
```

### Domain Boundaries

| Domain | Tests | Type | Interface |
|--------|-------|------|-----------|
| `adapter/standard/capability/` | Capability HTTP runtime and generated types | `:request` / `:integration` | HTTP / `.introspect` |
| `adapter/standard/` (root) | Cross-capability runtime (validation, STI, nested resources) | `:request` | HTTP |
| `adapter/serializer/resource/` | Resource object types, attribute mapping, STI unions, enums | `:integration` | `.introspect` |
| `adapter/serializer/error/` | Error types (error, issue, layer) and error response body | `:integration` | `.introspect` |
| `adapter/wrapper/member/` | Member, create, update, custom action, singular response bodies | `:integration` | `.introspect` |
| `adapter/wrapper/collection/` | Collection response body | `:integration` | `.introspect` |
| `adapter/` (root) | Adapter configuration | `:integration` | Ruby API |
| `api/` | API DSL definitions, route generation | `:integration` | Ruby API / Rails routes |
| `contract/` | Type system, imports, inheritance | `:integration` | Ruby API |
| `export/` | TypeScript, Zod, OpenAPI generation | `:integration` | `.generate` |
| `introspection/` | API structure inspection | `:integration` | `.introspect` |
| `representation/` | Serialization, deserialization | `:integration` | `.serialize` / `.deserialize` |

**All HTTP tests belong in `adapter/standard/`.** No HTTP requests in any other domain.

Each capability directory contains two test types:
- `types_spec.rb` — Verifies generated types via introspection (`type: :integration`)
- `request_spec.rb` or feature-specific specs — Verifies HTTP runtime (`type: :request`)

### What We Do NOT Test

| Thing | Reason |
|-------|--------|
| Basic CRUD (create, read, update, delete) | Rails ActiveRecord |
| 404 for missing records | Rails rescue_from |
| Model validations themselves | ActiveRecord::Validations |
| Association creation/deletion | ActiveRecord |

Test only behavior that apiwork implements.

### File Naming

`spec/integration/<domain>/<feature>_spec.rb`

One file per feature. Max 200 lines per file. Subdirectories for complex domains (filtering, pagination, writing, exports).

Capability directories use consistent file names:
- `types_spec.rb` — Generated types verified via introspection
- `request_spec.rb` — HTTP runtime tests (for capabilities with a single request spec)
- Feature-specific names for capabilities with multiple request specs (e.g., `string_spec.rb`, `logical_spec.rb`)

---

## Dummy App Definitions

Representations, contracts, and API definitions in `spec/dummy/` must only specify options that **deviate from defaults**. Never repeat a default value.

### Association defaults (do not specify)

| Option | Default | Only specify when |
|--------|---------|-------------------|
| `include:` | `:optional` | Using `:always` |
| `representation:` | Auto-detected from model | Association name differs from model, or cross-namespace |
| `sortable:` | `false` | Using `true` |
| `filterable:` | `false` | Using `true` |
| `writable:` | `false` | Using `true`, `:create`, or `:update` |
| `deprecated:` | `false` | Using `true` |
| `nullable:` | Auto-detected for `belongs_to` | Overriding the auto-detected value |

```ruby
# Bad — repeats defaults
belongs_to :tag, representation: TagRepresentation, include: :optional
has_many :items, representation: ItemRepresentation, sortable: false

# Good — only non-default options
belongs_to :tag
has_many :items
```

The `representation:` option is auto-detected from the associated model in the same namespace (e.g., `Api::V1::ItemRepresentation` for `:items`). Only specify it when the association name does not match the model name or when the representation lives in a different namespace.

### Declaration ordering

All declarations in dummy app definitions must follow a deterministic order. No exceptions.

**Section order within a representation class:**

| Order | Section | Rule |
|-------|---------|------|
| 1 | Identity DSL | `model`, `root`, `type_name` — alphabetical |
| 2 | Metadata DSL | `abstract!`, `deprecated!`, `description`, `example` — alphabetical |
| 3 | Configuration blocks | `adapter do...end` |
| 4 | `with_options` blocks | Ordered by first attribute name inside the block |
| 5 | Standalone attributes | `attribute` — alphabetical by name |
| 6 | Associations | `belongs_to`, `has_one`, `has_many` — alphabetical by name regardless of type |

**Keyword arguments** within each declaration: alphabetical.

`with_options` is required when 3 or more attributes share identical options. Attributes inside `with_options` follow the same alphabetical rule. Nested `with_options` is allowed.

```ruby
# Bad — 3+ attributes repeat the same options
attribute :balance, filterable: true, sortable: true
attribute :created_at, filterable: true, sortable: true
attribute :id, filterable: true, sortable: true

# Good — with_options eliminates repetition
with_options filterable: true, sortable: true do
  attribute :balance
  attribute :created_at
  attribute :id
end
```

```ruby
# Bad — wrong section order, wrong alphabetical order
class ReceiptRepresentation < Apiwork::Representation::Base
  description 'A billing receipt'
  model Invoice
  root :receipt

  attribute :id, sortable: true, filterable: true
  attribute :number, filterable: true, sortable: true
end

# Good — identity first, then metadata, keyword args alphabetical
class ReceiptRepresentation < Apiwork::Representation::Base
  model Invoice
  root :receipt

  description 'A billing receipt'
  example({ id: 1, number: 'INV-001' })

  attribute :id, filterable: true, sortable: true
  attribute :number, filterable: true, sortable: true
end
```

```ruby
# Bad — attributes and associations not alphabetical
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :name, writable: true
  attribute :email, writable: true

  has_many :services
  has_one :address
end

# Good — alphabetical by name
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :email, writable: true
  attribute :name, writable: true

  has_one :address
  has_many :services
end
```

**Section order within a contract class:**

| Order | Section |
|-------|---------|
| 1 | `abstract!` |
| 2 | `representation` |
| 3 | `identifier` |
| 4 | `import` |
| 5 | Type definitions (`object`, `enum`, `union`, `fragment`) |
| 6 | `action` blocks |

**Section order within an `action` block:**

| Order | Section |
|-------|---------|
| 1 | `summary` |
| 2 | `description` |
| 3 | `tags` |
| 4 | `operation_id` |
| 5 | `deprecated!` |
| 6 | `raises` |
| 7 | `request` |
| 8 | `response` |

Inside `body` and `query` blocks: required params before optional params.

**Section order within an `Apiwork::API.define` block:**

| Order | Section |
|-------|---------|
| 1 | `key_format` / `path_format` |
| 2 | `export` (alphabetical: openapi, typescript, zod) |
| 3 | `info` |
| 4 | `raises` |
| 5 | `adapter` |
| 6 | Type definitions (`object`, `enum`, `union`, `fragment`) |
| 7 | `concern` |
| 8 | `resources` / `resource` |

Inside resources: `member` before `collection` before nested `resources`/`resource`.

HTTP verbs in REST order: `get`, `post`, `patch`, `put`, `delete`.

---

## Two Test Types

### Type A: HTTP Request (`type: :request`)

Tests the full HTTP pipeline through the dummy Rails app. Only in `adapter/standard/`.

```ruby
RSpec.describe 'String filtering', type: :request do
  let!(:customer1) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001', status: :draft) }

  describe 'GET /api/v1/invoices' do
    it 'filters by exact match' do
      get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-001' } } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices'].length).to eq(1)
      expect(body['invoices'][0]['number']).to eq('INV-001')
    end
  end
end
```

### Type B: Definition Pipeline (`type: :integration`)

Tests DSL definitions, introspection, exports, or serialization. No HTTP requests.

```ruby
RSpec.describe 'TypeScript resource generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'Resource types' do
    it 'generates Invoice interface' do
      expect(output).to include('export interface Invoice')
    end
  end
end
```

### Type C: Direct Serialization (`type: :integration`)

Tests representation serialization and deserialization. Uses database records but no HTTP.

```ruby
RSpec.describe 'Representation encode and decode', type: :integration do
  it 'transforms output value through encode lambda' do
    customer1 = PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp')

    result = Api::V1::CustomerRepresentation.serialize(customer1)

    expect(result[:email]).to eq('billing@acme.com')
  end
end
```

---

## File Header

Every test file starts with exactly:

```ruby
# frozen_string_literal: true

require 'rails_helper'
```

No blank line between the magic comment and require.

---

## Naming

### RSpec.describe

| Test type | Format | Example |
|-----------|--------|---------|
| HTTP | String + `type: :request` | `RSpec.describe 'String filtering', type: :request` |
| Non-HTTP | String + `type: :integration` | `RSpec.describe 'TypeScript resource generation', type: :integration` |

Feature names, not class names. `'String filtering'` not `Apiwork::Adapter::Standard::Capability::Filtering`.

### describe (nested)

| Purpose | Format | Example |
|---------|--------|---------|
| HTTP endpoint | String | `describe 'GET /api/v1/invoices'` |
| Feature group | String | `describe 'Resource types'` |

### context

Must start with: `when`, `with`, `without`, `if`.

### it — Naming Formulas

| Category | Pattern | Example |
|----------|---------|---------|
| HTTP success | `'<verbs> by <mechanism>'` | `it 'filters by exact match'` |
| HTTP error | `'returns <status> for <reason>'` | `it 'returns error for invalid input'` |
| HTTP empty | `'returns empty array when no matches found'` | Always this exact string |
| HTTP create | `'creates the <model>'` | `it 'creates the invoice'` |
| HTTP update | `'updates the <model>'` | `it 'updates the invoice'` |
| HTTP delete | `'deletes the <model>'` | `it 'deletes the invoice'` |
| HTTP show | `'returns the <model>'` | `it 'returns the invoice'` |
| HTTP index | `'returns the collection'` | Always this exact string |
| HTTP 422 | `'returns unprocessable entity for invalid input'` | Always this exact string |
| Export includes | `'generates <thing>'` | `it 'generates Invoice interface'` |
| Export matches | `'includes <pattern>'` | `it 'includes invoice_status enum'` |
| Introspection | `'returns <thing>'` | `it 'returns all resource names'` |
| Serialize | `'serializes <thing>'` | `it 'serializes email through encode lambda'` |
| Deserialize | `'deserializes <thing>'` | `it 'deserializes type to class name'` |

---

## Assertions

### HTTP Status

```ruby
expect(response).to have_http_status(:ok)
expect(response).to have_http_status(:created)
expect(response).to have_http_status(:no_content)
expect(response).to have_http_status(:bad_request)
expect(response).to have_http_status(:not_found)
expect(response).to have_http_status(:unprocessable_content)
```

Use symbols, not integers.

### Response Parsing

Always in this exact order:
1. HTTP verb call
2. Blank line
3. Status assertion
4. `body = response.parsed_body`
5. Data assertions

```ruby
it 'filters by exact match' do
  get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-001' } } }

  expect(response).to have_http_status(:ok)
  body = response.parsed_body
  expect(body['invoices'].length).to eq(1)
  expect(body['invoices'][0]['number']).to eq('INV-001')
end
```

### Error Response

```ruby
it 'returns error for unknown filter field' do
  get '/api/v1/invoices', params: { filter: { nonexistent: { eq: 'value' } } }

  expect(response).to have_http_status(:bad_request)
  body = response.parsed_body
  issue = body['issues'].find { |i| i['code'] == 'field_unknown' }
  expect(issue['code']).to eq('field_unknown')
end
```

### Record Count Changes

```ruby
expect do
  post '/api/v1/invoices', as: :json, params: invoice_params
end.to change(Invoice, :count).by(1)
```

### Equality and Collections

```ruby
expect(body['invoices'].length).to eq(2)
expect(numbers).to include('INV-001', 'INV-003')
expect(ids).to contain_exactly(invoice1.id, invoice3.id)
```

Use `contain_exactly` for order-independent, `eq` for exact match with order.

### Boolean

```ruby
expect(body['invoice']['sent']).to be(true)
expect(body['invoice']['sent']).to be(false)
```

Use `be(true)` / `be(false)`, not `be_truthy` / `be_falsey`.

### String Matching (Exports)

```ruby
expect(output).to include('export interface Invoice')
expect(output).to match(/number\??: string/)
```

Use `include` for exact substring, `match` for regex.

### Serialization

```ruby
result = Api::V1::InvoiceRepresentation.serialize(invoice1)
expect(result[:number]).to eq('INV-001')

results = Api::V1::InvoiceRepresentation.serialize([invoice1, invoice2])
expect(results.length).to eq(2)
```

---

## Arrange / Act / Assert

Every `it` block follows AAA with blank lines separating each phase.

**Rule:** One blank line between act (HTTP call) and assert. No blank lines within the assert phase.

---

## Database Record Setup

### Named records (1-5)

Use `let!` (eager) with descriptive data.

```ruby
let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
let!(:invoice2) { Invoice.create!(customer: customer1, due_on: 2.days.from_now, notes: 'Rush delivery', number: 'INV-002', status: :sent) }
let!(:invoice3) { Invoice.create!(customer: customer1, due_on: 1.day.from_now, number: 'INV-003', status: :paid) }
```

### Bulk records (10+)

Use `before` with numbered data.

```ruby
before do
  25.times do |i|
    Invoice.create!(
      customer: customer1,
      due_on: (25 - i).days.from_now,
      number: "INV-#{format('%03d', i + 1)}",
      status: i.even? ? :draft : :sent,
    )
  end
end
```

### How many records?

| Scenario | Count |
|----------|-------|
| Filtering tests | 3 records (vary the filtered attribute) |
| Pagination tests | 25 records (bulk, `before` block) |
| Association tests | 2-3 parent + 2-3 children |
| Empty collection tests | 0 records (no setup) |

---

## Test Data Registry

These are the **exact** models and values to use. Copy-paste, do not invent.

### Invoice (primary model)

```ruby
let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
let!(:invoice2) { Invoice.create!(customer: customer1, due_on: 2.days.from_now, notes: 'Rush delivery', number: 'INV-002', status: :sent) }
let!(:invoice3) { Invoice.create!(customer: customer1, due_on: 1.day.from_now, number: 'INV-003', status: :paid) }
```

### Item (nested under Invoice)

```ruby
let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
let!(:item2) { Item.create!(description: 'Software license', invoice: invoice1, quantity: 1, unit_price: 500.00) }
let!(:item3) { Item.create!(description: 'Support contract', invoice: invoice2, quantity: 1, unit_price: 200.00) }
```

### Adjustment (nested under Item)

```ruby
let!(:adjustment1) { Adjustment.create!(amount: -150.00, description: 'Discount 10%', item: item1) }
let!(:adjustment2) { Adjustment.create!(amount: 50.00, description: 'Rush fee', item: item1) }
```

### Customer (STI)

```ruby
let!(:customer1) { PersonCustomer.create!(born_on: '1985-06-15', email: 'anna@example.com', name: 'Anna Svensson') }
let!(:customer2) { CompanyCustomer.create!(email: 'billing@acme.com', industry: 'Technology', name: 'Acme Corp', registration_number: 'SE556000-0000') }
```

### Address (has_one on Customer)

```ruby
let!(:address1) { Address.create!(city: 'Stockholm', country: 'SE', customer: customer1, street: '123 Main St', zip: '111 22') }
```

### Payment

```ruby
let!(:payment1) { Payment.create!(amount: 1500.00, customer: customer1, invoice: invoice1, method: :credit_card, reference: 'ch_abc123', status: :completed) }
let!(:payment2) { Payment.create!(amount: 500.00, customer: customer1, invoice: invoice2, method: :bank_transfer, reference: 'bt_def456', status: :pending) }
```

### Service (nested under Customer)

```ruby
let!(:service1) { Service.create!(customer: customer1, description: 'Monthly consulting', name: 'Consulting') }
```

### Attachment (nested under Invoice)

```ruby
let!(:attachment1) { Attachment.create!(filename: 'document.pdf', invoice: invoice1) }
let!(:attachment2) { Attachment.create!(filename: 'image.png', invoice: invoice1) }
```

### Tag + Tagging (polymorphic)

```ruby
let!(:tag1) { Tag.create!(name: 'Priority', slug: 'priority') }
let!(:tag2) { Tag.create!(name: 'Urgent', slug: 'urgent') }
let!(:tagging1) { Tagging.create!(tag: tag1, taggable: invoice1) }
```

### Activity (cursor pagination)

```ruby
let!(:activity1) { Activity.create!(action: 'invoice.created', target: invoice1) }
let!(:activity2) { Activity.create!(action: 'invoice.sent', read: true, target: invoice1) }
let!(:activity3) { Activity.create!(action: 'payment.received', target: invoice2) }
```

### Profile (singular resource)

```ruby
let!(:profile1) { Profile.create!(bio: 'Billing administrator', email: 'admin@billing.test', name: 'Admin', timezone: 'Europe/Stockholm') }
```

---

## adapter/ Test Coverage

### Resource Serializer Types (`adapter/serializer/resource/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Resource object | type :object, includes all attributes and associations |
| Attribute types | string, integer, boolean, date, datetime mapping |
| Nullable | nullable/non-nullable detection from schema |
| Enum attributes | enum reference on enum columns |
| Association references | has_many as array of references, belongs_to as reference |
| STI union | type :union, discriminator :type, person/company variants |
| STI variants | inherited + own attributes per variant |
| Enum types | invoice_status, payment_method, payment_status values |

### Error Serializer Types (`adapter/serializer/error/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Error object | type :object, issues + layer shape |
| Issue object | code, detail, meta, path, pointer fields |
| Layer enum | http, contract, domain values |
| Error response body | type :object, extends :error |

### Member Wrapper Types (`adapter/wrapper/member/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Member response body | type :object, singular root key as reference, optional meta |
| Create response body | singular root key as reference, optional meta |
| Update response body | singular root key as reference |
| Custom action response | send_invoice, void, search, bulk_create bodies |
| Singular resource | singular root key as reference |

### Collection Wrapper Types (`adapter/wrapper/collection/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Collection response body | type :object, plural root key as array of references, optional meta |
| Singular resource | singular root key as reference |

### Capability: Filtering

#### HTTP Runtime (`capability/filtering/`)

| File | Operators | Model |
|------|-----------|-------|
| `string_spec.rb` | eq, contains, starts_with, ends_with, in, null | Invoice (number, notes) |
| `numeric_spec.rb` | eq, gt, gte, lt, lte, between, in, null | Item (quantity, unit_price) |
| `temporal_spec.rb` | eq, gt, lt, between, null (date, datetime, time) | Invoice (due_on, created_at), Profile (preferred_contact_time) |
| `boolean_enum_spec.rb` | boolean eq/null, enum eq/in, enum value_invalid | Invoice (sent, status) |
| `association_spec.rb` | Direct and nested association filters | Item filter by invoice.number |
| `logical_spec.rb` | AND, OR, NOT, nested combinations | Invoice (status, sent) |
| `datetime_spec.rb` | datetime-specific operators and edge cases | Invoice (created_at) |
| `errors_spec.rb` | field_unknown, operator_invalid, type mismatch | Invoice |

#### Generated Types (`capability/filtering/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Filter object | type :object, operator params per attribute |
| Logical operators | AND (array of self-references), OR, NOT |
| Shorthand unions | string shorthand as union (string \| object) |
| Nullable filters | null operator as boolean |
| Enum filters | enum reference on filter params |
| Boolean filters | eq as boolean param |
| Association filters | nested filter object references |
| Global types | string/numeric/date/datetime/boolean/enum filter objects |
| Between type | lower + upper params |

### Capability: Sorting

#### HTTP Runtime (`capability/sorting/request_spec.rb`)

| Tests |
|-------|
| asc, desc, multi-field, association sort, error cases |

#### Generated Types (`capability/sorting/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Sort object | type :object, sort_direction references per sortable attribute |
| Association sort | nested sort object references |
| Sort direction enum | asc, desc values |

### Capability: Pagination

#### HTTP Runtime (`capability/pagination/`)

| File | Tests |
|------|-------|
| `offset_spec.rb` | page number/size, metadata (current/next/prev/total/items), out of range, max size |
| `cursor_spec.rb` | first page, after/before cursors, last page, cursor_invalid error |

#### Generated Types (`capability/pagination/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Offset page | type :object, number (integer), size (integer), both optional |
| Cursor page | type :object, after (string), before (string), size (integer), all optional |
| Offset pagination metadata | type :object, current_page, next_page, prev_page, total_pages, total_items |
| Cursor pagination metadata | type :object, has_next_page, has_prev_page, start_cursor, end_cursor |

### Capability: Including

#### HTTP Runtime (`capability/including/request_spec.rb`)

| Tests |
|-------|
| optional omitted, optional requested, always-included, multiple, nested, unknown error |

#### Generated Types (`capability/including/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Include object | type :object, params per includable association |
| Leaf associations | boolean params |
| Nested associations | union (boolean \| reference to nested include object) |
| Nested include object | type :object with nested association params |

### Capability: Writing

#### HTTP Runtime (`capability/writing/`)

| File | Tests |
|------|-------|
| `body_params_spec.rb` | writable fields, unknown field rejection, partial update, decode transformer |
| `nested_attributes_spec.rb` | create/update/delete nested, OP field, mixed ops, deep nesting |
| `custom_actions_spec.rb` | member body, collection query, collection body, unknown field error, defaults |

#### Generated Types (`capability/writing/types_spec.rb`)

| Group | Tests |
|-------|-------|
| Create payload | type :object, writable attributes, required/optional, enum references, excludes non-writable |
| Update payload | type :object, all writable attributes optional |
| Nested payload union | type :union, OP discriminator, create/update/delete variants |
| Nested create payload | OP literal 'create', optional id, writable fields |
| Nested update payload | OP literal 'update', optional id, writable fields |
| Nested delete payload | only OP and id, id required |
| Deep nesting | items adjustments nested payload chain |
| STI payloads | customer create/update as union with type discriminator |
| Writable association | items as optional array of nested payload references |

### Validation

| File | Tests |
|------|-------|
| `validation_spec.rb` | contract 400 (field_missing, type_invalid, field_unknown, multiple, empty body), model 422, error format (issues structure, pointer), nested error paths, update validation |

### Other Runtime

| File | Tests |
|------|-------|
| `sti_spec.rb` | Create person/company via type, update preserves type, index mixed types, delete STI |
| `singular_resource_spec.rb` | Show/create/update/destroy without :id |
| `nested_resources_spec.rb` | Parent scoping, cross-parent isolation, create under parent, non-nested coexistence |
| `action_restrictions_spec.rb` | only: restricts actions, except: restricts actions |
| `domain_errors_spec.rb` | Domain-specific error handling |
| `preload_spec.rb` | Attribute preload associations, capability runner preloads |
| `response_format_spec.rb` | Singular/plural root key, custom root key, pagination metadata, empty collection, key_format :camel, path_format :kebab |

---

## Export Test Coverage

### TypeScript (`typescript_spec.rb`)

| Tests |
|-------|
| Invoice interface, InvoiceStatus enum type, action request body type, Payment interface |

### Zod (`zod_spec.rb`)

| Tests |
|-------|
| Zod import, InvoiceSchema z.object, InvoiceStatusSchema z.enum, request body schema, response body schema |

### OpenAPI (`openapi_spec.rb`)

| Tests |
|-------|
| OpenAPI version, info title, invoice paths, component schemas, error responses for raises, 422 for create, 204 for destroy |

### Cross-cutting

| File | Tests |
|------|-------|
| `key_format_spec.rb` | TypeScript/Zod/OpenAPI all apply :camel consistently |
| `type_merging_spec.rb` | Declaration merging, metadata last-wins |

---

## Export Test Template

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript resource generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  describe 'Resource types' do
    it 'generates Invoice interface' do
      expect(output).to include('export interface Invoice')
    end
  end
end
```

### Rules

1. Use `type: :integration`
2. `let(:path)` for the API path
3. `let(:generator)` for the export instance
4. `let(:output)` for the generated string
5. Assert with `include` for string presence, `match` for patterns

---

## API Definition Paths

Integration tests that call `Apiwork::API.define` must use unique, deterministic base paths.

**Formula:** `/integration/<feature>-<scenario>`

---

## Canonical Test World

Tests must use a **fixed vocabulary**.

| Domain | Terms |
|--------|-------|
| Billing | `invoice`, `item`, `items`, `adjustment`, `customer`, `payment`, `address`, `receipt`, `service` |
| Framework | `api`, `resource`, `action`, `type`, `enum`, `adapter`, `capabilities`, `introspection`, `export` |
| **Forbidden** | `foo`, `bar`, `baz`, `test`, `example`, `sample`, `post`, `comment`, `user` |

### Test values by purpose

| Purpose | Value |
|---------|-------|
| Invoice number | `'INV-001'`, `'INV-002'`, `'INV-003'` |
| Invoice notes | `'Net 30 payment terms'`, `'Rush delivery'`, `'Prepaid quarterly'` |
| Item description | `'Consulting hours'`, `'Software license'`, `'Support contract'` |
| Adjustment description | `'Discount 10%'`, `'Rush fee'`, `'Early payment bonus'` |
| Person name | `'Anna Svensson'`, `'Erik Lindberg'` |
| Company name | `'Acme Corp'`, `'Beta Inc'` |
| Email | `'anna@example.com'`, `'billing@acme.com'` |
| Phone | `'+1-555-0100'` |
| Industry | `'Technology'`, `'Consulting'` |
| Registration number | `'SE556000-0000'` |
| Payment amount | `1500.00`, `500.00` |
| Payment reference | `'ch_abc123'`, `'bt_def456'` |
| Street | `'123 Main St'`, `'456 Oak Ave'` |
| City | `'Stockholm'`, `'Gothenburg'` |
| Zip | `'111 22'`, `'411 01'` |
| Country | `'SE'` |
| Tag name | `'Priority'`, `'Urgent'` |
| Tag slug | `'priority'`, `'urgent'` |
| Activity action | `'invoice.created'`, `'invoice.sent'`, `'payment.received'` |
| Filename | `'document.pdf'`, `'image.png'` |
| Profile name | `'Admin'` |
| Profile email | `'admin@billing.test'` |
| Timezone | `'Europe/Stockholm'` |

### Record attribute order

Alphabetical by key name. Always.

### Variable names

Numbered: `invoice1`, `invoice2`, `invoice3`. Never `first_invoice` or `paid_invoice`.

---

## Forbidden

| Pattern | Why |
|---------|-----|
| `subject` | Ambiguous, hides what is tested |
| `shared_examples` | Makes tests harder to read locally |
| `shared_context` | Use `let` or helpers instead |
| `instance_variable_get` | Use semi-public methods |
| `allow(...).to receive(...)` on internals | Test behavior, not calls |
| `before(:all)` | Use `let!` or `before` (per-example) |
| `after` blocks | Clean up should be automatic (transactional fixtures) |
| Nested `context` deeper than 2 levels | Flatten or split file |
| `described_class` | Use the actual class or string |
| `respond_to` assertions | Assert specific values |
| `be_present` / `be_a(Hash)` for structures | Verify specific keys and values |
| `if` in assertions | Split into separate `it` blocks |
| Comments | Structure and names carry meaning |
| Testing Rails behavior | CRUD, 404, model validations |

---

## Checklist

Before an integration test file is done:

1. File starts with `# frozen_string_literal: true` + `require 'rails_helper'`
2. `RSpec.describe` uses string (not class constant) + `type: :request` or `type: :integration`
3. `let!` (eager) for all database records
4. `describe` groups by HTTP method + path, or by feature group
5. `context` blocks match meaningful variation (`when`, `with`, `without`, `if`)
6. `it` names follow the naming formula table
7. No `subject`, no `shared_examples`, no `shared_context`
8. No comments
9. AAA structure with blank lines
10. Test data from the registry (no invented values)
11. Record attributes in alphabetical order
12. Max 200 lines per file
13. Verify specific values, not `be_present` / `be_a`
14. No HTTP requests outside `adapter/standard/`
15. No testing Rails framework behavior
16. `bundle exec rubocop -A` passes
17. `bundle exec rspec <file>` passes
