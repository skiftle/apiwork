---
order: 38
prev: false
next: false
---

# Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/request.rb#L10)

Defines query and body for a request.

Returns [Contract::Object](/reference/contract/object) via `query` and `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/request.rb#L69)

Defines the request body for this request.

Body is parsed from the JSON request body.

**Returns**

[Contract::Object](/reference/contract/object)

**Yields** [Contract::Object](/reference/contract/object)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/request.rb#L41)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.

**Returns**

[Contract::Object](/reference/contract/object)

**Yields** [Contract::Object](/reference/contract/object)

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
