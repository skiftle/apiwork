---
order: 16
prev: false
next: false
---

# Contract::Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L10)

Defines query params and body for a request.

Returns [Param](contract-param) via `query` and `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L69)

Defines the request body for this request.

Body is parsed from the JSON request body.
Use `param` inside the block to define fields.

**Returns**

[Param](contract-param) — the body param

**See also**

- [Contract::Param](contract-param)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L41)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.
Use `param` inside the block to define parameters.

**Returns**

[Param](contract-param) — the query param

**See also**

- [Contract::Param](contract-param)

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
