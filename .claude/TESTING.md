# Testing

Rules for writing tests in this repository.

This document is deterministic. Given a class, there is exactly **one** way to write its test.
Follow every rule. No variation. No judgment calls.

---

## Commands

```bash
bundle exec rspec                                        # all tests
bundle exec rspec spec/apiwork/issue_spec.rb             # single file
bundle exec rspec spec/apiwork/issue_spec.rb:42          # single test
bundle exec rubocop -A                                   # lint + auto-fix
```

---

## File Organization

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

**Rule:** If unsure whether unit or integration, choose integration.

---

## Unit vs Integration

**Unit:** Tests one class. Minimal setup. No HTTP requests. No database records.

**Integration:** Tests behavior across domains. Uses the dummy Rails app, database records, HTTP requests.

| Unit | Integration |
|------|-------------|
| `Apiwork::Issue` | Filtering API |
| `Apiwork::Contract::Object` validation | CRUD endpoints |
| `Apiwork::Representation::Attribute` | Export generation |
| Error class behavior | Nested includes |

---

## File Header

Every test file starts with exactly:

```ruby
# frozen_string_literal: true

require 'rails_helper'
```

No blank line between the magic comment and require.

---

## Which Methods to Test

### Decision Tree

```
1. Method is private?                    → Do NOT test
2. Method is trivial attr_reader?        → Do NOT test (just returns @variable)
3. Method is @api public?               → MUST test
4. Method is semi-public (no YARD)?     → Test if it has logic (conditional, computation, transformation)
5. Method is #initialize?               → Test only if it validates or transforms input
```

### What "trivial" means

A trivial getter returns `@variable` or delegates without transformation. Do not test these:

```ruby
attr_reader :name          # trivial — skip
delegate :find, to: :registry  # trivial — skip

def root_key               # NOT trivial — has computation
  @root_key ||= RootKey.new(...)
end
```

---

## Test Formulas by Method Category

Given a method, categorize it, then apply the formula mechanically.

### Category Decision Tree

```
1. Ends with `?`                        → Predicate
2. Ends with `!` and raises             → Raiser
3. Ends with `!` and mutates state      → Mutator
4. Name is `to_h`, `to_s`, `as_json`   → Converter
5. Name starts with `find`              → Finder
6. Takes `&block` and defines structure → DSL
7. Is a class setter (model, adapter)   → Configuration Setter
8. Returns a value                      → Getter
```

### Predicate (`?` methods)

**Formula:** Always exactly 2 tests — true case and false case.

```ruby
describe '#abstract?' do
  it 'returns true when abstract' do
    representation_class = Class.new(described_class) { abstract! }

    expect(representation_class.abstract?).to be(true)
  end

  it 'returns false when not abstract' do
    representation_class = Class.new(described_class)

    expect(representation_class.abstract?).to be(false)
  end
end
```

**`it` naming:** `'returns true when <condition>'` and `'returns false when <condition>'`.

### Getter (returns value)

**Formula:** 1 test per return path in the method.

Count return paths:
- No conditional logic → 1 test
- `if/else` → 2 tests
- `case/when` with N branches → N tests
- Method can return `nil` → add 1 test for nil case

```ruby
# Method with one path
describe '#layer' do
  it 'returns :domain' do
    error = described_class.new(issue)

    expect(error.layer).to eq(:domain)
  end
end

# Method with two paths (if/else)
describe '#adapter_name' do
  it 'returns the set name' do
    # arrange with name set
  end

  it 'returns nil when not set' do
    # arrange without name
  end
end
```

**`it` naming:** `'returns <what>'` for the primary path, `'returns <what> when <condition>'` for conditionals.

### Raiser (`!` methods that raise)

**Formula:** 1 test for success + 1 test for the raise.

```ruby
describe '.find!' do
  it 'returns the item' do
    # arrange + assert found
  end

  it 'raises KeyError when not found' do
    expect do
      described_class.find!(:nonexistent)
    end.to raise_error(KeyError, /nonexistent/)
  end
end
```

**`it` naming:** `'returns <what>'` + `'raises <Error> when <condition>'`.

### Mutator (`!` methods that change state)

**Formula:** 1 test verifying the state change.

