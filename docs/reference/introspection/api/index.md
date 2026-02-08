---
order: 49
prev: false
next: false
---

# API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L23)

Facade for introspected API data.

Entry point for accessing all API data. Access resources via [#resources](#resources),
types via [#types](#types), enums via [#enums](#enums).

**Example**

```ruby
api = Apiwork::API.introspect('/api/v1', locale: :fr)

api.info.title                      # => "Mon API"
api.types[:address].description     # => "Type d'adresse"
api.enums[:status].values           # => ["draft", "published"]

api.resources.each_value do |resource|
  resource.actions.each_value do |action|
    # ...
  end
end
```

## Modules

- [Info](./info/)
- [Resource](./resource)

## Instance Methods

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L54)

**Returns**

Hash{Symbol =&gt; [Enum](/reference/introspection/enum)}

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L60)

**Returns**

Hash{Symbol =&gt; [ErrorCode](/reference/introspection/error-code)}

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L36)

**Returns**

[API::Info](/reference/api/info/), `nil`

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L30)

**Returns**

`String`, `nil`

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L42)

**Returns**

Hash{Symbol =&gt; [API::Resource](/reference/api/resource)}

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L68)

Converts this API to a hash.

**Returns**

`Hash`

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L48)

**Returns**

Hash{Symbol =&gt; [Type](/reference/introspection/type)}

---
