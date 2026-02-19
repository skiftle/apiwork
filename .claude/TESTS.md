# Testing

Shared rules for all tests in this repository.

For method-level unit test patterns, see `UNIT_TESTS.md`.
For feature coverage and integration patterns, see `INTEGRATION_TESTS.md`.

---

## The Rule

**Where does the test belong?**

```
Does the test need Rails routing/controllers?
├── Yes → spec/integration/  (type: :request or type: :integration)
└── No  → spec/apiwork/      (unit test)
```

This is the only rule. Everything else follows from it.

### Examples

| Test | Location | Why |
|------|----------|-----|
| `Contract::Object` validation | `spec/apiwork/contract/` | Pure Ruby, no Rails |
| `Schema::Attribute` mapping | `spec/apiwork/schema/` | Pure Ruby, no Rails |
| `Export::TypeMapper` | `spec/apiwork/export/` | Pure Ruby, no Rails |
| `Adapter::Filter` building | `spec/apiwork/adapter/` | Uses AR but not HTTP |
| GET /api/v1/invoices | `spec/integration/adapter/` | HTTP request |
| TypeScript full pipeline | `spec/integration/export/` | Needs dummy app data |
| Representation serialization | `spec/integration/representation/` | Needs DB records |

### Unsure? Choose integration.

---

## Commands

```bash
bundle exec rspec                                    # all tests
bundle exec rspec spec/apiwork/issue_spec.rb         # single unit test
bundle exec rspec spec/integration/filtering_spec.rb # single integration test
bundle exec rspec spec/integration/filtering_spec.rb:42  # single example
bundle exec rubocop -A                               # lint + auto-fix
```

---

## File Structure

```
spec/
├── apiwork/       # Unit tests (mirrors lib/apiwork/)
├── integration/   # Cross-domain tests
├── dummy/         # Test Rails app
└── support/       # Helpers
```

### Mapping

| Source | Test |
|--------|------|
| `lib/apiwork/issue.rb` | `spec/apiwork/issue_spec.rb` |
| `lib/apiwork/contract/object.rb` | `spec/apiwork/contract/object_spec.rb` |
| Cross-domain behavior | `spec/integration/<domain>/<feature>_spec.rb` |

---

## File Header

Every test file starts with exactly:

```ruby
# frozen_string_literal: true

require 'rails_helper'
```

No blank line between the magic comment and require.

---

## Arrange / Act / Assert

Every `it` block follows AAA with blank lines separating each phase.

### Arrange + Assert (no separate act)

```ruby
it 'returns :domain' do
  error = described_class.new(issue)

  expect(error.layer).to eq(:domain)
end
```

### Arrange + Act + Assert

```ruby
it 'filters by exact match' do
  get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-001' } } }

  expect(response).to have_http_status(:ok)
  body = response.parsed_body
  expect(body['invoices'].length).to eq(1)
end
```

**Rule:** One blank line between phases. No blank lines within the assert phase.

---

## Naming

### RSpec.describe

| Test type | Format | Example |
|-----------|--------|---------|
| Unit | Class constant | `RSpec.describe Apiwork::Issue` |
| Integration (HTTP) | String + `type: :request` | `RSpec.describe 'String filtering', type: :request` |
| Integration (non-HTTP) | String + `type: :integration` | `RSpec.describe 'TypeScript generation', type: :integration` |

### describe (nested)

| Purpose | Format | Example |
|---------|--------|---------|
| Instance method | `'#method'` | `describe '#pointer'` |
| Class method | `'.method'` | `describe '.find'` |
| HTTP endpoint | String | `describe 'GET /api/v1/invoices'` |
| Feature group | String | `describe 'Resource types'` |

### context

Must start with: `when`, `with`, `without`, `if`.

```ruby
context 'when the path is empty' do
context 'with valid datetime values' do
context 'without filters' do
```

### it

Short, factual, present tense. One outcome per `it`.

