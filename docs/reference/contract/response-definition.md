---
order: 36
prev: false
next: false
---

# ResponseDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L5)

## Instance Methods

### #body(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L57)

Defines the response body for this response.

Use `param` inside the block to define fields.
When using schema!, body is auto-generated from schema attributes.

**Returns**

`Definition` — the body definition

**Example**

```ruby
response do
  body do
    param :id, type: :integer
    param :title, type: :string
    param :created_at, type: :datetime
  end
end
```

---

### #no_content!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L37)

Declares this action returns 204 No Content.

Use for actions that don't return a response body,
like DELETE or actions that only perform side effects.

**Example**

```ruby
action :destroy do
  response { no_content! }
end
```

**Example: Archive action**

```ruby
action :archive do
  response { no_content! }
end
```

---
