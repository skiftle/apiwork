---
order: 25
prev: false
next: false
---

# Introspection::API::Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L24)

Wraps resource definitions.

**Example**

```ruby
api.resources.each do |resource|
  resource.name       # => :invoices
  resource.identifier # => "invoices"
  resource.path       # => "invoices"
  resource.nested?    # => true if has nested resources

  resource.actions.each do |action|
    # ...
  end

  resource.resources.each do |nested|
    # ...
  end
end
```

## Instance Methods

### #actions

`#actions`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L49)

**Returns**

`Array<Action>` — actions defined on this resource

**See also**

- [Action](introspection-action)

---

### #each_action

`#each_action(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L74)

Iterates over all actions.

**See also**

- [Action](introspection-action)

---

### #identifier

`#identifier`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L36)

**Returns**

`String` — resource identifier

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L27)

**Returns**

`Symbol` — resource name

---

### #nested?

`#nested?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L65)

**Returns**

`Boolean` — whether this resource has nested resources

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L42)

**Returns**

`String` — URL path segment

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L57)

**Returns**

`Array<Resource>` — nested resources

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/resource.rb#L80)

**Returns**

`Hash` — structured representation

---