```ruby
# Good
it 'returns a hash'
it 'filters by exact match'
it 'raises DomainError'

# Bad — multiple behaviors
it 'validates and saves the record'
```

---

## Assertions

### Equality

```ruby
expect(issue.code).to eq(:required)
expect(issue.path).to eq([:user, :name])
expect(result.length).to eq(2)
```

### Boolean

```ruby
expect(representation_class.abstract?).to be(true)
expect(representation_class.abstract?).to be(false)
```

Use `be(true)` / `be(false)`, not `be_truthy` / `be_falsey`.

### Nil / Empty / Present

```ruby
expect(definition.element).to be_nil
expect(result.issues).to be_empty
expect(json['issues']).to be_present
```

### Collections

```ruby
expect(result.length).to eq(2)
expect(numbers).to include('INV-001', 'INV-003')
expect(ids).to contain_exactly(invoice1.id, invoice3.id)
```

Use `contain_exactly` for order-independent, `eq` for exact match with order.

### Type

```ruby
expect(output).to be_a(String)
expect(definition.element).to be_a(Apiwork::Representation::Element)
```

### Errors

```ruby
expect do
  Class.new(described_class) do
    resource_serializer 'NotAClass'
  end
end.to raise_error(Apiwork::ConfigurationError, /must be a Serializer class/)
```

### String Matching

```ruby
expect(output).to include('export interface Invoice')
expect(output).to match(/number\??: string/)
```

Use `include` for exact substring, `match` for regex.

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

---

## Multiple Assertions per `it`

### When allowed

Multiple assertions test **one object's state after one action**:

```ruby
it 'creates an issue with required attributes' do
  issue = described_class.new(:required, 'Field is required')

  expect(issue.code).to eq(:required)
  expect(issue.detail).to eq('Field is required')
  expect(issue.path).to eq([])
  expect(issue.meta).to eq({})
end
```

### When to split

Different **inputs** or **behaviors** require separate `it` blocks:

```ruby
it 'returns JSON pointer format' do
  issue = described_class.new(:required, 'Required', path: [:user, :email])

  expect(issue.pointer).to eq('/user/email')
end

it 'handles array indices' do
  issue = described_class.new(:required, 'Required', path: [:items, 0, :name])

  expect(issue.pointer).to eq('/items/0/name')
end
```

### Decision

```
Same object, same action, multiple properties?  → Same it
Different input values for same method?          → Separate it
Different method calls?                          → Separate it
```

---

## `let` vs Inline

```
1. Same object used in 3+ it blocks in same describe?  → let
2. Database record that must exist before test?         → let!
3. Object used in 1-2 it blocks?                       → inline in the it block
4. Setup shared across 3+ it blocks?                   → before
5. Bulk data (10+ records)?                             → before with loop
```

Never use `let` at the `RSpec.describe` level in unit tests. Keep `let` as close to its usage as possible.

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
| Comments | Structure and names carry meaning |
| `foo`, `bar`, `baz`, `test`, `example` | Use domain vocabulary |

---

## Intermediate Variables

```
Accessing .first on a collection?                → Extract: `issue = json['issues'].first`
Mapping a collection for comparison?             → Extract: `numbers = result.map { |r| r[:number] }`
Simple method call on test object?               → Inline: `expect(issue.pointer).to eq(...)`
```

---

## Test Data Registry

These are the **exact** models and values to use. Copy-paste, do not invent.

Number variables only when there are multiple instances (e.g., `invoice1`, `invoice2`). Single instances use plain names (e.g., `customer`, `service`).

### Canonical Test World

| Domain | Terms |
|--------|-------|
| Billing | `invoice`, `item`, `items`, `adjustment`, `customer`, `payment`, `address`, `receipt`, `service` |
| Framework | `api`, `resource`, `action`, `schema`, `type`, `enum`, `adapter`, `capabilities`, `introspection`, `export` |
| **Forbidden** | `foo`, `bar`, `baz`, `test`, `example`, `sample`, `post`, `comment`, `user` |

