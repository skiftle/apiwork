---
order: 38
prev: false
next: false
---

# Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/response.rb#L10)

Defines body for a response.

Returns [Contract::Object](/reference/contract/object) via `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/response.rb#L74)

Defines the response body for this response.

**Returns**

[Contract::Object](/reference/contract/object)

**See also**

- [Contract::Object](/reference/contract/object)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/response.rb#L49)

Declares this response as 204 No Content.

Use for actions that don't return a response body,
like DELETE or actions that only perform side effects.

**Returns**

`void`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action/response.rb#L28)

Whether this response has no content.

**Returns**

`Boolean`

---
