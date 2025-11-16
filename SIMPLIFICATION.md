# The Simplification Mindset

Everything should be **super simple** and **straight-forward**.

This isn't just about writing less code — it's about writing code that feels **inevitable**.
When you read it, it should feel like "of course, this is how it works."

---

## Core Philosophy: The 10/10 Rule

A system is **10 out of 10** when:

1. **The architecture is flawless** — the design is sound, responsibilities are clear
2. **The implementation is minimal** — no unnecessary abstraction, no duplication
3. **The naming is obvious** — you don't need to think about what something means
4. **The code reads naturally** — like well-written prose, not a puzzle

**We don't compromise.** If the system is right but the implementation is messy, we refactor.
If the naming is verbose, we simplify. If there's duplication, we consolidate.

---

## Consolidation Over Duplication

**One way to do it. Not three.**

When you find multiple classes doing nearly identical things, **consolidate them into one**.

### Example: The Unified Builder Pattern

We had three separate builders for descriptors:
- `GlobalBuilder` for API-level types/enums
- `DescriptorBuilder` for contract-scoped types/enums (but no unions!)
- Direct implementation in `Contract::Base`

**The problem:** Duplication. Different capabilities. Hard to maintain.

**The solution:** ONE builder with a `scope` parameter.

```ruby
# One builder, all contexts
class Contract::Descriptor::Builder
  def initialize(api_class: nil, scope: nil)
    @api_class = api_class
    @scope = scope  # nil = global, ContractClass = contract-scoped
  end

  def type(name, &block)
    Registry.register_type(name, scope: @scope, api_class: @api_class, &block)
  end

  def enum(name, values)
    Registry.register_enum(name, values, scope: @scope, api_class: @api_class)
  end

  def union(name, &block)
    Registry.register_union(name, scope: @scope, api_class: @api_class, &block)
  end
end

# Used everywhere the same way
# Global descriptors
builder = Builder.new(api_class: api, scope: nil)

# Contract-scoped descriptors
builder = Builder.new(api_class: api, scope: ContractClass)
```

**Result:**
- ~100 lines of code deleted
- Contracts gained union support automatically
- Single source of truth
- Easier to test, easier to understand

**The principle:** If the only difference is configuration, use parameters — not separate classes.

---

## Method Naming: Simple and Direct

Method names should be **nouns for getters**, **verbs for actions**.

Don't repeat context that's already obvious from the namespace or class.

### Before: Verbose and Redundant

```ruby
TypeStore.serialize_all_types_for_api(api)
EnumStore.serialize_all_enums_for_api(api)
Registry.serialize_all_for_api(api)
```

**Problems:**
- "serialize_all" is redundant — of course we're serializing all of them
- "_for_api" is redundant — the parameter already says it's an API
- Too long, too much typing, too much thinking

### After: Simple and Clean

```ruby
TypeStore.serialize(api)
EnumStore.serialize(api)
Registry.types(api)
Registry.enums(api)
```

**Why better:**
- Shorter, clearer
- The method name describes **what it returns**, not how
- `types(api)` reads naturally: "give me the types for this API"
- Follows Rails conventions (like `User.all`, not `User.get_all_users`)

### More Examples

| ❌ Before                        | ✅ After              | Why                                   |
| -------------------------------- | --------------------- | ------------------------------------- |
| `qualified_name(scope, name)`    | `scoped_name(scope, name)` | "scoped" is clearer than "qualified"  |
| `extract_payload_value(meta)`    | `resolved_value(meta)`     | "resolved" describes what it is       |
| `extract_contract_prefix(scope)` | `scope_prefix(scope)`      | Don't repeat "extract"                |
| `serialize_all_for_api(api)`     | `serialize(api)`           | Context is obvious from parameter     |

**The rule:** Name what it **is** or **does** — nothing more, nothing less.

---

## Parameters Over Proliferation

**Don't create multiple classes when a parameter will do.**

When you find yourself creating:
- `GlobalSomething` and `ScopedSomething`
- `SomethingForApi` and `SomethingForContract`
- `SomethingWithX` and `SomethingWithoutX`

**Stop.** You probably need one class with a parameter.

```ruby
# ❌ Bad - proliferation
class GlobalTypeRegistrar
  def register(name, &block)
    # ...
  end
end

class ScopedTypeRegistrar
  def register(name, scope, &block)
    # ...
  end
end

# ✅ Good - one class with parameter
class TypeRegistrar
  def register(name, scope: nil, &block)
    # scope = nil means global
    # scope = ContractClass means scoped
  end
end
```

**Benefits:**
- Less code to maintain
- Changes apply everywhere at once
- Easier to test (one class, multiple scenarios)
- Clear design (scope is just configuration)

---