```ruby
describe '#abstract!' do
  it 'marks the class as abstract' do
    representation_class = Class.new(described_class)
    representation_class.abstract!

    expect(representation_class.abstract?).to be(true)
  end
end
```

**`it` naming:** `'marks <object> as <state>'` or `'clears <what>'`.

### Converter (`to_h`, `to_s`, `as_json`)

**Formula:** Always exactly 1 test. Assert the full output structure.

```ruby
describe '#to_h' do
  it 'includes all fields' do
    issue = described_class.new(
      :required,
      'Field is required',
      meta: { field: :email },
      path: [:user, :email],
    )

    expect(issue.to_h).to eq(
      {
        code: :required,
        detail: 'Field is required',
        meta: { field: :email },
        path: %w[user email],
        pointer: '/user/email',
      },
    )
  end
end
```

**`it` naming:** `'includes all fields'` for hashes, `'formats as <description>'` for strings.

### Finder (`find`, `find!`)

**Formula:** `find` gets 2 tests (found + nil). `find!` gets 2 tests (found + raises).

```ruby
describe '.find' do
  it 'returns the item' do
    # ...
  end

  it 'returns nil when not found' do
    expect(described_class.find(:nonexistent)).to be_nil
  end
end
```

### DSL Method (takes `&block`)

**Formula:** 1 test for basic usage + 1 test per distinct parameter behavior.

```ruby
describe '.attribute' do
  it 'registers the attribute' do
    representation_class = Class.new(described_class) do
      abstract!
      attribute :title, type: :string
    end

    expect(representation_class.attributes[:title]).to be_a(Apiwork::Representation::Attribute)
    expect(representation_class.attributes[:title].type).to eq(:string)
  end

  it 'passes block to Attribute' do
    representation_class = Class.new(described_class) do
      abstract!
      attribute :settings do
        object do
          string :theme
        end
      end
    end

    expect(representation_class.attributes[:settings].element).to be_a(Apiwork::Representation::Element)
  end
end
```

**`it` naming:** `'registers the <thing>'` or `'defines a <thing>'` for creation, `'passes block to <target>'` for block forwarding.

### Configuration Setter (class setters with validation)

**Formula:** Always exactly 3 tests:
1. Sets the value correctly
2. Raises for non-class argument
3. Raises for wrong class hierarchy

```ruby
describe '.resource_serializer' do
  it 'sets the serializer class' do
    adapter_class = Class.new(described_class) do
      resource_serializer Serializer::Resource::Default
    end

    expect(adapter_class.resource_serializer).to eq(Serializer::Resource::Default)
  end

  it 'raises for non-class argument' do
    expect do
      Class.new(described_class) do
        resource_serializer 'NotAClass'
      end
    end.to raise_error(Apiwork::ConfigurationError, /must be a Serializer class/)
  end

  it 'raises for wrong class hierarchy' do
    expect do
      Class.new(described_class) do
        resource_serializer String
      end
    end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
  end
end
```

If the setter supports inheritance, add a 4th test:

```ruby
  it 'inherits from superclass' do
    parent = Class.new(described_class) do
      resource_serializer Serializer::Resource::Default
    end
    child = Class.new(parent)

    expect(child.resource_serializer).to eq(Serializer::Resource::Default)
  end
```

---

## Edge Cases from Signature

Edge cases are derivable from the method signature. Apply mechanically:

| Signature pattern | Required edge case test |
|-------------------|------------------------|
| `param = nil` | Test with `nil` |
| `param = []` or Array param | Test with `[]` |
| `param = {}` or Hash param | Test with `{}` |
| `param = ''` or String param | Test with `''` |
| Parameter is a collection | Test with 0, 1, and 2+ items |
| Parameter has `optional:` keyword | Test with and without the parameter |
| Method coerces input | Test input type that needs coercion |

### Example

