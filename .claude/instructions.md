# Ruby & Rails – Code Philosophy and Style Guide

Claude, always follow these principles when working in this project.

This is not just a style guide.
It's a philosophy.
Code should _feel right_ — clean, honest, and effortless to read.
Simplicity is not the absence of complexity; it's the result of care.

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

---

## ✨ Core Principles

- Small, focused objects. One clear responsibility.
- Simplicity over complexity — even if it means writing more lines.
- Explicit over implicit. Avoid magic, monkey patching, and surprises.
- Use guard clauses instead of deep nesting.
- Write positive conditions. Avoid `unless`, `!`, and `== false`.
  **Exception:** `unless` may be used when it reads naturally and clearly with a simple condition,
  e.g. `unless completed` ✅
  but not with compound or negative logic (`unless !foo` or `unless a && b`) ❌
- No unnecessary abbreviations — prefer full, expressive names:
  - `attribute` instead of `attr`
    **Exception:** well-established terms like `param` and standard Ruby methods like `attr_reader` are acceptable.
- Don't repeat what's already in the namespace:
  - `CaseTransformer.hash`, not `transform_keys`.
- Prefer composition over inheritance.
- Use `ActiveSupport::Concern` instead of legacy `self.included(base)` + `base.extend(ClassMethods)` patterns.

---

## 🏗️ Class References & Lazy Loading

**Always use strings for class references** to enable lazy loading and avoid eager loading dependencies.

```ruby
# ✅ Correct - uses strings
class UserResource < Resource::Base
  has_one :profile, class_name: 'ProfileResource'
  has_many :posts, class_name: 'PostResource'
end

class UserContract < Contract::Base
  resource 'UserResource'
end

# ❌ Wrong - uses class constants
has_one :profile, class_name: ProfileResource    # No eager loading!
resource UserResource                             # No constants!
```

**Why strings?**
- Avoids circular dependencies
- Enables lazy loading
- Works with Rails autoloading
- Safer in development with code reloading

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

## 🎨 Code Style & Linting

**Always follow RuboCop rules.** This project uses RuboCop to enforce consistent style.

- Run `bundle exec rubocop` before committing
- Fix all RuboCop offenses, don't disable cops without good reason
- RuboCop's suggestions are not optional — they're part of our style
- Use `rubocop -a` or `rubocop -A` for auto-corrections when safe

**If you think a RuboCop rule should be changed, discuss it first.** Don't just disable it.

---

## ✅ Good vs ❌ Bad — Common Patterns

```ruby
# ❌ Bad - negative condition with !
if !user.active?
  deactivate_account
end

# ✅ Good - positive condition with unless
unless user.active?
  deactivate_account
end

# ❌ Bad - manual comparison
if order.total > 0
  charge(order)
end

# ✅ Good - predicate method
if order.total.positive?
  charge(order)
end

# ❌ Bad - negating empty
if !items.empty?
  process(items)
end

# ✅ Good - using any?
if items.any?
  process(items)
end

# ❌ Bad - comparing with false
if user.admin? == false
  deny_access
end

# ✅ Good - unless
unless user.admin?
  deny_access
end

# ❌ Bad - multiple == false
if completed == false && archived == false
  mark_as_pending
end

# ✅ Good - guard clause with positive logic
return if completed || archived
mark_as_pending
```
