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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L50)

**Returns**

`Array<Action>` — actions defined on this resource

**See also**

- [Action](spec-data-action)

---

### #each_action

`#each_action(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L88)

Iterates over all actions.

**See also**

- [Action](spec-data-action)

---

### #identifier

`#identifier`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L37)

**Returns**

`String` — resource identifier

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L28)

**Returns**

`Symbol` — resource name

---

### #nested?

`#nested?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L67)

**Returns**

`Boolean` — whether this resource has nested resources

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L43)

**Returns**

`String` — URL path segment

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L59)

**Returns**

`Array<Resource>` — nested resources

**See also**

- [Resource](spec-data-resource)

---

### #schema

`#schema`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L73)

**Returns**

`Hash`, `nil` — schema definition if this resource has a schema

---

### #schema?

`#schema?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L79)

**Returns**

`Boolean` — whether this resource has a schema

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/resource.rb#L94)

**Returns**

`Hash` — the raw underlying data hash

---
