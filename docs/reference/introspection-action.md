---
order: 26
prev: false
next: false
---

# Introspection::Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L17)

Wraps action definitions within a resource.

**Example**

```ruby
resource.actions.each do |action|
  action.name        # => :index, :show, :create, etc.
  action.method      # => :get, :post, :patch, :delete
  action.path        # => "/" or "/:id"
  action.request     # => Action::Request or nil
  action.response    # => Action::Response or nil
  action.deprecated? # => false
end
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L85)

**Returns**

`Boolean` — whether this action is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L67)

**Returns**

`String`, `nil` — full description

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L35)

**Returns**

`Symbol` — HTTP method (:get, :post, :patch, :delete, :put)

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L20)

**Returns**

`Symbol` — action name

---

### #operation_id

`#operation_id`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L79)

**Returns**

`String`, `nil` — OpenAPI operation ID

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L29)

**Returns**

`String` — action path segment (e.g., "/:id", "/")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L55)

**Returns**

`Array<Symbol>` — error codes this action may raise

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L42)

**Returns**

`Action::Request`, `nil` — request definition

**See also**

- [Action::Request](action-request)

---

### #request?

`#request?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L91)

**Returns**

`Boolean` — whether a request is defined

---

### #response

`#response`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L49)

**Returns**

`Action::Response`, `nil` — response definition

**See also**

- [Action::Response](action-response)

---

### #response?

`#response?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L97)

**Returns**

`Boolean` — whether a response is defined

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L61)

**Returns**

`String`, `nil` — short summary

---

### #tags

`#tags`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L73)

**Returns**

`Array<String>` — OpenAPI tags

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/action.rb#L103)

**Returns**

`Hash` — structured representation

---
