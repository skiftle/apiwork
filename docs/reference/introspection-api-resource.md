---
order: 25
prev: false
next: false
---

# Introspection::API::Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L25)

Wraps resource definitions.

**Example**

```ruby
api.resources[:invoices].path              # => "invoices"
api.resources[:invoices].parent_identifiers # => []
api.resources[:invoices].resources         # => {} or nested resources

api.each_resource do |resource|
  resource.identifier         # => "invoices"
  resource.parent_identifiers # => [] or ["posts"] for nested

  resource.actions.each_value do |action|
    action.request  # => Action::Request or nil
    action.response # => Action::Response or nil
  end
end
```

## Instance Methods

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L45)

**Returns**

`Hash{Symbol => Action}` — actions defined on this resource

**See also**

- [Action](introspection-action)

---

### #each_action

`#each_action(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L66)

Iterates over all actions.

**See also**

- [Action](introspection-action)

---

### #identifier

`#identifier`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L32)

**Returns**

[String](introspection-string) — resource identifier

---

### #parent_identifiers

`#parent_identifiers`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L44)

**Returns**

`Array<String>` — parent resource identifiers

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L38)

**Returns**

[String](introspection-string) — URL path segment

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L51)

**Returns**

`Hash{Symbol => Resource}` — nested resources

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L72)

**Returns**

`Hash` — structured representation

---
