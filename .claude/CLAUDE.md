# Ruby & Rails – Code Philosophy and Style Guide

Claude, always follow these principles when working in this project.

This is not just a style guide.
It's a philosophy.
Code should _feel right_ — clean, honest, and effortless to read.
Simplicity is not the absence of complexity; it's the result of care.

---

## 🎯 The Simplification Mindset

Everything should be **super simple** and **straight-forward**.

This isn't just about writing less code — it's about writing code that feels **inevitable**.
When you read it, it should feel like "of course, this is how it works."

### The 10/10 Rule

A system is **10 out of 10** when:

1. **The architecture is flawless** — the design is sound, responsibilities are clear
2. **The implementation is minimal** — no unnecessary abstraction, no duplication
3. **The naming is obvious** — you don't need to think about what something means
4. **The code reads naturally** — like well-written prose, not a puzzle

**We don't compromise.** If the system is right but the implementation is messy, we refactor.
If the naming is verbose, we simplify. If there's duplication, we consolidate.

### Consolidation Over Duplication

**One way to do it. Not three.**

When you find multiple classes doing nearly identical things, **consolidate them into one**.

Example: We had three separate builders for descriptors. The solution? ONE builder with a `scope` parameter.

```ruby
# One builder, all contexts
class Contract::Descriptor::Builder
  def initialize(api_class: nil, scope: nil)
    @scope = scope  # nil = global, ContractClass = contract-scoped
  end
end

# Used everywhere the same way
builder = Builder.new(api_class: api, scope: nil)           # Global
builder = Builder.new(api_class: api, scope: ContractClass) # Contract-scoped
```

**Result:** ~100 lines deleted, single source of truth, easier to understand.

**The principle:** If the only difference is configuration, use parameters — not separate classes.

### Parameters Over Proliferation

**Don't create multiple classes when a parameter will do.**

When you find yourself creating `GlobalSomething` and `ScopedSomething`, or `SomethingForApi` and `SomethingForContract` — **stop.** You probably need one class with a parameter.

```ruby
# ❌ Bad - class proliferation
class GlobalTypeRegistrar
  def register(name, &block) ...
end

class ScopedTypeRegistrar
  def register(name, scope, &block) ...
end

# ✅ Good - one class with parameter
class TypeRegistrar
  def register(name, scope: nil, &block)
    # scope = nil means global, scope = ContractClass means scoped
  end
end
```

### Method Naming: Nouns for Getters

Method names should be **nouns for getters**, **verbs for actions**.

Don't repeat context that's already obvious from the namespace or class.

```ruby
# ❌ Before - verbose and redundant
TypeStore.serialize_all_types_for_api(api)
EnumStore.serialize_all_enums_for_api(api)

# ✅ After - simple and clean
TypeStore.serialize(api)
EnumStore.serialize(api)
Registry.types(api)      # Returns types - the method name IS the thing
Registry.enums(api)      # Returns enums - clear and direct
```

**The rule:** Name what it **is** or **does** — nothing more, nothing less.

### Unified Storage Over Fragmentation

**Don't create multiple storage levels when one will do.** Fewer storage structures = simpler code.

---

## 🧱 Composition Over Modules

**Prefer class instances over modules.** Modules create hidden coupling; class instances make dependencies explicit and testable.

```ruby
# ❌ Bad - module mixed into class
class Api::Base
  include Recorder
end

# ✅ Good - class instance as collaborator
class Api::Base
  def initialize
    @recorder = Recorder.new(@metadata, @namespaces)
  end
end
```

**Exceptions:** `ActiveSupport::Concern` for DSLs, standard library extensions, true interface contracts.

### One Class, One File

**Every class and module lives in its own file.** No inline classes, no multiple classes per file.

```ruby
# ❌ Bad - inline class
class Builder
  class Result  # Should be its own file
    attr_reader :value
  end
end

# ✅ Good - separate files
# lib/builder.rb
class Builder; end

# lib/builder/result.rb
class Builder::Result; end
```

### Extract for Concepts, Not Lines

**Don't create helpers just to save lines.** Only extract when there's a genuine conceptual win — a named idea that makes the code clearer.

```ruby
# ❌ Bad - extracting just to DRY
def format_date(d) = d.strftime("%Y-%m-%d")  # Used twice, no concept

# ✅ Good - a real concept with a name
class CaseTransformer
  def self.camelize(s) ... end
  def self.snake(s) ... end
end
```

**The test:** Would this extraction make the code *easier to understand*, or just shorter? If just shorter, don't extract. Three similar lines is better than a premature abstraction.

**Never create:** `helpers/`, `utils/`, `misc/` — these are code graveyards. If you can't name the concept, it doesn't exist yet.

---

## 🧠 Philosophy

- **Readability over cleverness.**
  Code should make sense immediately. If you need to explain it, it's probably wrong.

