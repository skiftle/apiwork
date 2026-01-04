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
resource = api.resources[:invoices]

resource.identifier         # => "invoices"
resource.path               # => "invoices"
resource.parent_identifiers # => []
resource.resources          # => {} or nested resources

resource.actions.each_value do |action|
  action.request  # => Action::Request
  action.response # => Action::Response
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
