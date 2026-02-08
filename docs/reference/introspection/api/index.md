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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L64)

The enums for this API.

**Returns**

Hash{Symbol =&gt; [Enum](/reference/introspection/enum)}

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L72)

The error codes for this API.

**Returns**

Hash{Symbol =&gt; [ErrorCode](/reference/introspection/error-code)}

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L40)

The info for this API.

**Returns**

[API::Info](/reference/api/info/), `nil`

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L32)

The mount path for this API.

**Returns**

`String`, `nil`

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L48)

The resources for this API.

**Returns**

Hash{Symbol =&gt; [API::Resource](/reference/api/resource)}

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L80)

Converts this API to a hash.

**Returns**

`Hash`

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L56)

The types for this API.

**Returns**

Hash{Symbol =&gt; [Type](/reference/introspection/type)}

---
