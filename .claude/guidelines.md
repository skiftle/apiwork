# Ruby & Rails – Code Philosophy and Style Guide

Claude, always follow these principles when working in this project.

This is not just a style guide.  
It’s a philosophy.  
Code should _feel right_ — clean, honest, and effortless to read.  
Simplicity is not the absence of complexity; it’s the result of care.

---

## 🧠 Philosophy

- **Readability over cleverness.**  
  Code should make sense immediately. If you need to explain it, it’s probably wrong.

- **Simplicity as a moral quality.**  
  The goal isn’t to impress — it’s to respect whoever reads or maintains this later (including yourself).

- **Classic Ruby elegance.**  
  No unnecessary meta-programming, no “look what Ruby can do” moments.  
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
    **Exception:** well-established terms like `param` are acceptable  
    when they are the natural choice within their domain.
- Don't repeat what's already in the namespace:
  - `CaseTransformer.hash`, not `transform_keys`.
- Prefer composition over inheritance.
- Avoid legacy `self.included(base)` + `base.extend(ClassMethods)` patterns.  
  Use `ActiveSupport::Concern` instead — it’s cleaner, more expressive, and automatically handles class method extensions:

  ```ruby
  # ✅ Preferred
  module MyFeature
    extend ActiveSupport::Concern

    class_methods do
      def greet
        "hello"
      end
    end
  end

  # ❌ Legacy
  module MyFeature
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def greet
        "hello"
      end
    end
  end
  ```

# 🧩 Guidelines — Naming & Block Chains

---

### 🧩 Naming should reflect what something **is** – not how it’s used

Variable names must describe **what** something represents — not **how** it’s used or **when** it’s used.  
The goal is to keep code self-documenting, consistent, and logically easy to follow.

#### ✅ Example

```ruby
key_transform = serialize_key_transform
CaseTransformer.hash(meta, key_transform)
```

#### ✅ Also acceptable

```ruby
strategy = serialize_key_transform
CaseTransformer.hash(meta, strategy)
```

> This is perfectly fine because the method being called — `CaseTransformer.hash` —
> expects its argument to be called `strategy`.
> Matching a method's parameter name is valid and preferred for consistency.

**Note:** No need to check `== :none` before calling — `CaseTransformer.hash` handles `:none` internally.

---

#### 📖 Rules

- Always name things by **what they are**.
- Use natural English order (adjective → noun):  
  ✅ `paginated_invoices`, ❌ `invoices_paginated`.
- Avoid names that misrepresent the value (`opts`, `tmp`, `context`) if it has a clear meaning.
- It’s perfectly acceptable to use:
  - `result` — when the method’s purpose is to build and return that result.
  - `strategy` (or similar) — when that’s the **expected parameter name** or the correct concept in the method being called.
- Keep names consistent within their local context.
- Update all references when renaming.
- Never change behavior.

#### ✅ Example — `result` is fully acceptable

```ruby
def build_includes_hash(visited = Set.new)
  result = {}

  associations.each do |assoc_name, assoc_def|
    resource_class = assoc_def[:resource] || RapidResource::ResourceResolver.from_association(association, self)

    if resource_class.respond_to?(:build_includes_hash)
      nested = resource_class.build_includes_hash(visited)
      result[assoc_name] = nested.any? ? nested : {}
    else
      result[assoc_name] = {}
    end
  end

  result
end
```

> In this case, `result` is the clearest and most accurate name — it represents the full return value of the method.

#### ✅ Example — `strategy` matches method context

```ruby
# Method definition elsewhere:
# def self.transform(meta, strategy)
#   ...
# end

strategy = serialize_key_transform
CaseTransformer.hash(meta, strategy)
```

> When the called method's parameter is named `strategy`,
> using `strategy` locally improves clarity by aligning with that conceptual contract.

---

### 🚫 Avoid multi-line block chains (applies to `do ... end`)

Chaining Ruby blocks (like `map`, `select`, `each`) across multiple lines using `do ... end` is **not allowed**.  
It hurts readability and violates the RuboCop rule `Style/MultilineBlockChain`.

Shorthand `{ ... }` blocks **are allowed** to span multiple lines when it’s natural and readable —  
for example, in simple pipeline-like expressions.

#### ❌ Wrong

```ruby
collection
  .map do |item|
    process(item)
  end
  .select do |item|
    valid?(item)
  end
```

#### ✅ Right

Split the chain into clear, named steps:

```ruby
mapped = collection.map do |item|
  process(item)
end

selected = mapped.select do |item|
  valid?(item)
end
```

#### ✅ Also fine (shorthand version)

```ruby
collection
  .map { process(_1) }
  .select { valid?(_1) }
```

> Multi-line `do ... end` chains reduce readability.  
> `{ ... }` shorthand is allowed when the intent remains clear and concise.

---

## 🔤 Consistent word order

Use the noun first (what it is), followed by its property (how it is).  
This helps related objects group naturally in the code.

| ❌ Wrong             | ✅ Right             |
| -------------------- | -------------------- |
| `invoices_paginated` | `paginated_invoices` |
| `user_serialized`    | `serialized_user`    |
| `params_query`       | `query_params`       |

> 💬 Readable code feels like natural English:  
> **“paginated invoices”**, not **“invoices paginated.”**

---

## ✨ Summary

- Name things after **what they are**.
- Keep word order natural (adjective → noun).
- Avoid variable names that distort meaning.
- Prefer clarity over brevity.

> **Good code should sound like a clear sentence when read aloud.**

- Name predicates positively: `allowed?`, `active?`, not `not_allowed?`.
- Prefer `include?` / `exclude?` over `in?` — they are clearer, more Ruby-like, and positively expressed.

  ```ruby
  list.exclude?(key)   # ✅ not !key.in?(list)
  list.include?(key)   # ✅ natural and idiomatic
  ```

  Use `exclude?` instead of negating `in?` or `include?` — it reads cleaner and stays true to the principle of writing positive conditions.  
  **Exception:** when explicitly validating that a value is a boolean (`true` or `false`),  
  `[true, false].include?(value)` is acceptable, as it clearly expresses intent.

  ```

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
  These read more naturally and reveal intent at a glance.

---

## ✅ Good vs ❌ Bad — Common Patterns

```ruby
# ❌ Bad
if !user.active?
  deactivate_account
end

# ✅ Good
unless user.active?
  deactivate_account
end

# ❌ Bad
if order.total > 0
  charge(order)
end

# ✅ Good
if order.total.positive?
  charge(order)
end

# ❌ Bad
if !items.empty?
  process(items)
end

# ✅ Good
if items.any?
  process(items)
end

# ❌ Bad
if user.admin? == false
  deny_access
end

# ✅ Good
unless user.admin?
  deny_access
end

# ❌ Bad
if completed == false && archived == false
  mark_as_pending
end

# ✅ Good
return if completed || archived
mark_as_pending
```
