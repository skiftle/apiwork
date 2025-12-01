---
order: 4
---

# Custom Errors

Beyond contract and model validation, you can create custom errors for business logic, authorization, and domain-specific rules.

## Creating Issues

Build issues directly when you need custom error handling:

```ruby
issue = Apiwork::Issue.new(
  code: :insufficient_balance,
  detail: "Account balance is too low for this transaction",
  path: [:transaction, :amount],
  meta: { required: 100.00, available: 45.50 }
)
```

The `code` should be a symbol that clients can use programmatically. The `detail` provides human-readable context.

## Rendering Errors

Use `render_error` to return custom issues:

```ruby
def create
  order = Order.new(contract.body[:order])

  unless inventory_available?(order)
    issues = order.items.filter_map.with_index do |item, index|
      next if item.in_stock?

      Apiwork::Issue.new(
        code: :out_of_stock,
        detail: "#{item.name} is out of stock",
        path: [:order, :items, index, :product_id],
        meta: { product_id: item.product_id, requested: item.quantity, available: 0 }
      )
    end

    return render_error issues, status: :conflict
  end

  order.save!
  respond_with order
end
```

## Authorization Errors

For permission checks:

```ruby
def destroy
  post = Post.find(params[:id])

  unless current_user.can_delete?(post)
    issue = Apiwork::Issue.new(
      code: :forbidden,
      detail: "You don't have permission to delete this post",
      path: [],
      meta: { user_id: current_user.id, post_id: post.id }
    )
    return render_error [issue], status: :forbidden
  end

  post.destroy
  respond_with post
end
```

## Domain Validation

For business rules that don't fit in model validations:

```ruby
def transfer
  from_account = Account.find(contract.body[:from_account_id])
  to_account = Account.find(contract.body[:to_account_id])
  amount = contract.body[:amount]

  issues = []

  if from_account.frozen?
    issues << Apiwork::Issue.new(
      code: :account_frozen,
      detail: "Source account is frozen",
      path: [:from_account_id],
      meta: { account_id: from_account.id }
    )
  end

  if to_account.closed?
    issues << Apiwork::Issue.new(
      code: :account_closed,
      detail: "Destination account is closed",
      path: [:to_account_id],
      meta: { account_id: to_account.id }
    )
  end

  if amount > from_account.balance
    issues << Apiwork::Issue.new(
      code: :insufficient_funds,
      detail: "Insufficient funds for transfer",
      path: [:amount],
      meta: { requested: amount, available: from_account.balance }
    )
  end

  return render_error issues, status: :unprocessable_entity if issues.any?

  Transfer.execute(from: from_account, to: to_account, amount: amount)
  respond_with from_account
end
```

## HTTP Status Codes

Choose the appropriate status for your error type:

| Status | When to Use |
|--------|-------------|
| `400 Bad Request` | Malformed request (rare for custom errors) |
| `401 Unauthorized` | Authentication required |
| `403 Forbidden` | Authenticated but not authorized |
| `404 Not Found` | Resource doesn't exist |
| `409 Conflict` | State conflict (out of stock, already processed) |
| `422 Unprocessable Entity` | Business rule violation |
| `429 Too Many Requests` | Rate limiting |

## Error Builders

For reusable error patterns, create helper methods:

```ruby
module ErrorHelpers
  def forbidden_error(message, meta = {})
    Apiwork::Issue.new(
      code: :forbidden,
      detail: message,
      path: [],
      meta: meta
    )
  end

  def not_found_error(resource, id)
    Apiwork::Issue.new(
      code: :not_found,
      detail: "#{resource.to_s.humanize} not found",
      path: [],
      meta: { resource: resource, id: id }
    )
  end

  def field_error(code, message, path, meta = {})
    Apiwork::Issue.new(
      code: code,
      detail: message,
      path: Array(path),
      meta: meta
    )
  end
end
```

Include in your controller:

```ruby
class ApplicationController < ActionController::API
  include Apiwork::Controller::Concern
  include ErrorHelpers

  def handle_not_found(resource, id)
    render_error [not_found_error(resource, id)], status: :not_found
  end
end
```

## Combining Error Sources

You can mix custom issues with validation issues:

```ruby
def create
  invoice = Invoice.new(contract.body[:invoice])
  issues = []

  # Business rule check
  if invoice.total > current_user.credit_limit
    issues << Apiwork::Issue.new(
      code: :credit_limit_exceeded,
      detail: "Invoice total exceeds your credit limit",
      path: [:invoice, :total],
      meta: { limit: current_user.credit_limit, total: invoice.total }
    )
  end

  # Model validation
  unless invoice.valid?
    adapter = Apiwork::Controller::ValidationAdapter.new(
      invoice,
      schema_class: InvoiceSchema
    )
    issues.concat(adapter.convert)
  end

  return render_error issues, status: :unprocessable_entity if issues.any?

  invoice.save!
  respond_with invoice
end
```

## Consistent Error Codes

Define standard error codes for your application:

```ruby
module ErrorCodes
  # Authentication
  INVALID_TOKEN = :invalid_token
  TOKEN_EXPIRED = :token_expired

  # Authorization
  FORBIDDEN = :forbidden
  OWNERSHIP_REQUIRED = :ownership_required

  # Business Rules
  INSUFFICIENT_FUNDS = :insufficient_funds
  CREDIT_LIMIT_EXCEEDED = :credit_limit_exceeded
  ACCOUNT_FROZEN = :account_frozen

  # Inventory
  OUT_OF_STOCK = :out_of_stock
  QUANTITY_EXCEEDS_AVAILABLE = :quantity_exceeds_available

  # State
  ALREADY_PROCESSED = :already_processed
  INVALID_STATE_TRANSITION = :invalid_state_transition
end
```

Using consistent codes helps clients handle errors programmatically:

```typescript
if (error.code === 'insufficient_funds') {
  showInsufficientFundsDialog(error.meta.available);
} else if (error.code === 'out_of_stock') {
  removeItemFromCart(error.meta.product_id);
}
```
