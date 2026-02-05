---
order: 34
prev: false
next: false
---

# Contract::Action::Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/request.rb#L10)

Defines query params and body for a request.

Returns [Contract::Object](contract-object) via `query` and `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/request.rb#L71)

Defines the request body for this request.

Body is parsed from the JSON request body.

**Returns**

[Contract::Object](contract-object)

**See also**

- [Contract::Object](contract-object)

**Example: instance_eval style**

```ruby
body do
  string :title
  decimal :amount
end
```

**Example: yield style**

```ruby
body do |body|
  body.string :title
  body.decimal :amount
end
```

---

### #query

`#query(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/request.rb#L42)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.

**Returns**

[Contract::Object](contract-object)

**See also**

- [Contract::Object](contract-object)

**Example: instance_eval style**

```ruby
query do
  integer? :page
  string? :status, enum: :status
end
```

**Example: yield style**

```ruby
query do |query|
  query.integer? :page
  query.string? :status, enum: :status
end
```

---
