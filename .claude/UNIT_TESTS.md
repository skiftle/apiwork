# Unit Testing

Rules for writing unit tests in this repository.

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

## Which Methods to Unit Test

### Decision Tree

```
1. Method is private?                              → NEVER
2. Method is @api public?                          → MUST test
2b. @api public but delegates to abstract method?  → Skip (tested via concrete subclasses)
3. #initialize with validation or coercion?        → MUST test
4. Method has ≥3 code paths?                       → MUST test
5. File has ≥8 conditional keywords total?         → MUST test entry points
6. Everything else (semi-public, <3 code paths)?   → Do NOT unit test
```

Rule 2b applies to abstract base classes where @api public methods delegate to methods that raise `NotImplementedError`. These methods cannot be meaningfully tested on the base class. The concrete subclasses that implement the abstract method are tested instead. Examples: `Object#string` delegates to abstract `#param`, `Element#string` delegates to abstract `#of`, `Union#variant` calls abstract `#build_element`.

Rule 4 catches semi-public methods with branching logic that integration tests cannot fully exercise.

Rule 5 is a safety net for classes where complex branching lives in private methods called from simple public entry points. Count ALL conditional keywords in the entire file (including private). If ≥8: test every non-private method that delegates to private logic. This catches classes like `SurfaceResolver` (0 non-private conditionals, 31 private) and `Serializer` (2 non-private, 18 private).

Rule 6 applies to simple semi-public methods in simple classes. These are adequately tested through integration tests.

### What about canonical entry points?

Canonical entry points (`#build`, `#generate`, `#serialize`, `#coerce`, etc.) are tested if they match rules 2, 4, or 5.

Base classes like `Builder::Base#build` and `Serializer::Base#serialize` are `@api public` and get unit tests via rule 2.

Concrete implementations like `Coercer#coerce` have ≥3 code paths in the method itself. These get unit tests via rule 4.

Concrete implementations like `SurfaceResolver.resolve` or `Serializer#serialize` have simple public methods that delegate to complex private logic. The file has ≥8 total conditionals. These get unit tests via rule 5 — test the entry point with inputs that exercise the private branches.

Concrete implementations with <3 code paths in a file with <8 total conditionals (e.g., `Filtering::ContractBuilder#build`) are tested through integration tests only.

### What about `attr_reader`?

`@api public` attr_readers that just return `@variable` are tested through `#initialize`.
The `#initialize` test asserts all public attributes.
No separate `describe` for trivial attr_readers.

```ruby
# Issue has @api public attr_reader :code, :detail, :path, :meta
# These are tested in describe '#initialize':

it 'creates with required attributes' do
  issue = described_class.new(:required, 'Field is required')

  expect(issue.code).to eq(:required)     # attr_reader tested here
  expect(issue.detail).to eq('Field is required')
  expect(issue.path).to eq([])
  expect(issue.meta).to eq({})
end
```

### Which classes get unit tests?

A class gets a unit test file if it has at least one method matching rules 2-5.

```
Has @api public methods?                              → yes → unit test file
Has #initialize with logic?                           → yes → unit test file
Has any non-private method with ≥3 code paths?        → yes → unit test file
File has ≥8 conditional keywords total?               → yes → unit test file (test entry points)
None of the above?                                    → no unit test file (integration only)
```

Classes that do NOT get unit tests (no `@api public`, no methods with ≥3 code paths, file has <8 total conditionals):

| Category | Examples |
|----------|----------|
| Capability declarations | `Filtering`, `Pagination`, `Sorting` |
| Concrete builders (<3 code paths) | `Filtering::ContractBuilder`, `Pagination::Operation` |
| Constants modules | `Filtering::Constants`, `Writing::Constants` |
| Error classes (no logic) | `DomainError`, `ConfigurationError`, `HttpError` |
| Internal registries | `Adapter::Registry`, `API::Registry` |
| Result/data holders | `Validator::Result`, `RequestParser::Result` |
| Introspection dump classes | `Dump::Action`, `Dump::API`, `Dump::Contract` |
| Mixins | `Abstractable`, `Validatable` |
| Engine, version | `Engine`, `version.rb` |

