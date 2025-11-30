---
order: 6
---

# Abstract Contracts

Abstract contracts serve as base classes for other contracts.

## Marking as Abstract

```ruby
class BaseContract < Apiwork::Contract::Base
  abstract
end
```

## Usage Pattern

Create a base contract with shared configuration:

```ruby
class BaseContract < Apiwork::Contract::Base
  abstract

  # Shared types
  type :pagination do
    param :page, type: :integer
    param :per_page, type: :integer
  end
end
```

Concrete contracts inherit from it:

```ruby
class PostContract < BaseContract
  schema!

  action :index do
    request do
      query do
        param :pagination, type: :pagination
      end
    end
  end
end
```

## Inheritance Behavior

The `abstract` flag is not inherited:

```ruby
BaseContract.abstract?  # true
PostContract.abstract?  # false
```

Subclasses can be marked abstract again:

```ruby
class AdminBaseContract < BaseContract
  abstract
end
```
