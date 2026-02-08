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
resource.actions[:show].method     # => :get
resource.actions[:show].path       # => "/posts/:id"
resource.actions[:create].request  # => Action::Request

resource.actions.each_value do |action|
  action.method      # => :get, :post, :patch, :delete
  action.request     # => Action::Request
  action.response    # => Action::Response
  action.deprecated? # => false
end
```

## Modules

- [Request](./request)
- [Response](./response)

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L80)

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L62)

**Returns**

`String`, `nil`

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L32)

**Returns**

`Symbol`

---

### #operation_id

`#operation_id`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L74)

**Returns**

`String`, `nil`

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L26)

**Returns**

`String`

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L50)

**Returns**

`Array<Symbol>`

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L38)

**Returns**

[Action::Request](/reference/contract/action/request)

---

### #response

`#response`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L44)

**Returns**

[Action::Response](/reference/contract/action/response)

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L56)

**Returns**

`String`, `nil`

---

### #tags

`#tags`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L68)

**Returns**

`Array<String>`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L88)

Converts this action to a hash.

**Returns**

`Hash`

---