## Storage: Unified Over Fragmented

**Don't create multiple storage levels when one will do.**

We used to have 4 storage levels for types/enums:
1. Global types
2. API-scoped types
3. Contract-scoped types
4. Per-contract instance types

**The problem:** Complex lookup logic. Hard to reason about. Lots of code.

**The solution:** ONE unified storage with metadata.

```ruby
# Before: 4 storage levels, complex resolution
@global_types = {}
@api_types = {}
@contract_types = {}
@instance_types = {}

# After: 1 storage with scope metadata
@storage = {
  api_mount_path => {
    user_status: {
      name: :user_status,
      scoped_name: :user_status,
      scope: nil,
      payload: { ... }
    },
    post_status: {
      name: :status,
      scoped_name: :post_status,
      scope: PostContract,
      payload: { ... }
    }
  }
}
```

**Result:**
- Simpler resolution: just hash lookup
- Single code path for all scopes
- Easier to serialize (just iterate the hash)
- Survives Rails reloading (keyed by mount_path)

**The principle:** Fewer storage structures = simpler code.

---

## Delete What You Don't Need

**When you consolidate, DELETE the old code.**

Don't leave it around "just in case." Dead code is:
- Confusing (which one is used?)
- Misleading (looks important, but isn't)
- A maintenance burden (shows up in searches, needs updating)

After creating the unified Builder, we **deleted**:
- `lib/apiwork/contract/descriptor/global_builder.rb`
- `lib/apiwork/api/descriptor_builder.rb`

**Gone.** Not commented out. Not marked deprecated. Deleted.

**The rule:** If it's not used, remove it. The git history remembers.

---

## Naming Variables: Full Semantic Meaning

**Don't abbreviate or rename variables when deriving values.**

Keep the full semantic name and append the transformation.

```ruby
# ✅ Good - preserves full context
action_name_sym = action_name.to_sym
scoped_name_value = scoped_name(scope, name)
user_id_str = user_id.to_s

# ❌ Bad - loses context
action_sym = action_name.to_sym    # What action? "name" is lost
qualified = scoped_name(scope, name)  # Vague, what does qualified mean?
id_str = user_id.to_s              # Which ID? "user" is lost
```

**Why it matters:**
- Variables are **traceable** — you can see where the data came from
- No cognitive overhead — you don't wonder "what is `qualified`?"
- Grep-friendly — searching for `scoped_name` finds all uses

**The pattern:**
- Type conversions: `original_name_type` (e.g., `action_name_sym`)
- Derived values: `original_name_property` (e.g., `invoice_total`)
- Transformed data: `transformed_original_name` (e.g., `serialized_user`)

---

## Rails Reloading: Design For It

**Rails reloads classes in development. Design your registries to survive it.**

### The Problem

In development, Rails reloads your code on every request.
If you store data using class references as keys, those references become stale.

```ruby
# ❌ Bad - breaks on reload
@storage[PostContract] = { ... }  # PostContract reference becomes stale
```

### The Solution

**Use stable identifiers that survive reloading.**

For API registries, use `mount_path`:

```ruby
# ✅ Good - survives reload
@storage[api.mount_path] = { ... }  # '/api/v1' is stable
```

For contract-scoped types, store the scope but namespace by API mount path:

```ruby
# Storage structure
@storage = {
  '/api/v1' => {
    user_status: { scope: nil, ... },           # Global
    post_status: { scope: PostContract, ... }   # Contract-scoped
  }
}
```

**Why it works:**
- `mount_path` is a string, doesn't change on reload
- Contract classes are re-registered on reload
- Idempotent registration (same type can be registered again)

**The principle:** Use stable, serializable identifiers for registry keys.

---

## Testing: The Final Arbiter

**All changes must keep tests green.**

We have 547 tests. After every change:

```bash
bundle exec rspec
```

**If tests fail:**
- Fix the code (not the tests, unless they're wrong)
- Don't commit broken tests
- Don't skip tests to make things pass

**If tests pass:**
- You're probably good
- But also sanity-check: does the API make sense?

**The rule:** Green tests are necessary but not sufficient. The code still has to feel right.

---

## Summary: The Apiwork Way

1. **Consolidate** — one way to do it, not three
2. **Simplify names** — short, direct, no redundancy
3. **Use parameters** — not separate classes for every variation
4. **Unify storage** — fewer storage levels, simpler code
5. **Delete dead code** — ruthlessly
6. **Preserve semantics** — full variable names, always
7. **Design for reloading** — stable identifiers in registries
8. **Keep tests green** — 547 tests, 0 failures

**When in doubt, ask:**
- Is this the simplest way?
- Would I understand this in 6 months?
- Can I explain it in one sentence?

If the answer is no, simplify until it's yes.
