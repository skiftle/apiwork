---
order: 5
---

# Custom Errors

Beyond contract and model validation, you can create custom errors for business logic, authorization, and domain-specific rules.

## Creating Errors

Build errors directly when you need custom error handling:

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

Use `render_error` to return custom errors:

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

    return render_error issues, layer: :domain, status: :conflict
  end

  order.save!
  respond order
end
```

## Authorization Errors

For common HTTP errors like forbidden or not found, use `respond_with_error`:

```ruby
def destroy
  post = Post.find(params[:id])

  unless current_user.can_delete?(post)
    return respond_with_error :forbidden,
      detail: "You don't have permission to delete this post",
      meta: { user_id: current_user.id, post_id: post.id }
  end

  post.destroy
  respond post
end
```

[HTTP Issues](./http-issues.md) lists all built-in codes and how to register custom ones.

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

  return render_error issues, layer: :domain, status: :unprocessable_entity if issues.any?

  Transfer.execute(from: from_account, to: to_account, amount: amount)
  respond from_account
end
```

## HTTP Status Codes

Choose the appropriate status for your error type:

| Status                     | When to Use                                      |
| -------------------------- | ------------------------------------------------ |
| `400 Bad Request`          | Malformed request (rare for custom errors)       |
| `401 Unauthorized`         | Authentication required                          |
| `403 Forbidden`            | Authenticated but not authorized                 |
| `404 Not Found`            | Resource doesn't exist                           |
| `409 Conflict`             | State conflict (out of stock, already processed) |
| `422 Unprocessable Entity` | Business rule violation                          |
| `429 Too Many Requests`    | Rate limiting                                    |

## Registering Custom Codes

For domain-specific errors that you use frequently, register them as error codes:

```ruby
# config/initializers/error_codes.rb
Apiwork::ErrorCode.register :insufficient_funds, status: 402
Apiwork::ErrorCode.register :account_frozen, status: 403
Apiwork::ErrorCode.register :out_of_stock, status: 409
```

Then use them with `respond_with_error`:

```ruby
respond_with_error :insufficient_funds,
  meta: { requested: amount, available: from_account.balance }
```

This gives you i18n support and consistent HTTP status codes. [HTTP Issues](./http-issues.md) shows all built-in codes and how to register your own.
