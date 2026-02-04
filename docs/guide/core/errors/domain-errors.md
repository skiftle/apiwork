---
order: 4
---

# Domain Errors

Domain errors occur when a structurally valid request violates a business rule.

## HTTP Status

**422 Unprocessable Entity** — The request was valid, but business rules failed.

## What Triggers Domain Errors

Domain errors are raised when business logic rejects valid input. How this happens depends on your adapter.

#### See also

- [Standard Adapter: Validation](../adapters/standard-adapter/validation.md)
- [Issue reference](../../../reference/issue.md)
