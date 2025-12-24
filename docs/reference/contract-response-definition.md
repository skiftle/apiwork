---
order: 13
prev: false
next: false
---

# Contract::ResponseDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L11)

Defines body for a response.

Part of the Adapter DSL. Returned by [ActionDefinition#response](contract-action-definition#response).
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L21)

**Returns**

`Symbol` — the action name

---

### #body(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L75)

Defines the response body for this response.

Use `param` inside the block to define fields.
When using schema!, body is auto-generated from schema attributes.

**Returns**

[Definition](contract-definition) — the body definition

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

### #body_definition()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L21)

**Returns**

[Definition](contract-definition), `nil` — the body definition

---

### #no_content!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L54)

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

### #no_content?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L35)

Returns true if this response is 204 No Content.

**Returns**

`Boolean` — 

---
