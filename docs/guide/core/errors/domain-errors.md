---
order: 4
---

# Domain Errors

Domain errors occur when a structurally valid request violates a business rule.

The client cannot avoid domain errors by changing the request shape — only by changing the data itself.

::: info
Layer describes **what kind of rule was broken** — not where the code lives.

A validation in a Rails model is still a _domain rule_. "Invoice numbers must be unique" is domain logic — regardless of where it's enforced.
:::

## HTTP Status

**422 Unprocessable Entity** — The request was valid, but business rules failed.

## What Triggers Domain Errors

Domain errors are raised when business logic rejects valid input. How this happens depends on your adapter:

- The **standard adapter** maps ActiveRecord validation errors automatically
- Custom adapters can define their own mapping

The adapter determines which error codes to use, how to construct paths, and what metadata to include.

## Raising Domain Errors

How domain errors are raised depends on your adapter. The standard adapter uses ActiveRecord's error system:

```ruby
def transfer
  if amount > account.balance
    account.errors.add(:balance, :insufficient_funds)
  end
  expose account  # Adapter converts errors to domain errors
end
```

See your adapter's documentation for details on how it handles domain validation.

#### See also

- [Standard Adapter: Validation](../adapters/standard-adapter/validation.md) — Rails validation mapping, error codes, nested records
- [Issue reference](../../../reference/apiwork/issue.md) — issue object structure
