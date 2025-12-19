---
order: 33
prev: false
next: false
---

# RequestDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L5)

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L6)

Returns the value of attribute action_name.

---

### #body(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L61)

Defines the request body for this request.

Body is parsed from the JSON request body.
Use `param` inside the block to define fields.

**Returns**

`Definition` — the body definition

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

### #body_definition()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L6)

Returns the value of attribute body_definition.

---

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L6)

Returns the value of attribute contract_class.

---

### #query(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L34)

Defines query parameters for this request.

Query parameters are parsed from the URL query string.
Use `param` inside the block to define parameters.

**Returns**

`Definition` — the query definition

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

### #query_definition()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L6)

Returns the value of attribute query_definition.

---
