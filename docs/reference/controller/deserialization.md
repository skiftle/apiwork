---
order: 4
prev: false
next: false
---

# Deserialization

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/deserialization.rb#L6)

## Instance Methods

### #contract()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/controller/deserialization.rb#L60)

Returns the parsed and validated request contract.

The contract contains parsed query parameters and request body,
with type coercion applied. Access parameters via `contract.query`
and `contract.body`.

**Returns**

`Apiwork::Contract::Base` — the contract instance

**Example: Access parsed parameters**

```ruby
def create
  invoice = Invoice.new(contract.body)
  # contract.body contains validated, coerced params
end
```

**Example: Check for specific parameters**

```ruby
def index
  if contract.query[:include]
    # handle include parameter
  end
end
```

---
