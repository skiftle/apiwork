---
order: 16
prev: false
next: false
---

# Contract::ResponseDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L11)

Defines body for a response.

Returns [ParamDefinition](contract-param-definition) via `body`.
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L70)

Defines the response body for this response.

Use `param` inside the block to define fields.
When using schema!, body is auto-generated from schema attributes.

**Returns**

[ParamDefinition](contract-param-definition) — the body param definition

**See also**

- [Contract::ParamDefinition](contract-param-definition)

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

### #no_content!

`#no_content!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L48)

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

### #no_content?

`#no_content?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L29)

Returns true if this response is 204 No Content.

**Returns**

`Boolean`

---
