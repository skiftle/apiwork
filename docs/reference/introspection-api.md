---
order: 20
prev: false
next: false
---

# Introspection::API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L23)

Facade for introspected API data.

Entry point for accessing all API data. Access resources via [#resources](#resources),
types via [#types](#types), enums via [#enums](#enums).

**Example**

```ruby
api = MyAPI.introspect(locale: :sv)

api.info.title              # => "My API"
api.types.each { |t| ... }  # iterate custom types
api.enums.each { |e| ... }  # iterate enums

api.each_resource do |resource, parent_path|
  resource.actions.each do |action|
    # ...
  end
end
```

## Instance Methods

### #each_resource

`#each_resource(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L89)

Iterates over all resources recursively (including nested).

**See also**

- [API::Resource](api-resource)

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L62)

**Returns**

`Array<Enum>` — registered enums

**See also**

- [Enum](introspection-enum)

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L77)

**Returns**

`Array<ErrorCode>` — error code definitions

**See also**

- [ErrorCode](introspection-error-code)

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L37)

**Returns**

`API::Info` — API metadata

**See also**

- [API::Info](api-info)

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L30)

**Returns**

`String`, `nil` — API mount path (e.g., "/api/v1")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L70)

**Returns**

`Array<Symbol>` — API-level error codes that may be raised

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L44)

**Returns**

`Array<API::Resource>` — top-level resources

**See also**

- [API::Resource](api-resource)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L95)

**Returns**

`Hash` — structured representation

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L53)

**Returns**

`Array<Type>` — registered custom types

**See also**

- [Type](introspection-type)

---
