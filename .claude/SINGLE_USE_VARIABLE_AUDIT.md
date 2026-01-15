# Single-Use Variable Audit

Instructions for identifying and removing single-use variable anti-patterns.

---

## Core Rule

**If a variable is assigned and used exactly once, inline it.**

```ruby
# Bad — single-use variable
type_name = pascal_case(name)
"export type #{type_name} = ..."

# Good — inlined
"export type #{pascal_case(name)} = ..."
```

---

## What is a Single-Use Variable?

A variable that:
1. Is assigned a value
2. Is used exactly **once** after assignment
3. Does not have side effects that need to be separated from its usage

```ruby
# Single-use — inline it
schema_name = action_type_name(resource_name, action_name, 'Request')
"export const #{schema_name}Schema = ..."

# NOT single-use — used twice
type = surface.types[type_name]
if type.union?
  build_union(type)
else
  build_object(type)
end

# NOT single-use — used in multiple branches
column = table[key]
case direction
when :asc then column.asc
when :desc then column.desc
end
```

---

## When NOT to Inline

### Multiple uses (including branches)

```ruby
# Keep — used in both branches
base_type = map_param(param)
if condition
  "{ discriminator } & #{base_type}"
else
  base_type
end
```

### Side effects with value usage

```ruby
# Keep — delete has side effect AND value is used
contract = merged.delete(:contract)
contract ? process(contract) : default
```

### Complex expressions that need naming

```ruby
# Keep — name adds clarity for complex expression
filtered_attributes = schema.attributes
  .select(&:filterable?)
  .reject(&:internal?)
  .index_by(&:name)
```

### Long method chains (3+ calls)

```ruby
# Keep — breaking up long chain
sorted_types = TypeAnalysis
  .topological_sort_types(types_hash)
  .map(&:first)
  .reject(&:internal?)

sorted_types.each { |type| ... }
```

---

## Common Patterns to Inline

### String interpolation

```ruby
# Before
type_name = pascal_case(name)
"export type #{type_name} = #{type_literal};"

# After
"export type #{pascal_case(name)} = #{type_literal};"
```

### Method arguments

```ruby
# Before
schema_name = action_type_name(resource, action, 'Request')
build_schema(schema_name)

# After
build_schema(action_type_name(resource, action, 'Request'))
```

### Return values

```ruby
# Before
result = process(data)
result

# After
process(data)
```

### Hash/array literals

```ruby
# Before
members = [base_type, 'null'].sort
base_type = members.join(' | ')

# After
base_type = [base_type, 'null'].sort.join(' | ')
```

### Chained transformations

```ruby
# Before
variants = param.variants.map { |v| map_param(v) }
variants.sort.join(' | ')

# After
param.variants.map { |v| map_param(v) }.sort.join(' | ')
```

---

## Verification Process

### 1. Identify candidates

Search for assignment patterns:

```bash
grep -rE "^\s+(\w+)\s*=\s*[^=]" lib/apiwork/
```

### 2. Verify single-use

For each candidate, check:
- Is the variable used exactly once after assignment?
- Is it used in multiple branches (if/case/ternary)? → NOT single-use
- Does the assignment have side effects? → Consider keeping

### 3. Present findings

Create a table before implementing:

| Fil | Rad | Variabel | Nuvarande | Förslag |
|-----|-----|----------|-----------|---------|
| `path/to/file.rb` | 42 | `var_name` | `var = expr`<br>`use(var)` | Inline |

### 4. Implement and verify

```bash
bundle exec rspec
bundle exec rubocop -A
```

---

## Edge Cases

### Ternary expressions

```ruby
# Single-use — inline
definition = scope ? @store[key] : nil
definition || @store[name]

# Becomes
(scope ? @store[key] : nil) || @store[name]
```

### Block results

```ruby
# Single-use — inline the whole block
schemas = types.map do |type|
  build_schema(type)
end
schemas.join("\n")

# Becomes
types.map { |type| build_schema(type) }.join("\n")
```

### Guard clauses

```ruby
# Keep — guard uses the value
shape = shape_for(part_type)
return [{}, []] unless shape

# NOT single-use — shape is used twice (guard + later)
```

---

## Anti-patterns to Avoid

### Over-inlining

Don't inline if it makes the line too long (>150 chars after rubocop):

```ruby
# Bad — too long after inlining
"export interface #{action_type_name(resource_name, action_name, 'Response', parent_identifiers:)} {\n  body: #{action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)};\n}"

# Good — let rubocop format it or keep variable for readability
```

### Breaking method chains

Don't inline if it creates nested method calls that are hard to read:

```ruby
# Bad — confusing nesting
process(transform(validate(coerce(data))))

# Good — pipeline style
data
  .then { |d| coerce(d) }
  .then { |d| validate(d) }
  .then { |d| transform(d) }
  .then { |d| process(d) }

# Or keep intermediate variables for clarity
```

---

## Search Commands

Find potential single-use variables:

```bash
# All variable assignments
grep -rE "^\s+(\w+)\s*=\s*[^=]" lib/apiwork/

# Specific patterns
grep -rE "type_name\s*=" lib/apiwork/
grep -rE "schema_name\s*=" lib/apiwork/
grep -rE "_literal\s*=" lib/apiwork/
grep -rE "properties\s*=" lib/apiwork/
```

---

## Verification

After changes:

```bash
bundle exec rspec
bundle exec rubocop -A
```
