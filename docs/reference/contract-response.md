---
order: 29
prev: false
next: false
---

# Contract::Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response.rb#L10)

Defines body for a response.

Returns [Contract::Object](contract-object) via `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response.rb#L73)

Defines the response body for this response.

When using representation, body is auto-generated from representation attributes.

**Returns**

[Contract::Object](contract-object)

**See also**

- [Contract::Object](contract-object)

**Example: instance_eval style**

```ruby
body do
  integer :id
  string :title
  decimal :amount
end
```

**Example: yield style**

```ruby
body do |body|
  body.integer :id
  body.string :title
  body.decimal :amount
end
```

---

### #no_content!

`#no_content!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response.rb#L46)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response.rb#L27)

Returns true if this response is 204 No Content.

**Returns**

`Boolean`

---