### Invoice (primary model)

```ruby
let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
let!(:invoice1) { Invoice.create!(customer:, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
let!(:invoice2) { Invoice.create!(customer:, due_on: 2.days.from_now, notes: 'Rush delivery', number: 'INV-002', status: :sent) }
let!(:invoice3) { Invoice.create!(customer:, due_on: 1.day.from_now, number: 'INV-003', status: :paid) }
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
let!(:address) { Address.create!(city: 'Stockholm', country: 'SE', customer: customer1, street: '123 Main St', zip: '111 22') }
```

### Payment

```ruby
let!(:payment1) { Payment.create!(amount: 1500.00, customer:, invoice: invoice1, method: :credit_card, reference: 'ch_abc123', status: :completed) }
let!(:payment2) { Payment.create!(amount: 500.00, customer:, invoice: invoice2, method: :bank_transfer, reference: 'bt_def456', status: :pending) }
```

### Service (nested under Customer)

```ruby
let!(:service) { Service.create!(customer:, description: 'Monthly consulting', name: 'Consulting') }
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
let!(:tagging) { Tagging.create!(tag: tag1, taggable: invoice1) }
```

### Activity (cursor pagination)

```ruby
let!(:activity1) { Activity.create!(action: 'invoice.created', target: invoice1) }
let!(:activity2) { Activity.create!(action: 'invoice.sent', read: true, target: invoice1) }
let!(:activity3) { Activity.create!(action: 'payment.received', target: invoice2) }
```

### Profile (singular resource)

```ruby
let!(:profile) { Profile.create!(bio: 'Billing administrator', email: 'admin@billing.test', name: 'Admin', timezone: 'Europe/Stockholm') }
```

### Bulk records (pagination)

