---
order: 22
prev: false
next: false
---

# Contract::Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response.rb#L10)

Defines body for a response.

Returns [Object](object) via `body`.

## Instance Methods

### #body

`#body(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/response.rb#L64)

Defines the response body for this response.

When using schema!, body is auto-generated from schema attributes.

**Returns**

[Contract::Object](contract-object)

**See also**

- [Contract::Object](contract-object)

**Example**

```ruby
body do
  integer :id
  string :title
  decimal :amount
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
