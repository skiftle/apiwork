---
order: 22
prev: false
next: false
---

# Contract::Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L9)

Defines query params and body for a request.

Returns [Object](object) via `query` and `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L59)

Defines the request body for this request.

Body is parsed from the JSON request body.

**Returns**

[Contract::Object](contract-object)

**See also**

- [Contract::Object](contract-object)

**Example**

```ruby
body do
  string :title
  decimal :amount
end
```

---

### #query

`#query(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request.rb#L35)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.

**Returns**

[Contract::Object](contract-object)

**See also**

- [Contract::Object](contract-object)

**Example**

```ruby
query do
  integer :page, optional: true
  string :status, enum: :status, optional: true
end
```

---