### How to count code paths

Code paths = 1 + count of conditional keywords in the method body.

**Count each occurrence of:** `if`, `elsif`, `unless`, `when`, `rescue`, ternary (`? :`).

Postfix conditions count: `return if x` counts as `if`. `value unless y` counts as `unless`.

**Do NOT count:** `else` (replaces the default path, does not add one), `case` (grouping keyword, not a branch), `end`, `&&`, `||`, `&.`, block iterations (`.each`, `.map`, `.select`).

**Examples:**

```
def name                                     → 1 path (no conditionals)
  @name
end

def validate!                                → 2 paths (1 + if)
  return if abstract?
  check_model
end

def key_format                               → 2 paths (1 + ternary)
  @key_format ? @key_format : :keep
end

def resolve(name)                            → 4 paths (1 + unless + if + elsif)
  return nil unless name
  result = registry.find(name)
  if result.nil?
    raise KeyError
  elsif result.deprecated?
    warn "Deprecated"
    result
  end
end

def coerce(value, type)                      → 5 paths (1 + 4 when)
  case type
  when :string then value.to_s
  when :integer then Integer(value)
  when :boolean then parse_boolean(value)
  when :datetime then Time.iso8601(value)
  end
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
7. Accepts keyword args with defaults   → DSL with Options
8. Is a class setter (model, adapter)   → Configuration Setter
9. Returns a value                      → Getter
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
      attribute :number, type: :string
    end

    expect(representation_class.attributes[:number]).to be_a(Apiwork::Representation::Attribute)
    expect(representation_class.attributes[:number].type).to eq(:string)
  end

  it 'passes block to Attribute' do
    representation_class = Class.new(described_class) do
      abstract!
      attribute :metadata do
        object do
          string :theme
        end
      end
    end

    expect(representation_class.attributes[:metadata].element).to be_a(Apiwork::Representation::Element)
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

### DSL Method with Options (keyword arguments)

**Formula:** Always exactly 2 contexts: "with defaults" and "with overrides".

This applies to any DSL method that accepts keyword arguments with default values (e.g., `#param`, `#string`, `#integer`, and all sugar methods on Object classes).

**"with defaults"** — Call the method with only required arguments. Assert all boolean defaults.

**"with overrides"** — Call the method with ALL accepted keyword arguments set to non-default values. Assert each one.

```ruby
describe '#string' do
  context 'with defaults' do
    it 'defines a string param' do
      object = described_class.new
      object.string(:number)

      expect(object.params[:number][:type]).to eq(:string)
      expect(object.params[:number][:deprecated]).to be(false)
      expect(object.params[:number][:nullable]).to be(false)
      expect(object.params[:number][:optional]).to be(false)
      expect(object.params[:number][:required]).to be(false)
    end
  end

  context 'with overrides' do
    it 'forwards all options' do
      object = described_class.new
      object.string(
        :number,
        as: :name,
        default: 'Untitled',
        deprecated: true,
        description: 'The invoice number',
        enum: %w[draft published],
        example: 'INV-001',
        format: :email,
        max: 100,
        min: 1,
        nullable: true,
        optional: true,
        required: false,
      )

      param = object.params[:number]
      expect(param[:as]).to eq(:name)
      expect(param[:default]).to eq('Untitled')
      expect(param[:deprecated]).to be(true)
      expect(param[:description]).to eq('The invoice number')
      expect(param[:enum]).to eq(%w[draft published])
      expect(param[:example]).to eq('INV-001')
      expect(param[:format]).to eq(:email)
      expect(param[:max]).to eq(100)
      expect(param[:min]).to eq(1)
      expect(param[:nullable]).to be(true)
      expect(param[:optional]).to be(true)
      expect(param[:required]).to be(false)
    end
  end
end
```

