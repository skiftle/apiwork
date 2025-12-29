---
order: 12
prev: false
next: false
---

# Contract::RequestDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L11)

Defines query params and body for a request.

Returns [ParamDefinition](contract-param-definition) via `query` and `body`.
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L68)

Defines the request body for this request.

Body is parsed from the JSON request body.
Use `param` inside the block to define fields.

**Returns**

[ParamDefinition](contract-param-definition) — the body param definition

**Example**

```ruby
request do
  body do
    param :title, type: :string
    param :amount, type: :decimal, min: 0
  end
end
```

---

### #query

`#query(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L41)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.
Use `param` inside the block to define parameters.

**Returns**

[ParamDefinition](contract-param-definition) — the query param definition

**Example**

```ruby
request do
  query do
    param :page, type: :integer, optional: true, default: 1
    param :per_page, type: :integer, optional: true, default: 25
    param :filter, type: :string, optional: true
  end
end
```

---