- **Simplicity as a moral quality.**
  The goal isn't to impress — it's to respect whoever reads or maintains this later (including yourself).

- **Classic Ruby elegance.**
  No unnecessary meta-programming, no "look what Ruby can do" moments.
  Just clean, natural, confident code.

- **Rails-ness matters.**
  It should _feel_ like Rails — declarative, expressive, and grounded in convention.

- **Never break what already works.**
  Refactor inside, not outside. The public API stays untouched, and the tests stay green.

- **Clean up as you go.**
  When you change an approach or refactor a feature, remove the legacy code that's no longer needed.
  Dead code is not neutral — it confuses, misleads, and costs maintenance.
  Leave the codebase cleaner than you found it.

- **Breaking changes are fine — this is pre-release.**
  Don't preserve backward compatibility just because something exists.
  If a better approach emerges, take it. Remove the old way entirely.
  We're still shaping the API. Make it right, not compatible.

- **Rails Reloading — use stable identifiers.**
  Rails reloads classes in development. Use stable identifiers (like `mount_path`) for registry keys, not class references that become stale on reload.

---

## 📝 No Comments

**Code should speak for itself.** If logic needs explaining, extract it to a well-named method.

```ruby
# ❌ Bad
# Check if user can make API call
if user.subscription_tier == 'premium' && user.api_calls_this_month < 10_000

# ✅ Good
if user.can_make_api_call?
```

**Only allowed comments:**
- Magic comments: `# frozen_string_literal: true`
- RuboCop directives: `# rubocop:disable Metrics/AbcSize`
- Temporary TODOs (should become issues)

---

## ✨ Core Principles

- Small, focused objects. One clear responsibility.
- Simplicity over complexity — even if it means writing more lines.
- Explicit over implicit. Avoid magic, monkey patching, and surprises.
- Use guard clauses instead of deep nesting.
- **Don't duplicate conditional logic between call site and method.**
  If a condition is part of the method's internal logic, it belongs in the method — not at the call site.
  ```ruby
  # ❌ Bad - duplicate guard logic
  validate_association_exists! if @model_class

  def validate_association_exists!
    return unless @model_class  # Same check! This is the method's responsibility
    # ...
  end

  # ✅ Good - single guard clause in method
  validate_association_exists!

  def validate_association_exists!
    return unless @model_class
    # ...
  end
  ```

  **Exception:** Surrounding context conditions that aren't part of the method's responsibility can stay at the call site.
  ```ruby
  # ✅ OK - surrounding context condition
  send_notification if user.opted_in?

  def send_notification
    # Method doesn't care about opt-in status, that's caller's concern
    mailer.deliver_now
  end
  ```

  **The rule:** If the condition is part of the method's validation or core logic, move it inside. If it's about *whether to call* the method based on external context, it can stay outside.
- Write positive conditions. Avoid `unless`, `!`, and `== false`.
  **Exception:** `unless` may be used when it reads naturally and clearly with a simple condition,
  e.g. `unless completed` ✅
  but not with compound or negative logic (`unless !foo` or `unless a && b`) ❌
- No unnecessary abbreviations — prefer full, expressive names:
  - `attribute` instead of `attr`
    **Exception:** well-established terms like `param` and standard Ruby methods like `attr_reader` are acceptable.
- Don't repeat what's already in the namespace:
  - `CaseTransformer.hash`, not `transform_keys`.
