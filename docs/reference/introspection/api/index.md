---
order: 47
prev: false
next: false
---

# API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L23)

Facade for introspected API data.

Entry point for accessing all API data. Access resources via [#resources](/reference/#resources),
types via [#types](/reference/#types), enums via [#enums](/reference/#enums).

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L58)

**Returns**

Hash{Symbol =&gt; [Enum](/reference/introspection/enum)} — registered enums

**See also**

- [Enum](/reference/introspection/enum)

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L65)

**Returns**

Hash{Symbol =&gt; [ErrorCode](/reference/introspection/error-code)} — error code definitions

**See also**

- [ErrorCode](/reference/introspection/error-code)

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L37)

**Returns**

[API::Info](/reference/api/info/), `nil` — API metadata, or nil if not defined

**See also**

- [API::Info](/reference/api/info/)

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L30)

**Returns**

`String`, `nil` — API mount path (e.g., "/api/v1")

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L44)

**Returns**

Hash{Symbol =&gt; [API::Resource](/reference/api/resource)} — top-level resources

**See also**

- [API::Resource](/reference/api/resource)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L71)

**Returns**

`Hash` — structured representation

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L51)

**Returns**

Hash{Symbol =&gt; [Type](/reference/introspection/type)} — registered custom types

**See also**

- [Type](/reference/introspection/type)

---