```ruby
# Method: initialize(code, detail, path: [], meta: {})
# Signature tells us: path defaults to [], meta defaults to {}

it 'creates an issue with required attributes' do
  issue = described_class.new(:required, 'Field is required')

  expect(issue.code).to eq(:required)
  expect(issue.detail).to eq('Field is required')
  expect(issue.path).to eq([])    # edge: default value
  expect(issue.meta).to eq({})    # edge: default value
end

it 'accepts path and meta' do
  issue = described_class.new(
    :type_invalid,
    'Expected string',
    meta: { expected: 'string', got: 'integer' },
    path: [:user, :name],
  )

  expect(issue.path).to eq([:user, :name])
  expect(issue.meta).to eq({ expected: 'string', got: 'integer' })
end
```

---

## When to Create `context` Blocks

`context` blocks are not optional or judgment-based. Create them when:

| Condition | Create context | Example |
|-----------|---------------|---------|
| Method has `if/else` or `case` on input | 1 context per branch | `context 'when type is :string'` |
| Method behaves differently for nil vs value | 2 contexts | `context 'when value is nil'` |
| Method reads a flag/option | 2 contexts | `context 'with optional: true'` |
| Test needs different setup data | 1 context per setup | `context 'with published posts'` |

Do NOT create contexts when:
- Method has a single code path
- The variation is only the input value (use separate `it` blocks instead)

### Single path — no context needed

```ruby
describe '#layer' do
  it 'returns :domain' do
    error = described_class.new(issue)

    expect(error.layer).to eq(:domain)
  end
end
```

### Multiple paths — contexts required

```ruby
describe '#pointer' do
  context 'with path elements' do
    it 'returns JSON pointer format' do
      issue = described_class.new(:required, 'Required', path: [:user, :email])

      expect(issue.pointer).to eq('/user/email')
    end

    it 'handles array indices' do
      issue = described_class.new(:required, 'Required', path: [:items, 0, :name])

      expect(issue.pointer).to eq('/items/0/name')
    end
  end

  context 'without path elements' do
    it 'returns empty string' do
      issue = described_class.new(:required, 'Required', path: [])

      expect(issue.pointer).to eq('')
    end
  end
end
```

### Rule: contexts from method branching

Read the method. Count branches. Each branch is a context.

```ruby
# Source method:
def build_action_response(action)
  case action.name
  when :index    then build_collection(...)
  when :destroy  then no_content!
  else                build_member(...)
  end
end

# Test structure:
describe '#build_action_response' do
  context 'when action is :index' do
    it 'builds collection response' do ...
  end

  context 'when action is :destroy' do
    it 'builds no content response' do ...
  end

  context 'when action is :show' do
    it 'builds member response' do ...
  end
end
```

---

## Describe Block Order

Follow the class layout order from CLAUDE.md:

1. `class << self` methods: `describe '.method'` (alphabetical)
2. `#initialize`: `describe '#initialize'`
3. Public instance methods: `describe '#method'` (alphabetical)

Within each `describe`:
1. Happy path `it` blocks first
2. `context` blocks after (ordered by: normal cases, then edge cases, then error cases)

---

## `let` vs Inline — Decision Tree

```
1. Same object used in 3+ it blocks in same describe?  → let
2. Database record that must exist before test?         → let!
3. Object used in 1-2 it blocks?                       → inline in the it block
4. Setup shared across 3+ it blocks?                   → before
5. Bulk data (10+ records)?                             → before with loop
```

Never use `let` at the `RSpec.describe` level in unit tests. Keep `let` as close to its usage as possible.

```ruby
# Good — let scoped to the describe that uses it
describe '#pointer' do
  let(:issue) { described_class.new(:required, 'Required', path: [:user, :email]) }

  it 'returns JSON pointer format' do
    expect(issue.pointer).to eq('/user/email')
  end

  # ... 2 more it blocks using issue
end

# Bad — let at top level used by one describe
RSpec.describe Apiwork::Issue do
  let(:issue) { described_class.new(:required, 'Required') }

  describe '#code' do
    it 'returns the code' do
      expect(issue.code).to eq(:required)
    end
  end
end
```

---

## Unit Test Template

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ClassName do
  describe '.class_method' do
    it 'returns the value' do
      result = described_class.class_method(:input)

      expect(result).to eq(:expected)
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      object = described_class.new(:code, 'Detail')

      expect(object.code).to eq(:code)
      expect(object.detail).to eq('Detail')
    end
  end

  describe '#instance_method' do
    it 'returns the value' do
      object = described_class.new(:code, 'Detail')

      expect(object.instance_method).to eq(:expected)
    end
  end
