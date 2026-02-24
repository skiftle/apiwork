---
order: 55
prev: false
next: false
---

# Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L19)

Wraps action definitions within a resource.

**Example**

```ruby
resource.actions[:show].method # => :get
resource.actions[:show].path # => "/posts/:id"
resource.actions[:create].request # => Action::Request

resource.actions.each_value do |action|
  action.method # => :get, :post, :patch, :delete
  action.request # => Action::Request
  action.response # => Action::Response
  action.deprecated? # => false
end
```

## Modules

- [Request](./request)
- [Response](./response)

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L100)

Whether this action is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L76)

The description for this action.

**Returns**

`String`, `nil`

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L36)

The method for this action.

**Returns**

`Symbol`

---

### #operation_id

`#operation_id`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L92)

The operation ID for this action.

**Returns**

`String`, `nil`

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L28)

The path for this action.

**Returns**

`String`

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L60)

The raises for this action.

**Returns**

`Array<Symbol>`

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L44)

The request for this action.

**Returns**

[Action::Request](/reference/contract/action/request)

---

### #response

`#response`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L52)

The response for this action.

**Returns**

[Action::Response](/reference/contract/action/response)

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L68)

The summary for this action.

**Returns**

`String`, `nil`

---

### #tags

`#tags`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L84)

The tags for this action.

**Returns**

`Array<String>`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L108)

Converts this action to a hash.

**Returns**

`Hash`

---