**Rules:**

1. "with defaults" always verifies ALL boolean defaults explicitly (`be(false)` or `be(true)`)
2. "with overrides" sets EVERY accepted keyword argument to a non-default value
3. "with overrides" verifies EVERY keyword argument individually
4. Use `be(true)` / `be(false)` for booleans, `eq(value)` for everything else

**Optional variant methods** (ending with `?`, e.g., `#string?`) get "with defaults" only:

```ruby
describe '#string?' do
  context 'with defaults' do
    it 'defines an optional string param' do
      object = described_class.new
      object.string?(:number)

      expect(object.params[:number][:type]).to eq(:string)
      expect(object.params[:number][:optional]).to be(true)
    end
  end
end
```

**`it` naming:** `'defines a <type> param'` for defaults, `'forwards all options'` for overrides, `'defines an optional <type> param'` for optional variants.

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
| Test needs different setup data | 1 context per setup | `context 'with paid invoices'` |

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

Follow the class layout order from CLAUDE.md (`@api public` first, then semi-public):

1. `class << self` methods — `@api public` (alphabetical)
2. `class << self` methods — semi-public with ≥3 code paths (alphabetical)
3. `#initialize`
4. Instance methods — `@api public` (alphabetical)
5. Instance methods — semi-public with ≥3 code paths (alphabetical)

Skip sections that have no methods. A class with only semi-public methods (no `@api public`) uses sections 2, 3, 5 only.

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

---

## Naming

### RSpec.describe

| Test type | Format | Example |
|-----------|--------|---------|
| Unit | Class constant | `RSpec.describe Apiwork::Issue` |

### describe (nested)

| Purpose | Format | Example |
|---------|--------|---------|
| Instance method | `'#method'` | `describe '#pointer'` |
| Class method | `'.method'` | `describe '.find'` |
| Nested class | Class constant | `describe Apiwork::Representation::Attribute` |

### context

Must start with: `when`, `with`, `without`, `if`.

```ruby
context 'when the path is empty' do
context 'with valid datetime values' do
context 'without filters' do
```

### it — Naming Formulas

`<what>` is the **return value as written in code** or the **method name as words**.

**Algorithm for `<what>`:**

```
1. Return is a literal (:domain, 422, "UTC")    → use the literal: 'returns :domain'
2. Return is the method name's noun              → use it: 'returns the pointer'
3. Return is nil                                 → 'returns nil when <condition>'
```

**Algorithm for `<condition>`:**

```
1. Condition is from a context block             → omit (context already states it)
2. Condition is about input state                → 'when <state>': 'when not set', 'when empty'
3. Condition is about a flag                     → 'when <flag>': 'when abstract', 'when optional'
```

| Method category | `it` pattern | Exact example |
|-----------------|--------------|---------------|
| Getter (literal return) | `'returns <literal>'` | `it 'returns :domain'` |
| Getter (object return) | `'returns the <method name as noun>'` | `it 'returns the pointer'` |
| Getter (nil path) | `'returns nil when <condition>'` | `it 'returns nil when not set'` |
| Predicate (true) | `'returns true when <adjective from method name>'` | `it 'returns true when abstract'` |
| Predicate (false) | `'returns false when not <adjective>'` | `it 'returns false when not abstract'` |
| Mutator | `'marks the <class noun> as <state>'` | `it 'marks the class as abstract'` |
| Converter (`to_h`) | `'includes all fields'` | `it 'includes all fields'` — always this exact string |
| Converter (`to_s`) | `'formats as <output pattern>'` | `it 'formats as [code] at pointer detail'` |
| Converter (`as_json` delegating) | `'returns the same as to_h'` | `it 'returns the same as to_h'` — always this exact string |
| Converter (branch, true) | `'includes the <thing>'` | `it 'includes the pointer'` |
| Converter (branch, false) | `'excludes the <thing>'` | `it 'excludes the pointer'` |
| Finder (success) | `'returns the <class noun>'` | `it 'returns the error code'` |
| Finder (nil) | `'returns nil when not found'` | Always this exact string |
| Finder (raise) | `'raises <Error> when not found'` | `it 'raises KeyError when not found'` |
| DSL (registers) | `'registers the <thing>'` | `it 'registers the attribute'` |
| DSL (block) | `'passes block to <target class>'` | `it 'passes block to Attribute'` |
| Config setter (set) | `'sets the <thing>'` | `it 'sets the serializer class'` |
| Config setter (non-class) | `'raises ConfigurationError for non-class argument'` | Always this exact string |
| Config setter (wrong hierarchy) | `'raises ConfigurationError for wrong class hierarchy'` | Always this exact string |
| Config setter (inherit) | `'inherits from superclass'` | Always this exact string |
| Initialize (defaults) | `'creates with required attributes'` | Always this exact string |
| Initialize (optionals) | `'accepts <param1> and <param2>'` | `it 'accepts path and meta'` |
| Initialize (coercion) | `'converts <input> to <output>'` | `it 'converts path elements to symbols except integers'` |
**Forbidden patterns:**