end
```

### Rules

1. `RSpec.describe` takes the **class constant**: `Apiwork::Issue`, not `'Issue'`
2. Group by **public method**: `describe '#instance_method'`, `describe '.class_method'`
3. Use `described_class` for the top-level described class
4. No `subject`. Ever.

### Anonymous Classes

For testing DSL classes (representations, contracts), use anonymous classes:

```ruby
let(:representation_class) do
  Class.new(Apiwork::Representation::Base) do
    abstract!
  end
end
```

Mark test representations `abstract!` to prevent registration side effects.

### Test Contract Helper

Use `create_test_contract` from `TestApiHelper` for contract-based tests:

```ruby
let(:contract_class) { create_test_contract }
let(:definition) { described_class.new(contract_class) }
```

---

## Integration Test Template

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feature Name', type: :request do
  let!(:post1) { Post.create!(body: 'Rails tutorial', created_at: 3.days.ago, published: true, title: 'First Post') }
  let!(:post2) { Post.create!(body: 'Ruby guide', created_at: 2.days.ago, published: false, title: 'Second Post') }
  let!(:post3) { Post.create!(body: 'Rails advanced', created_at: 1.hour.ago, published: true, title: 'Third Post') }

  describe 'GET /api/v1/posts with filters' do
    it 'filters by exact match' do
      get '/api/v1/posts', params: { filter: { title: { eq: 'First Post' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('First Post')
    end
  end
end
```

### Rules

1. `RSpec.describe` takes a **string**: `'Filtering API'`, not a class
2. Always include `type: :request` for HTTP tests, `type: :integration` for non-HTTP integration
3. Use `let!` (bang) for database records that must exist before the test runs
4. Use `before` only for bulk data setup (10+ records)
5. `describe` groups by **HTTP method + path**: `describe 'GET /api/v1/posts'`
6. Parse response with `json = JSON.parse(response.body)` as local variable

### Database Record Setup

**Named records (1-5):** Use `let!` with descriptive data.

```ruby
let!(:post1) { Post.create!(body: 'Rails tutorial', created_at: 3.days.ago, published: true, title: 'First Post') }
let!(:post2) { Post.create!(body: 'Ruby guide', created_at: 2.days.ago, published: false, title: 'Second Post') }
```

**Bulk records (10+):** Use `before` with numbered data.

```ruby
before do
  25.times do |i|
    Post.create!(
      body: "Body #{i + 1}",
      created_at: (25 - i).days.ago,
      published: i.even?,
      title: "Post #{i + 1}",
    )
  end
end
```

### Response Parsing

Always in this exact order:
1. HTTP verb call
2. Blank line
3. Status assertion
4. `json = JSON.parse(response.body)`
5. Data assertions

```ruby
it 'returns the post' do
  get "/api/v1/posts/#{post1.id}"

  expect(response).to have_http_status(:ok)
  json = JSON.parse(response.body)
  expect(json['post']['title']).to eq('First Post')
end
```

### Error Response Pattern

```ruby
it 'returns error for invalid input' do
  get '/api/v1/posts', params: { filter: { invalid_field: { eq: 'value' } } }

  expect(response).to have_http_status(:bad_request)
  json = JSON.parse(response.body)
  expect(json['issues']).to be_present
end
```

For specific error details:

```ruby
it 'returns validation error with pointer' do
  post '/api/v1/posts', as: :json, params: { post: { body: 'No title' } }

  expect(response).to have_http_status(:unprocessable_entity)
  json = JSON.parse(response.body)
  issue = json['issues'].first
  expect(issue['code']).to eq('required')
  expect(issue['pointer']).to eq('/post/title')
end
```

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
    it 'generates Post interface' do
      expect(output).to include('export interface Post')
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

## Naming

### RSpec.describe

| Test type | Format | Example |
|-----------|--------|---------|
| Unit | Class constant | `RSpec.describe Apiwork::Issue` |
| Integration (HTTP) | String + `type: :request` | `RSpec.describe 'Filtering API', type: :request` |
| Integration (non-HTTP) | String + `type: :integration` | `RSpec.describe 'TypeScript Generation', type: :integration` |

