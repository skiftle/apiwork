---
order: 33
prev: false
next: false
---

# Introspection::API::Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L21)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L47)

**Returns**

Hash{Symbol =&gt; [Introspection::Action](introspection-action)} — actions defined on this resource

**See also**

- [Introspection::Action](introspection-action)

---

### #identifier

`#identifier`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L28)

**Returns**

`String` — resource identifier

---

### #parent_identifiers

`#parent_identifiers`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L40)

**Returns**

`Array<String>` — parent resource identifiers

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L34)

**Returns**

`String` — URL path segment

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L53)

**Returns**

Hash{Symbol =&gt; [Resource](introspection-api-resource)} — nested resources

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L59)

**Returns**

`Hash` — structured representation

---
