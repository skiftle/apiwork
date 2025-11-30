---
order: 1
---

# Errors

Apiwork provides structured error handling.

## Error Types

```
Error (base class)
├── ConstraintError (400 Bad Request)
│   ├── ValidationError (422 Unprocessable Entity)
│   └── ContractError
├── ConfigurationError
├── SchemaError
└── AdapterError
```

## Issues

Errors contain `Issue` objects with:

- `code` - Machine-readable error code
- `detail` - Human-readable message
- `path` - Location in the data structure
- `pointer` - JSON Pointer format path

```ruby
issue = Apiwork::Issue.new(
  code: :field_missing,
  detail: 'Field required',
  path: [:post, :title]
)

issue.code     # :field_missing
issue.detail   # "Field required"
issue.path     # [:post, :title]
issue.pointer  # "/post/title"
```

## Contract Validation

When contract validation fails:

```ruby
contract = PostContract.new(query: {}, body: {}, action: :create)

contract.valid?   # false
contract.issues   # Array of Issue objects
contract.issues.first.code    # :field_missing
contract.issues.first.path    # [:post, :title]
```

## Error Response

Errors serialize to JSON:

```json
{
  "issues": [
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": ["post", "title"],
      "pointer": "/post/title"
    }
  ]
}
```