### describe (nested)

| Purpose | Format | Example |
|---------|--------|---------|
| Instance method | `'#method'` | `describe '#pointer'` |
| Class method | `'.method'` | `describe '.find'` |
| Nested class | Class constant | `describe Apiwork::Representation::Attribute` |
| HTTP endpoint | String | `describe 'GET /api/v1/posts'` |
| Feature group | String | `describe 'Resource types'` |

### context

Must start with: `when`, `with`, `without`, `if`.

```ruby
context 'when the path is empty' do
context 'with valid datetime values' do
context 'without filters' do
```

### it — Naming Formulas

| Method category | `it` pattern | Example |
|-----------------|--------------|---------|
| Getter | `'returns <what>'` | `it 'returns :domain'` |
| Getter (conditional) | `'returns <what> when <condition>'` | `it 'returns nil when not set'` |
| Predicate (true) | `'returns true when <condition>'` | `it 'returns true when abstract'` |
| Predicate (false) | `'returns false when <condition>'` | `it 'returns false when not abstract'` |
| Mutator | `'marks <object> as <state>'` | `it 'marks the class as abstract'` |
| Converter | `'includes all fields'` | `it 'includes all fields'` |
| Finder (success) | `'returns the <thing>'` | `it 'returns the error code'` |
| Finder (nil) | `'returns nil when not found'` | `it 'returns nil when not found'` |
| Finder (raise) | `'raises <Error> when not found'` | `it 'raises KeyError when not found'` |
| DSL | `'registers the <thing>'` | `it 'registers the attribute'` |
| Config setter (set) | `'sets the <thing>'` | `it 'sets the serializer class'` |
| Config setter (error) | `'raises ConfigurationError for <reason>'` | `it 'raises ConfigurationError for non-class argument'` |
| Config setter (inherit) | `'inherits from superclass'` | `it 'inherits from superclass'` |
| HTTP (success) | `'<verb>s by <mechanism>'` | `it 'filters by exact match'` |
| HTTP (error) | `'returns <status> for <reason>'` | `it 'returns error for invalid input'` |
| HTTP (empty) | `'returns empty <collection> when <condition>'` | `it 'returns empty array when no matches found'` |

**Forbidden patterns:**

| Bad | Good |
|-----|------|
| `it 'should return a hash'` | `it 'returns a hash'` |
| `it 'validates and saves'` | Split into two `it` blocks |
| `it 'works correctly'` | Be specific using formula |
| `it 'it returns a hash'` | `it 'returns a hash'` |

---

## Assertions

### Equality

```ruby
expect(issue.code).to eq(:required)
expect(issue.path).to eq([:user, :name])
expect(json['posts'].length).to eq(2)
```

### Boolean

```ruby
expect(post['published']).to be(true)
expect(post['published']).to be(false)
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
expect(json['posts'].length).to eq(2)
expect(titles).to include('First Post', 'Third Post')
expect(ids).to contain_exactly(post1.id, post3.id)
```

Use `contain_exactly` for order-independent, `eq` for exact match with order.

### Type

```ruby
expect(output).to be_a(String)
expect(definition.element).to be_a(Apiwork::Representation::Element)
```

### HTTP Status

```ruby
expect(response).to have_http_status(:ok)
expect(response).to have_http_status(:created)
expect(response).to have_http_status(:bad_request)
expect(response).to have_http_status(:not_found)
expect(response).to have_http_status(:unprocessable_entity)
```

Use symbols, not integers.

### Errors

```ruby
expect do
  Class.new(described_class) do
    resource_serializer 'NotAClass'
  end
end.to raise_error(Apiwork::ConfigurationError, /must be a Serializer class/)
```

### Change

```ruby
expect do
  post '/api/v1/posts', as: :json, params: post_params
end.to change(Post, :count).by(1)
```

### String Matching

```ruby
expect(output).to include('export interface Post')
expect(output).to match(/title\??: string/)
```

Use `include` for exact substring, `match` for regex.

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
it 'converts path elements to symbols' do
  issue = described_class.new(
    :required,
    'Required',
    path: ['user', 'items', 0, 'name'],
  )

  expect(issue.path).to eq([:user, :items, 0, :name])