| Bad | Why | Good |
|-----|-----|------|
| `it 'should return a hash'` | "should" | `it 'returns a hash'` |
| `it 'validates and saves'` | Multiple behaviors | Split into two `it` blocks |
| `it 'works correctly'` | Non-specific | Use formula |
| `it 'it returns a hash'` | Stutters | `it 'returns a hash'` |
| `it 'returns the correct value'` | "correct" is filler | `it 'returns :domain'` |
| `it 'properly handles nil'` | "properly" is filler | `it 'returns nil when not set'` |

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

**Rule:** One blank line between arrange and assert. No blank lines within the assert phase.

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

## Test Data

### Forbidden Words

Never use: `foo`, `bar`, `baz`, `test`, `example`, `sample`, `dummy`, `thing`, `data`, `xxx`, `abc`

### Record Attribute Order

Alphabetical by key name. Always.

```ruby
Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft)
```

### Variable Names

Numbered: `invoice1`, `invoice2`, `invoice3`. Never `first_invoice` or `paid_invoice`.

---

## Test Data Registry

See `INTEGRATION_TESTS.md` for the full test data registry with all models and values.

---

## Unit Test Value Registry

Fixed values by type. Do not invent new values.

### Issue values

| Field | Primary value | Secondary value | Empty/default value |
|-------|--------------|-----------------|---------------------|
| `code` | `:required` | `:type_invalid` | `:invalid` |
| `detail` | `'Field is required'` | `'Expected string'` | `'Invalid request'` |
| `path` | `[:user, :email]` | `[:items, 0, :name]` | `[]` |
| `meta` | `{ field: :email }` | `{ expected: 'string', got: 'integer' }` | `{}` |

### Error values

| Field | Value |
|-------|-------|
| `issue` | `Apiwork::Issue.new(:invalid, 'is invalid', path: [:amount])` |
| `status` | `422` |
| `error_code` | `Apiwork::ErrorCode.find!(:unprocessable_entity)` |

### Representation values

| Field | Value |
|-------|-------|
| Attribute name | `:number`, `:notes`, `:status`, `:amount` |
| Attribute type | `:string`, `:integer`, `:boolean`, `:datetime` |
| Association name | `:items`, `:customer`, `:payments` |

### Contract values

| Field | Value |
|-------|-------|
| Action name | `:index`, `:show`, `:create`, `:update`, `:destroy` |
| Param name | `:number`, `:notes`, `:amount`, `:email` |
| Param type | `:string`, `:integer`, `:boolean` |

### DSL class setter test values

