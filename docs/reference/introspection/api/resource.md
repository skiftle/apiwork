---
order: 55
prev: false
next: false
---

# Resource

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L55)

The actions for this resource.

**Returns**

Hash{Symbol =&gt; [Introspection::Action](/reference/introspection/action/)}

**See also**

- [Introspection::Action](/reference/introspection/action/)

---

### #identifier

`#identifier`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L30)

The identifier for this resource.

**Returns**

`String`

---

### #parent_identifiers

`#parent_identifiers`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L46)

The parent identifiers for this resource.

**Returns**

`Array<String>`

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L38)

The path for this resource.

**Returns**

`String`

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L63)

The nested resources for this resource.

**Returns**

Hash{Symbol =&gt; [Resource](/reference/api/resource)}

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L71)

Converts this resource to a hash.

**Returns**

`Hash`

---
