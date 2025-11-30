---
order: 2
---

# Error Classes

## ConstraintError

Base class for constraint violations. HTTP status: 400 Bad Request.

```ruby
raise Apiwork::ConstraintError.new([
  Apiwork::Issue.new(code: :custom_error, detail: 'Something went wrong', path: [])
])
```

## ValidationError

For validation failures. HTTP status: 422 Unprocessable Entity.

```ruby
raise Apiwork::ValidationError.new([
  Apiwork::Issue.new(code: :field_missing, detail: 'Field required', path: [:title])
])
```

## ContractError

For contract-specific violations. Inherits from `ConstraintError`.

## ConfigurationError

For API configuration errors during setup:

```ruby
raise Apiwork::ConfigurationError.new(
  code: :model_not_found,
  detail: "Could not find model 'Post' for Api::V1::PostSchema",
  path: []
)
```

## SchemaError

For schema configuration errors.

## AdapterError

For adapter-related errors.

## Accessing Issues

All constraint errors have an `issues` array:

```ruby
begin
  # operation that may fail
rescue Apiwork::ConstraintError => e
  e.issues.each do |issue|
    puts "#{issue.code}: #{issue.detail}"
  end
end
```

## HTTP Status

Each error class defines its HTTP status:

```ruby
Apiwork::ConstraintError.new([]).http_status    # :bad_request (400)
Apiwork::ValidationError.new([]).http_status    # :unprocessable_entity (422)
```