| Test | Valid class | Invalid (non-class) | Invalid (wrong hierarchy) |
|------|-----------|---------------------|--------------------------|
| `resource_serializer` | `Serializer::Resource::Default` | `'NotAClass'` | `String` |
| `error_serializer` | `Serializer::Error::Default` | `'NotAClass'` | `String` |
| `member_wrapper` | `Wrapper::Member::Default` | `'NotAClass'` | `String` |
| `collection_wrapper` | `Wrapper::Collection::Default` | `'NotAClass'` | `String` |
| `error_wrapper` | `Wrapper::Error::Default` | `'NotAClass'` | `String` |

Non-class argument is always `'NotAClass'`. Wrong hierarchy is always `String`.

### String test values by purpose

| Purpose | Value |
|---------|-------|
| Person name | `'Anna Svensson'`, `'Erik Lindberg'` |
| Email | `'anna@example.com'`, `'billing@acme.com'` |
| Company | `'Acme Corp'`, `'Beta Inc'` |
| Invoice number | `'INV-001'`, `'INV-002'`, `'INV-003'` |
| Notes | `'Net 30 payment terms'`, `'Rush delivery'`, `'Prepaid quarterly'` |
| Item description | `'Consulting hours'`, `'Software license'`, `'Support contract'` |
| Adjustment description | `'Discount 10%'`, `'Early payment bonus'` |
| Payment reference | `'ch_abc123'`, `'bt_def456'` |
| Tag name | `'Priority'`, `'Urgent'` |
| Tag slug | `'priority'`, `'urgent'` |
| Filename | `'document.pdf'`, `'image.png'` |
| Street | `'123 Main St'`, `'456 Oak Ave'` |
| City | `'Stockholm'`, `'Gothenburg'` |

### Numeric test values

| Purpose | Value |
|---------|-------|
| Positive integer | `42` |
| Zero | `0` |
| Negative integer | `-1` |
| Decimal | `19.99` |
| Count | `25` (for bulk) |

### Time test values

| Purpose | Value |
|---------|-------|
| Past (days) | `3.days.ago`, `2.days.ago`, `1.day.ago` |
| Past (hours) | `1.hour.ago` |
| Date string | `'1990-01-15'` |
| Datetime string | `'2024-01-15T10:30:00Z'` |

---

## API Definition Paths

Tests that call `Apiwork::API.define` must use unique, deterministic base paths.

**Formula:** `/unit/<class>-<method>[-<variant>]`

| Component | Rule | Example |
|-----------|------|---------|
| Prefix | Always `/unit/` for unit tests | `/unit/` |
| `<class>` | Demodulized class name, lowercased | `Base` becomes `base`, `Resource` becomes `resource` |
| `<method>` | Method name without `.`/`#`, underscores become hyphens | `.key_format` becomes `key-format` |
| `<variant>` | Only when multiple API definitions in same `describe` | see below |

### Variant rules

| Situation | Variant | Example path |
|-----------|---------|--------------|
| Single `it` in describe | none | `/unit/base-adapter` |
| Primary/happy path | none | `/unit/base-key-format` |
| Default value test | `default` | `/unit/base-key-format-default` |
| Error/raises test | `invalid` | `/unit/base-key-format-invalid` |
| Specific keyword argument | argument name | `/unit/resource-get-on` |
| Other behavior variant | shortest descriptive word | `/unit/resource-resources-nested` |

### Examples

```ruby
# .adapter — single it, no variant
Apiwork::API.define('/unit/base-adapter') {}

# .key_format — 3 tests in same describe
Apiwork::API.define '/unit/base-key-format' do       # primary
Apiwork::API.define('/unit/base-key-format-default') {} # default value
Apiwork::API.define '/unit/base-key-format-invalid' do  # error case

# #resources — many tests in same describe
Apiwork::API.define '/unit/resource-resources' do         # primary
Apiwork::API.define '/unit/resource-resources-nested' do  # variant
Apiwork::API.define '/unit/resource-resources-only' do    # keyword arg
Apiwork::API.define '/unit/resource-resources-except' do  # keyword arg
Apiwork::API.define '/unit/resource-resources-path' do    # keyword arg
```

---

## Intermediate Variables

