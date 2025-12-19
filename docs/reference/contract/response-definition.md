---
order: 65
prev: false
next: false
---

# ResponseDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L5)

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L6)

Returns the value of attribute action_name.

---

### #body(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L55)

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

### #body_definition()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L6)

Returns the value of attribute body_definition.

---

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L6)

Returns the value of attribute contract_class.

---

### #initialize(contract_class, action_name)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L10)

**Returns**

`ResponseDefinition` — a new instance of ResponseDefinition

---

### #no_content!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L35)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response_definition.rb#L17)

**Returns**

`Boolean` — 

---
