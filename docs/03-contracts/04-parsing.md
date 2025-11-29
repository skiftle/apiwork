# Parsing

When a request is received, Apiwork parses and validates the input.

## Coercion

String values are automatically coerced to the declared type:

| Type | Input | Result |
|------|-------|--------|
| `:integer` | `"123"` | `123` |
| `:float` | `"12.5"` | `12.5` |
| `:boolean` | `"true"` | `true` |
| `:boolean` | `"false"` | `false` |
| `:date` | `"2024-01-15"` | `Date` object |
| `:datetime` | `"2024-01-15T10:30:00Z"` | `DateTime` object |

## Validation

After coercion, values are validated:

- Type checking
- Required field presence
- Enum membership
- Min/max constraints

## Issues

Validation failures produce issues:

```ruby
contract = PostContract.new(query: {}, body: {}, action: :create)

contract.valid?   # false
contract.issues   # Array of Issue objects
```

Each issue has:

```ruby
issue.code    # :field_missing, :invalid_type, etc.
issue.path    # [:post, :title]
issue.message # Human-readable message
```

## Issue Codes

| Code | Meaning |
|------|---------|
| `:field_missing` | Required field not provided |
| `:invalid_type` | Value cannot be coerced to type |
| `:invalid_value` | Value fails validation (enum, min, max) |
| `:field_unknown` | Unknown field in strict mode |
| `:value_null` | Null value when not nullable |
| `:string_too_short` | String shorter than min |
| `:string_too_long` | String longer than max |
| `:array_too_small` | Array has fewer than min items |
| `:array_too_large` | Array has more than max items |

See [Errors](../06-errors/01-introduction.md) for error handling.
