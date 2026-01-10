---
order: 32
prev: false
next: false
---

# Introspection::Action

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

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L82)

**Returns**

`Boolean` — whether this action is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L64)

**Returns**

`String`, `nil` — full description

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L32)

**Returns**

`Symbol` — HTTP method (:get, :post, :patch, :delete, :put)

---

### #operation_id

`#operation_id`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L76)

**Returns**

`String`, `nil` — OpenAPI operation ID

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L26)

**Returns**

`String` — full action path (e.g., "/posts/:id", "/posts")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L52)

**Returns**

`Array<Symbol>` — error codes this action may raise

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L39)

**Returns**

[Action::Request](introspection-action-request) — request definition

**See also**

- [Action::Request](introspection-action-request)

---

### #response

`#response`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L46)

**Returns**

[Action::Response](introspection-action-response) — response definition

**See also**

- [Action::Response](introspection-action-response)

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L58)

**Returns**

`String`, `nil` — short summary

---

### #tags

`#tags`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L70)

**Returns**

`Array<String>` — OpenAPI tags

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L88)

**Returns**

`Hash` — structured representation

---
