---
order: 2
---

# Context

`context` passes controller data to representations during serialization. Override it to provide the current user, permissions, locale, or any runtime state that representations need.

## Usage

```ruby
class InvoicesController < ApplicationController
  include Apiwork::Controller

  def context
    { current_user: current_user }
  end

  def index
    expose Invoice.all
  end
end
```

The hash is available as `context` inside representation methods:

```ruby
class InvoiceRepresentation < ApplicationRepresentation
  attribute :id
  attribute :number
  attribute :editable, type: :boolean

  def editable
    context[:current_user].admin? || record.draft?
  end
end
```

## Default

The default `context` returns an empty hash:

```ruby
def context
  {}
end
```

Override it in any controller that needs to pass data to its representations.

## Scope

`context` is passed to every representation involved in a response — the primary representation and all nested associations. A single override covers the entire serialization tree.

```ruby
class InvoiceRepresentation < ApplicationRepresentation
  attribute :editable, type: :boolean
  has_many :lines

  def editable
    context[:current_user].admin?
  end
end

class LineRepresentation < ApplicationRepresentation
  attribute :adjustable, type: :boolean

  def adjustable
    context[:current_user].admin?
  end
end
```

Both representations receive the same `context` from the controller.

## Shared Context

Define `context` in the [base controller](./index.md#setup) when multiple controllers use the same data:

```ruby
class V1Controller < ApplicationController
  include Apiwork::Controller

  def context
    { current_user: current_user, locale: I18n.locale }
  end
end
```

All API controllers inherit the shared context. Override in a specific controller to add or change values.

#### See also

- [Controller reference](../../reference/controller.md) — `context` method details
- [Representations](../representations/) — how attributes and associations are serialized
- [Computed Attributes](../representations/attributes/custom.md) — using `context` in attribute methods
