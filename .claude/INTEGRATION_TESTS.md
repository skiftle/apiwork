# Integration Testing

Rules for writing integration tests in this repository.

Integration tests verify cross-domain behavior: full HTTP pipelines, DSL definitions with introspection, and export generation.

For unit test rules, see `UNIT_TESTS.md`.

---

## Commands

```bash
bundle exec rspec spec/integration/                         # all integration tests
bundle exec rspec spec/integration/adapter/filtering_spec.rb  # single file
bundle exec rspec spec/integration/adapter/filtering_spec.rb:42  # single test
```

---

## File Structure

```
spec/integration/
├── adapter/          # Filtering, sorting, pagination, includes, preload, configuration
├── api/              # CRUD, nested resources, singular resource, routing, path format
├── contract/         # Custom actions, types, imports, inheritance, validation
├── export/           # OpenAPI, TypeScript, Zod generation
├── introspection/    # API.introspect, Contract.introspect
└── representation/   # Encode/decode, nested attributes, STI, polymorphic, associations
```

### File Naming

`spec/integration/<domain>/<feature>_spec.rb`

One file per feature. Max 200 lines per file.

---

## Two Test Types

### Type A: HTTP Request (`type: :request`)

Tests the full HTTP pipeline through the dummy Rails app. Uses database records, HTTP verbs, and JSON response parsing.

```ruby
RSpec.describe 'Filtering', type: :request do
  let!(:customer1) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }

  describe 'GET /api/v1/invoices' do
    it 'filters by exact match' do
      get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-001' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(1)
      expect(json['invoices'][0]['number']).to eq('INV-001')
    end
  end
end
```

### Type B: Definition Pipeline (`type: :integration`)

Tests inline `API.define` with introspection or export. No HTTP requests, no database records.

```ruby
RSpec.describe 'TypeScript Generation', type: :integration do
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
| HTTP | String + `type: :request` | `RSpec.describe 'Filtering', type: :request` |
| Non-HTTP | String + `type: :integration` | `RSpec.describe 'TypeScript Generation', type: :integration` |

Feature names, not class names. `'Filtering'` not `Apiwork::Adapter::Standard::Capability::Filtering`.

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
| HTTP 404 | `'returns not found for nonexistent <model>'` | `it 'returns not found for nonexistent invoice'` |
| HTTP 422 | `'returns unprocessable entity for invalid input'` | Always this exact string |
| Export includes | `'generates <thing>'` | `it 'generates Invoice interface'` |
| Export matches | `'includes <pattern>'` | `it 'includes invoice_status enum'` |
| Introspection | `'returns <thing>'` | `it 'returns all resource names'` |

---

## Assertions

### HTTP Status

```ruby
expect(response).to have_http_status(:ok)
expect(response).to have_http_status(:created)
expect(response).to have_http_status(:bad_request)
expect(response).to have_http_status(:not_found)
expect(response).to have_http_status(:unprocessable_entity)
```

Use symbols, not integers.

### Response Parsing

Always in this exact order:
1. HTTP verb call
2. Blank line
3. Status assertion
4. `json = JSON.parse(response.body)`
5. Data assertions

```ruby
it 'returns the invoice' do
  get "/api/v1/invoices/#{invoice1.id}"

  expect(response).to have_http_status(:ok)
  json = JSON.parse(response.body)
  expect(json['invoice']['number']).to eq('INV-001')
end
```

### Error Response

```ruby
it 'returns error for invalid input' do
  get '/api/v1/invoices', params: { filter: { invalid_field: { eq: 'value' } } }

  expect(response).to have_http_status(:bad_request)
  json = JSON.parse(response.body)
  expect(json['issues']).to be_present
end
```

For specific error details:

```ruby
it 'returns validation error with pointer' do
  post '/api/v1/invoices', as: :json, params: { invoice: { notes: 'Missing number' } }

  expect(response).to have_http_status(:unprocessable_entity)
  json = JSON.parse(response.body)
  issue = json['issues'].first
  expect(issue['code']).to eq('required')
  expect(issue['pointer']).to eq('/invoice/number')
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
expect(json['invoices'].length).to eq(2)
expect(numbers).to include('INV-001', 'INV-003')
expect(ids).to contain_exactly(invoice1.id, invoice3.id)
```

Use `contain_exactly` for order-independent, `eq` for exact match with order.

### Boolean

```ruby
expect(json['invoice']['sent']).to be(true)
expect(json['invoice']['sent']).to be(false)
```

Use `be(true)` / `be(false)`, not `be_truthy` / `be_falsey`.

### String Matching (Exports)

```ruby
expect(output).to include('export interface Invoice')
expect(output).to match(/number\??: string/)
```

Use `include` for exact substring, `match` for regex.

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
| Basic CRUD tests | 3 records |
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

## Integration Test Formulas

### CRUD Endpoint

For each CRUD action, test these scenarios mechanically:

| Action | Required tests |
|--------|---------------|
| `index` | returns collection, respects pagination, returns empty when no records |
| `show` | returns record, returns 404 for nonexistent |
| `create` | creates record (change count by 1), returns 422 for invalid input |
| `update` | updates record, returns 404, returns 422 |
| `destroy` | deletes record (change count by -1), returns 404 |

### Capability (filtering, sorting, pagination)

| Capability | Required tests |
|------------|---------------|
| Filtering | 1 per operator used (eq, contains, gt, in, etc.) + invalid field + invalid operator |
| Sorting | ascending + descending + invalid field |
| Pagination | first page + last page + page size + out of range |
| Including | valid include + nested include + invalid include |

### Export

| Export type | Required tests |
|-------------|---------------|
| TypeScript | generates interfaces for each resource + generates enum types + generates request/response types |
| Zod | generates schemas for each resource + generates enum schemas + generates action schemas |
| OpenAPI | generates paths + generates schemas + valid YAML structure |

---

## Export Test Template

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript Generation', type: :integration do
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
14. `bundle exec rubocop -A` passes
15. `bundle exec rspec <file>` passes