end
```

### HTTP: Act + Assert

```ruby
it 'filters by exact match' do
  get '/api/v1/posts', params: { filter: { title: { eq: 'First Post' } } }

  expect(response).to have_http_status(:ok)
  json = JSON.parse(response.body)
  expect(json['posts'].length).to eq(1)
end
```

**Rule:** One blank line between arrange and assert. One blank line between act (HTTP call) and assert. No blank lines within the assert phase.

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

### Decision: same `it` or separate?

```
Same object, same action, multiple properties?  → Same it
Different input values for same method?          → Separate it
Different method calls?                          → Separate it
```

---

## Test Data Vocabulary

Tests use a **fixed vocabulary**. No exceptions.

| Domain | Terms |
|--------|-------|
| Billing | `invoice`, `item`, `items`, `customer`, `payment`, `currency`, `amount` |
| Content | `post`, `comment`, `comments`, `author`, `title`, `body`, `published` |
| Framework | `api`, `resource`, `action`, `contract`, `type`, `enum`, `adapter`, `representation` |

**Forbidden:** `foo`, `bar`, `baz`, `test`, `example`, `sample`, `dummy`, `thing`, `data`

### String Values

Use recognizable, boring values:

```ruby
title: 'First Post'
body: 'Rails tutorial'
detail: 'Field is required'
path: [:user, :email]
```

### Numbered Records

```ruby
let!(:post1) { Post.create!(title: 'First Post', ...) }
let!(:post2) { Post.create!(title: 'Second Post', ...) }
let!(:post3) { Post.create!(title: 'Third Post', ...) }
```

Variable names: `post1`, `post2`, `post3`. Not `first_post`, `published_post`.

### Record Attribute Order

Alphabetical by key name within `create!`:

```ruby
Post.create!(body: 'Rails tutorial', created_at: 3.days.ago, published: true, title: 'First Post')
```

---

## Intermediate Variables

```
Accessing .first on a collection?                → Extract: `issue = json['issues'].first`
Mapping a collection for comparison?             → Extract: `titles = json['posts'].map { |p| p['title'] }`
Simple method call on test object?               → Inline: `expect(issue.pointer).to eq(...)`
```

---

## File Size

Target: **under 150 lines** per test file.

If a file exceeds 150 lines, split by `describe` group into separate files:

```
spec/apiwork/contract/object_spec.rb           → base validation
spec/apiwork/contract/object_datetime_spec.rb  → datetime-specific
spec/apiwork/contract/object_array_spec.rb     → array-specific
```

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
| `described_class` in integration tests | Use the actual class or string |
| Comments | Structure and names carry meaning |

---

## Complete Algorithm

Given a class to test:

```
1. Create file at spec/apiwork/<path>_spec.rb
2. Add header (frozen_string_literal + require)
3. RSpec.describe with class constant
4. List all public + semi-public methods with logic
5. Order: class methods (alphabetical), #initialize, instance methods (alphabetical)
6. For each method:
   a. Categorize (predicate/getter/raiser/mutator/converter/finder/DSL/config setter)
   b. Count code paths (branches, conditionals)
   c. Apply formula for that category → get exact number of it blocks
   d. Check signature for edge cases → add it blocks per table
   e. If 3+ it blocks with same setup → wrap in let, else inline
   f. If method has branches → add context blocks per branch
   g. Name it blocks using naming formula table
7. Verify: under 150 lines? If not, split.
```

---

## Checklist

Before a test file is done:

1. File starts with `# frozen_string_literal: true` + `require 'rails_helper'`
2. `RSpec.describe` uses class constant (unit) or string (integration)
3. Methods tested in class layout order
4. Each method categorized and formula applied
5. Edge cases derived from signature
6. `context` blocks match method branches
7. `it` names follow naming formula table
8. No `subject`, no `shared_examples`, no `shared_context`
9. No comments
10. AAA structure with blank lines
11. Test data uses canonical vocabulary
12. Record attributes in alphabetical order
13. `let` scoped to nearest `describe`, not top-level
14. Under 150 lines
15. `bundle exec rubocop -A` passes
16. `bundle exec rspec <file>` passes
