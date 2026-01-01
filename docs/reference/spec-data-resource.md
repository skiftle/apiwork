---
order: 33
prev: false
next: false
---

# Spec::Data::Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L25)

Wraps resource definitions.

**Example**

```ruby
data.resources.each do |resource|
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L48)

**Returns**

`Array<Action>` — actions defined on this resource

**See also**

- [Action](action)

---

### #each_action

`#each_action(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L86)

Iterates over all actions.

**See also**

- [Action](action)

---

### #identifier

`#identifier`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L35)

**Returns**

`String` — resource identifier

---

### #nested?

`#nested?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L65)

**Returns**

`Boolean` — whether this resource has nested resources

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L41)

**Returns**

`String` — URL path segment

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L57)

**Returns**

`Array<Resource>` — nested resources

**See also**

- [Resource](resource)

---

### #schema

`#schema`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L71)

**Returns**

`Hash`, `nil` — schema definition if this resource has a schema

---

### #schema?

`#schema?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L77)

**Returns**

`Boolean` — whether this resource has a schema

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L92)

**Returns**

`Hash` — the raw underlying data hash

---