- Prefer composition over inheritance. See [Composition Over Modules](#-composition-over-modules) for details.
- Use `ActiveSupport::Concern` instead of legacy `self.included(base)` + `base.extend(ClassMethods)` patterns.

---

## 🏗️ Class References

**Always use class constants (not strings) for class references** to leverage Zeitwerk autoloading and enable proper static analysis.

```ruby
# ✅ Correct - uses class constants
class UserResource < Resource::Base
  has_one :profile, class_name: ProfileResource
  has_many :posts, class_name: PostResource
end

class UserContract < Contract::Base
  resource UserResource
end

# ❌ Wrong - uses strings unnecessarily
has_one :profile, class_name: 'ProfileResource'
resource 'UserResource'
```

**Exception: Use strings in contexts where classes aren't loaded yet:**
- In `config/routes.rb` before application loads
- In configuration files that run before autoloading
- When dealing with dynamic/runtime class names

**Why class constants?**
- Works seamlessly with Zeitwerk autoloading
- Better IDE support (jump to definition, refactoring)
- Catches typos at load time instead of runtime
- Clearer dependencies and static analysis

---

## 🎯 Option Naming - Context Matters

**Don't repeat the context in option names.** When you're already in a Resource class, omit the `resource_` prefix. When in a Contract class, omit the `contract_` prefix.

```ruby
# ✅ In Resource class - context is clear, omit prefix
class PostResource < Resource::Base
  has_one :author, class_name: 'UserResource'      # ✅ not resource_class_name
  has_many :tags, class_name: 'TagResource'        # ✅ clean and clear
end

# ✅ In Contract class - context is clear, omit prefix
class PostContract < Contract::Base
  resource 'PostResource'                           # ✅ not resource_class_name
end

# ✅ Outside context - use full prefix for clarity
class SomeHelper
  def initialize(resource_class_name:)              # ✅ prefix needed here
    @resource = resource_class_name.constantize
  end
end
```

**The rule:** If the target class type is the "main" concept of where you are, omit the prefix. Otherwise, include it for clarity.

---

## 🧩 Naming Guidelines

### Names should reflect what something **is** – not how it's used

Variable names must describe **what** something represents — not **how** it's used or **when** it's used.

```ruby
# ✅ Good - describes what it is
key_transform = serialize_key_transform
CaseTransformer.hash(meta, key_transform)

# ✅ Also good - matches method parameter name
strategy = serialize_key_transform
CaseTransformer.hash(meta, strategy)

# ✅ Good - result represents the full return value
def build_includes_hash
  result = {}
  associations.each { |name, defn| result[name] = {} }
  result
end
```

### Natural word order (adjective → noun)

Use the noun first (what it is), followed by its property (how it is).

| ❌ Wrong             | ✅ Right             |
| -------------------- | -------------------- |
| `invoices_paginated` | `paginated_invoices` |
| `user_serialized`    | `serialized_user`    |
| `params_query`       | `query_params`       |

### Don't shorten or change variable names

**Keep the full semantic name when deriving new variables.** Don't abbreviate or rename just to be brief.

```ruby
# ✅ Good - preserves full semantic meaning
action_name_sym = action_name.to_sym
user_id_str = user_id.to_s
params_json = params.to_json
invoice_total = invoice.total
customer_email = customer.email

# ❌ Bad - loses or changes semantic meaning
action_sym = action_name.to_sym       # What action? "name" is lost
id_str = user_id.to_s                 # Which ID? "user" is lost
json_data = params.to_json            # Renames "params" to "data"
total = invoice.total                 # "invoice" context is lost
email = customer.email                # Which email? "customer" is lost
```

**The rule:** Append modifiers to the full name, never replace or shorten it.

- Type conversions: `original_name_type` (e.g., `action_name_sym`)
- Derived values: `original_name_property` (e.g., `invoice_total`)
- Transformed data: `transformed_original_name` (e.g., `serialized_user`)

This keeps variables **traceable** — you can always see where the data came from.

### Positive predicates

Name predicates positively: `allowed?`, `active?`, not `not_allowed?`.

```ruby
# ✅ Good - positive predicates
list.include?(key)
list.exclude?(key)

# ❌ Bad - negative predicates
!list.include?(key)
!key.in?(list)
```

---

## 🚫 Avoid multi-line block chains

Chaining Ruby blocks using `do ... end` across multiple lines is **not allowed**.

```ruby
# ❌ Bad - chained do...end blocks
collection
  .map do |item|
    process(item)
  end
  .select do |item|
    valid?(item)
  end

# ✅ Good - split into named steps
processed = collection.map do |item|
  process(item)
end

validated = processed.select do |item|
  valid?(item)
end

# ✅ Also good - shorthand blocks
collection
  .map { process(_1) }
  .select { valid?(_1) }
```

---

## 🎯 Method Arguments: Positional vs Keyword vs Options

**Choose the right argument style for clarity and maintainability.**

### Positional arguments
Use when the argument is **unambiguous, essential, and has fixed order**.

```ruby
# ✅ Good - obvious from method name
User.find(id)
Money.new(amount, currency)
distance(point_a, point_b)

# ❌ Bad - unclear meaning
resize(800, 600)           # width/height? who knows
broadcast(event, true)     # what does true mean?
```

**Rule:** If you can guess what the argument means without a name → positional.

**Avoid positional when:**
- Hard to remember the order
- Not mandatory
- More than 2–3 arguments

### Keyword arguments
Use when **readability matters** or **meaning isn't self-evident**.

```ruby
# ✅ Good - self-documenting
resize(width: 800, height: 600)
paginate(page: 1, per_page: 20)
broadcast(event, async: true)

# ✅ Good - multiple optional arguments
def send_email(to:, subject:, body:, cc: nil, bcc: nil, priority: :normal)
end
```

**Benefits:**
- Order doesn't matter
- Self-documenting
- Future-proof (can add more without breaking)
- IDE-friendly

**Prefer keyword args for:**
- Boolean flags
- Optional arguments
- When there are > 2 arguments
- Rails-style declarative APIs

### Options hash (`**options`)
Use **sparingly** — only when the API is truly open-ended or dynamic.

```ruby
# ✅ Good - genuinely dynamic/extensible
define_resource(:invoice, cache: true, **options)
render :template, locals: { ... }, layout: true

# ❌ Bad - you know the keys, use keyword args instead
def resize(**options)  # Vague, avoid
  width = options[:width]
  height = options[:height]
end

# ✅ Better
def resize(width:, height:)
end
```

**Rule:** If you know the keys → keyword args. If you don't → options hash.

### Combining styles

**Order matters:** positional → keyword → splat

```ruby
# ✅ Correct order
def process(data, mode:, format: :json, **options)
end

# ❌ Wrong order
def process(mode:, data, **options)  # positional after keyword
end
```

### Specific guidelines

**Booleans:** Always keyword, never positional
```ruby
broadcast(event, async: true)  # ✅ clear
broadcast(event, true)         # ❌ unclear
```

**Constructors:** Positional for essentials, keyword for everything else
```ruby
User.new(email:, name:, admin: false, verified: true)
```

**More than 3 arguments?** → Consider keyword args or a parameter object
```ruby
# ❌ Too many positional
def create_invoice(customer, amount, currency, due_date, notes)
end

# ✅ Better - keyword args
def create_invoice(customer:, amount:, currency:, due_date:, notes: nil)
end

# ✅ Best - parameter object when it gets complex
params = InvoiceParams.new(customer:, amount:, currency:, due_date:)
create_invoice(params)
```

---

## 💎 Ruby / Rails Idioms to Prefer

- `map(&:to_s)`, `select(&:present?)`, `reject(&:blank?)`, `compact_blank`
- `index_by`, `each_with_object({})`, `group_by`, `sum(&:value)`
- `delegate`, `attr_reader` + memoization (`@x ||= ...`)
- `tap`, `then`, `yield_self` for fluent, expressive flow
- `present?`, `blank?`, `presence`, `deep_symbolize_keys`, `with_indifferent_access`
- Freeze constants: `FOO = {...}.freeze`
- Use **keyword arguments** in public methods.
- Keep domain logic separate from I/O (files, network, serialization).
- **Use Ruby 3 hash shorthands** when key and variable names match:
  ```ruby
  { title, value } # ✅ not { title: title, value: value }
  ```
- **Prefer expressive predicate methods over manual comparisons:**
  ```ruby
  amount.positive?   # ✅ not amount > 0
  amount.negative?   # ✅ not amount < 0
  collection.any?    # ✅ not collection.size > 0
  collection.many?   # ✅ not collection.length > 1
  value.zero?        # ✅ not value == 0
  string.empty?      # ✅ not string == ""
  ```

---

## 🔄 Autoloading with Zeitwerk

**Never use `require` or `require_relative` for application code when Zeitwerk can handle it.**

Rails uses Zeitwerk for autoloading. Let it do its job.

```ruby
# ❌ Bad - manual requires in app code
require 'app/models/user'
require_relative '../services/user_service'

# ✅ Good - just use the class, Zeitwerk loads it
User.find(1)
UserService.new.call
```

**When to use `require`:**
- Loading gems or standard library: `require 'json'`, `require 'net/http'`
- In `lib/` files that aren't in the autoload path
- In test setup or configuration files

**The rule:** If it's in `app/`, `lib/apiwork/`, or other autoloaded paths, don't require it.

---

## 📚 Documentation

**Keep docs in sync with code.** When you change behavior, update the corresponding documentation.

Documentation lives in `docs/`. Key areas:
- `docs/04-schemas/` — Schema DSL and options
- `docs/03-contracts/` — Contract definitions
- `docs/05-type-system/` — Types, enums, unions

**Rule:** If you change how something works, check if docs mention it. Update them in the same commit.

---

## 🎨 Code Style & Linting

**Always follow RuboCop rules.** This project uses RuboCop to enforce consistent style.

- **Run `bundle exec rubocop -a` on every file you create or modify** — auto-fix safe offenses immediately
- Fix all RuboCop offenses, don't disable cops without good reason
- RuboCop's suggestions are not optional — they're part of our style
- Use `rubocop -A` for aggressive auto-corrections only when appropriate

**Workflow:**
1. Write or modify code
2. Run `bundle exec rubocop -a <file_path>` to auto-fix
3. Address any remaining offenses manually
4. Verify tests still pass

**If you think a RuboCop rule should be changed, discuss it first.** Don't just disable it.

---

## ✅ Good vs ❌ Bad — Quick Reference

| ❌ Bad | ✅ Good |
|--------|---------|
| `if !user.active?` | `unless user.active?` |
| `if order.total > 0` | `if order.total.positive?` |
| `if !items.empty?` | `if items.any?` |
| `if user.admin? == false` | `unless user.admin?` |
| `if x == false && y == false` | `return if x \|\| y` |