```
Accessing .first on a collection?                → Extract: `issue = json['issues'].first`
Mapping a collection for comparison?             → Extract: `numbers = result.map { |r| r[:number] }`
Simple method call on test object?               → Inline: `expect(issue.pointer).to eq(...)`
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
| `described_class` outside unit tests | Use the actual class or string |
| Comments | Structure and names carry meaning |

---

## Global State in Unit Tests

Unit tests must not mutate global state with keys that exist in production code or other tests.

### Decision Tree

```
1. Can I avoid global state entirely?        → Yes → use anonymous classes, create_test_contract
2. Must I mutate global state (e.g., I18n)?  → Use keys that do not exist in production
3. Need `after` block to clean up?           → Forbidden. Fix the test instead.
```

### I18n Translations

When a test needs `I18n.backend.store_translations`, use keys that do not exist in locale files:

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

### Registries and Class State

Apiwork registries (API, Adapter, Export) persist across tests. Avoid registering with real keys:

1. Use anonymous classes (`Class.new(described_class)`) — they are not registered
2. Use `create_test_contract` helper — generates isolated contracts
3. For `Apiwork::API.define`, use deterministic paths per the API Definition Paths section

### Why Not `after` Blocks?

`after` blocks are forbidden because:

1. They create hidden dependencies between setup and teardown
2. Global state cleanup is fragile (e.g., `I18n.backend.reload!` breaks `store_translations`)
3. They mask the real problem: the test is mutating shared state with conflicting keys

The fix is always: **use keys that cannot conflict with production code or other tests.**

---

## Complete Algorithm

Given a class to test:

```
1. Does the class qualify? (has @api public methods, #initialize with logic, non-private methods with ≥3 code paths, or file has ≥8 total conditionals?)
   No  → skip, integration tests only
   Yes → continue

2. Create file at spec/apiwork/<path>_spec.rb
3. Add header (frozen_string_literal + require)
4. RSpec.describe with class constant

5. List methods to test:
   a. All @api public methods (except trivial attr_reader — tested via #initialize)
   b. #initialize if it validates or coerces input
   c. All non-private methods with ≥3 code paths
   d. If file has ≥8 total conditionals: all non-private entry points that delegate to private logic
   e. Nothing else

6. Order: class methods @api public (alphabetical), class methods semi-public ≥3 (alphabetical), #initialize, instance methods @api public (alphabetical), instance methods semi-public ≥3 (alphabetical)

7. For each method:
   a. Categorize (predicate/getter/raiser/mutator/converter/finder/DSL/DSL with options/config setter)
   b. Count code paths (branches, conditionals)
   c. Apply formula for that category → get exact number of it blocks
   d. Check signature for edge cases → add it blocks per table
   e. If 3+ it blocks with same setup → wrap in let, else inline
   f. If method has branches → add context blocks per branch
   g. If DSL with options → add "with defaults" + "with overrides" contexts
   h. Name it blocks using naming formula table
```

---

## Checklist

Before a test file is done:

1. File starts with `# frozen_string_literal: true` + `require 'rails_helper'`
2. `RSpec.describe` uses class constant (unit) or string (integration)
3. Tests `@api public` methods, `#initialize` with logic, non-private methods with ≥3 code paths, and entry points for files with ≥8 total conditionals (per decision tree above)
4. No tests for private methods or simple semi-public methods in simple files
5. Methods tested in class layout order (@api public first alphabetical, then semi-public ≥3 alphabetical, within each section)
6. Each method categorized and formula applied
7. Edge cases derived from signature
8. `context` blocks match method branches
9. DSL methods with options have "with defaults" + "with overrides" contexts
10. `it` names follow naming formula table
11. No `subject`, no `shared_examples`, no `shared_context`
12. No comments
13. AAA structure with blank lines
14. Test data from the registry (no invented values)
15. Record attributes in alphabetical order
16. `let` scoped to nearest `describe`, not top-level
17. `bundle exec rubocop -A` passes
18. `bundle exec rspec <file>` passes
