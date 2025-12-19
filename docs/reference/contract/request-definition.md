---
order: 33
prev: false
next: false
---

# RequestDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L5)

## Instance Methods

### #body(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L62)

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

### #query(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/request_definition.rb#L35)

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
