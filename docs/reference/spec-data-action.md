---
order: 25
prev: false
next: false
---

# Spec::Data::Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L18)

Wraps action definitions within a resource.

**Example**

```ruby
resource.actions.each do |action|
  action.name        # => :index, :show, :create, etc.
  action.method      # => :get, :post, :patch, :delete
  action.path        # => "/" or "/:id"
  action.request     # => Request or nil
  action.response    # => Response or nil
  action.deprecated? # => false
end
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L86)

**Returns**

`Boolean` — whether this action is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L68)

**Returns**

`String`, `nil` — full description

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L36)

**Returns**

`Symbol` — HTTP method (:get, :post, :patch, :delete, :put)

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L21)

**Returns**

`Symbol` — action name

---

### #operation_id

`#operation_id`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L80)

**Returns**

`String`, `nil` — OpenAPI operation ID

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L30)

**Returns**

`String` — action path segment (e.g., "/:id", "/")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L56)

**Returns**

`Array<Symbol>` — error codes this action may raise

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L43)

**Returns**

[Request](spec-data-request), `nil` — request definition

**See also**

- [Request](spec-data-request)

---

### #request?

`#request?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L92)

**Returns**

`Boolean` — whether a request is defined

---

### #response

`#response`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L50)

**Returns**

[Response](spec-data-response), `nil` — response definition

**See also**

- [Response](spec-data-response)

---

### #response?

`#response?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L98)

**Returns**

`Boolean` — whether a response is defined

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L62)

**Returns**

`String`, `nil` — short summary

---

### #tags

`#tags`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L74)

**Returns**

`Array<String>` — OpenAPI tags

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L104)

**Returns**

`Hash` — structured representation

---
