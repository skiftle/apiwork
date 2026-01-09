---
order: 20
prev: false
next: false
---

# Contract::Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L9)

Defines query params and body for a request.

Returns [Object](contract-object) via `query` and `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L68)

Defines the request body for this request.

Body is parsed from the JSON request body.
Use `param` inside the block to define fields.

**Returns**

[Object](contract-object) — the body param

**See also**

- [Contract::Object](contract-object)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L40)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.
Use `param` inside the block to define parameters.

**Returns**

[Object](contract-object) — the query param

**See also**

- [Contract::Object](contract-object)

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