```ruby
before do
  25.times do |i|
    Invoice.create!(
      customer:,
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

## String Values by Purpose

| Purpose | Value |
|---------|-------|
| Person name | `'Anna Svensson'`, `'Erik Lindberg'` |
| Email | `'anna@example.com'`, `'billing@acme.com'` |
| Company | `'Acme Corp'`, `'Beta Inc'` |
| Invoice number | `'INV-001'`, `'INV-002'`, `'INV-003'` |
| Notes | `'Net 30 payment terms'`, `'Rush delivery'`, `'Prepaid quarterly'` |
| Item description | `'Consulting hours'`, `'Software license'`, `'Support contract'` |
| Adjustment description | `'Discount 10%'`, `'Early payment bonus'`, `'Rush fee'` |
| Payment reference | `'ch_abc123'`, `'bt_def456'` |
| Tag name | `'Priority'`, `'Urgent'` |
| Tag slug | `'priority'`, `'urgent'` |
| Filename | `'document.pdf'`, `'image.png'` |
| Street | `'123 Main St'`, `'456 Oak Ave'` |
| City | `'Stockholm'`, `'Gothenburg'` |
| Industry | `'Technology'`, `'Consulting'` |
| Registration number | `'SE556000-0000'` |
| Activity action | `'invoice.created'`, `'invoice.sent'`, `'payment.received'` |
| Profile name | `'Admin'` |
| Profile email | `'admin@billing.test'` |
| Timezone | `'Europe/Stockholm'` |

---

## Numeric Values

| Purpose | Value |
|---------|-------|
| Positive integer | `42` |
| Zero | `0` |
| Negative integer | `-1` |
| Decimal | `19.99` |
| Count | `25` (for bulk) |
| Payment amount | `1500.00`, `500.00` |
| Item quantity | `10`, `1` |
| Unit price | `150.00`, `500.00`, `200.00` |
| Adjustment amount | `-150.00`, `50.00` |

---

## Time Values

| Purpose | Value |
|---------|-------|
| Past (days) | `3.days.ago`, `2.days.ago`, `1.day.ago` |
| Future (days) | `3.days.from_now`, `2.days.from_now`, `1.day.from_now` |
| Past (hours) | `1.hour.ago` |
| Date string | `'1990-01-15'`, `'1985-06-15'` |
| Datetime string | `'2024-01-15T10:30:00Z'` |

---

## Record Attribute Order

Alphabetical by key name. Always.

```ruby
Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft)
```

---

## Variable Names

Numbered: `invoice1`, `invoice2`, `invoice3`. Never `first_invoice` or `paid_invoice`.

---

## Issue Values (Unit Tests)

| Field | Primary value | Secondary value | Empty/default value |
|-------|--------------|-----------------|---------------------|
| `code` | `:required` | `:type_invalid` | `:invalid` |
| `detail` | `'Field is required'` | `'Expected string'` | `'Invalid request'` |
| `path` | `[:user, :email]` | `[:items, 0, :name]` | `[]` |
| `meta` | `{ field: :email }` | `{ expected: 'string', got: 'integer' }` | `{}` |

---

## Error Values (Unit Tests)

| Field | Value |
|-------|-------|
| `issue` | `Apiwork::Issue.new(:invalid, 'is invalid', path: [:amount])` |
| `status` | `422` |
| `error_code` | `Apiwork::ErrorCode.find!(:unprocessable_entity)` |

---

## DSL Class Setter Test Values (Unit Tests)

| Test | Valid class | Invalid (non-class) | Invalid (wrong hierarchy) |
|------|-----------|---------------------|--------------------------|
| `resource_serializer` | `Serializer::Resource::Default` | `'NotAClass'` | `String` |
| `error_serializer` | `Serializer::Error::Default` | `'NotAClass'` | `String` |
| `member_wrapper` | `Wrapper::Member::Default` | `'NotAClass'` | `String` |
| `collection_wrapper` | `Wrapper::Collection::Default` | `'NotAClass'` | `String` |
| `error_wrapper` | `Wrapper::Error::Default` | `'NotAClass'` | `String` |

Non-class argument is always `'NotAClass'`. Wrong hierarchy is always `String`.

---

## API Definition Paths

Tests that call `Apiwork::API.define` must use unique, deterministic base paths.

| Test type | Formula | Example |
|-----------|---------|---------|
| Unit | `/unit/<class>-<method>[-<variant>]` | `/unit/base-adapter` |
| Integration | `/integration/<feature>-<scenario>` | `/integration/filtering-string` |

---

## Global State

Unit tests must not mutate global state with keys that exist in production code or other tests.

### Decision Tree

```
1. Can I avoid global state entirely?        → Yes → use anonymous classes, create_test_contract
2. Must I mutate global state (e.g., I18n)?  → Use keys that do not exist in production
3. Need `after` block to clean up?           → Forbidden. Fix the test instead.
```

### I18n Translations

Use keys that do not exist in locale files:

```ruby
it 'returns the API-specific translation' do
  definition = described_class.new(attach_path: false, key: :unit_test_api_specific, status: 404)
  I18n.backend.store_translations(:en, apiwork: { apis: { 'api/v1': { error_codes: { unit_test_api_specific: { description: 'Resource not found' } } } } })

  expect(definition.description(locale_key: 'api/v1')).to eq('Resource not found')
end
```

**Rules:**

1. Never use keys that exist in locale files (`:not_found`, `:bad_request`, etc.)
2. Use obviously test-only keys: `:unit_test_api_specific`, `:unit_operation`, etc.
3. Never use `after { I18n.backend.reload! }` — it interferes with lazy loading

---

## What We Do NOT Test

| Thing | Reason |
|-------|--------|
| Basic CRUD (create, read, update, delete) | Rails ActiveRecord |
| 404 for missing records | Rails rescue_from |
| Model validations themselves | ActiveRecord::Validations |
| Association creation/deletion | ActiveRecord |

Test only behavior that Apiwork implements.
