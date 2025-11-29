# Error Handling

## In Controllers

Apiwork automatically handles errors in controllers.

For custom handling:

```ruby
class ApplicationController < ActionController::API
  rescue_from Apiwork::ValidationError do |error|
    render json: { issues: error.issues.map(&:as_json) },
           status: error.http_status
  end

  rescue_from Apiwork::ConstraintError do |error|
    render json: { issues: error.issues.map(&:as_json) },
           status: error.http_status
  end
end
```

## Checking Contract Validity

```ruby
contract = PostContract.new(query: params, body: request.body, action: :create)

if contract.invalid?
  render json: { issues: contract.issues.map(&:as_json) },
         status: :unprocessable_entity
  return
end

# Proceed with valid data
contract.body
```

## Raising Errors

```ruby
def create
  issues = validate_custom_rules(params)

  if issues.any?
    raise Apiwork::ValidationError.new(issues)
  end

  # Proceed
end

def validate_custom_rules(params)
  issues = []

  if params[:start_date] > params[:end_date]
    issues << Apiwork::Issue.new(
      code: :invalid_date_range,
      detail: 'Start date must be before end date',
      path: [:start_date]
    )
  end

  issues
end
```

## Issue Serialization

Issues serialize to JSON:

```ruby
issue = Apiwork::Issue.new(
  code: :field_missing,
  detail: 'Field required',
  path: [:post, :title],
  meta: { field: :title }
)

issue.as_json
# {
#   code: :field_missing,
#   detail: "Field required",
#   path: ["post", "title"],
#   pointer: "/post/title",
#   meta: { field: :title }
# }
```
