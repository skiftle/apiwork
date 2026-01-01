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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L84)

**Returns**

`Boolean` — whether this action is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L66)

**Returns**

`String`, `nil` — full description

---

### #http_method

`#http_method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L34)

**Returns**

`Symbol` — HTTP method (:get, :post, :patch, :delete, :put)

---

### #operation_id

`#operation_id`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L78)

**Returns**

`String`, `nil` — OpenAPI operation ID

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L28)

**Returns**

`String` — action path segment (e.g., "/:id", "/")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L54)

**Returns**

`Array<Symbol>` — error codes this action may raise

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L41)

**Returns**

[Request](request), `nil` — request definition

**See also**

- [Request](request)

---

### #request?

`#request?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L90)

**Returns**

`Boolean` — whether a request is defined

---

### #response

`#response`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L48)

**Returns**

[Response](response), `nil` — response definition

**See also**

- [Response](response)

---

### #response?

`#response?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L96)

**Returns**

`Boolean` — whether a response is defined

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L60)

**Returns**

`String`, `nil` — short summary

---

### #tags

`#tags`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L72)

**Returns**

`Array<String>` — OpenAPI tags

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/action.rb#L102)

**Returns**

`Hash` — the raw underlying data hash

---
