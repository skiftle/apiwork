# YARD Documentation Audit Checklist

Run this audit to verify YARD documentation accuracy and consistency.

---

## 1. Return Types for Class References

Methods that return **class objects** (not instances) must use `Class<Type>`:

```ruby
# Bad
@return [Representation::Base]  # implies instance
@return [Class]                  # too vague

# Good
@return [Class<Representation::Base>]
@return [Class<ActiveRecord::Base>]
```

**Check:** `grep -rn "@return \[Class\]" lib/`

---

## 2. Getter/Setter Method Style

Simple, direct description. No "Gets or sets" phrasing.

```ruby
# Bad
# Gets or sets the output type for this export.
#
# Without arguments, returns the current output type.
# With an argument, sets the output type.

# Good
# The output type for this export.
#
# @param type [Symbol, nil] :hash or :string
# @return [Symbol, nil]
def output(type = nil)
```

The `@param` and `@return` tags make the getter/setter behavior clear.

---

## 3. Parameter Types Must Match Signature

If a parameter has a default value of `nil`, document it:

```ruby
# Bad - signature allows nil but doc doesn't show it
# @param name [Symbol] the name
def export_name(name = nil)

# Good
# @param name [Symbol, nil] the name
def export_name(name = nil)
```

---

## 4. No @raise for Abstract Methods

Don't document `@raise [NotImplementedError]` on abstract methods. The pattern is obvious from the code.

```ruby
# Bad
# @return [Hash]
# @raise [NotImplementedError] subclasses must implement
def serialize
  raise NotImplementedError
end

# Good
# @return [Hash]
def serialize
  raise NotImplementedError
end
```

---

## 5. Documentation Must Match Code

Before documenting a parameter or behavior, verify it exists in the actual method signature.

**Common mistakes:**
- Documenting parameters that don't exist
- Wrong parameter types
- @return type doesn't match actual return value

---

## Audit Commands

```bash
# Find potential Class<> issues
grep -rn "@return \[Class\]" lib/
grep -rn "@return \[.*Base\]" lib/ | grep -v "Class<"

# Find "Gets or sets" patterns to review
grep -rn "Gets or sets" lib/

# Find potential parameter mismatches (manual review needed)
grep -rn "@param.*\[.*\]" lib/ --include="*.rb"
```

---

## Files Audited

Track completed audits here:

| Date | Area | Result |
|------|------|--------|
| 2025-02-07 | lib/apiwork/adapter/ | Clean |
| 2025-02-07 | lib/apiwork/introspection/ | Clean |
| 2025-02-07 | lib/apiwork/representation/ | Fixed |
| 2025-02-07 | lib/apiwork/export/ | Fixed |
| 2025-02-07 | lib/apiwork/api.rb | Fixed |
| 2025-02-07 | lib/apiwork/adapter.rb | Fixed |
| 2025-02-07 | lib/apiwork/export.rb | Fixed |
| 2025-02-07 | docs/guide/ | Clean |
