---
order: 10
prev: false
next: false
---

# Adapter::Capabilities

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L27)

API capabilities for conditional type registration.

Passed to `register_api` in your adapter. Query to determine
what types to register based on API structure and schema definitions.

**Example: Conditional type registration**

```ruby
def register_api(registrar, capabilities)
  if capabilities.offset_pagination?
    registrar.type :offset_pagination do
      param :page, type: :integer
      param :per_page, type: :integer
    end
  end

  if capabilities.sortable?
    registrar.type :sort_param do
      param :field, type: :string
      param :direction, type: :string
    end
  end
end
```

## Instance Methods

### #cursor_pagination?

`#cursor_pagination?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L84)

**Returns**

`Boolean` — true if any schema uses cursor pagination

---

### #filter_types

`#filter_types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L30)

**Returns**

`Array<Symbol>` — data types used in filterable attributes

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L54)

**Returns**

`Boolean` — true if any schema has filterable attributes

---

### #index_actions?

`#index_actions?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L72)

**Returns**

`Boolean` — true if any resource has an index action

---

### #nullable_filter_types

`#nullable_filter_types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L34)

**Returns**

`Array<Symbol>` — data types used in nullable filterable attributes

---

### #offset_pagination?

`#offset_pagination?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L78)

**Returns**

`Boolean` — true if any schema uses offset pagination

---

### #pagination?

`#pagination?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L60)

**Returns**

`Boolean` — true if any pagination strategy is used

---

### #resources?

`#resources?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L66)

**Returns**

`Boolean` — true if the API has any resources registered

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L48)

**Returns**

`Boolean` — true if any schema has sortable attributes or associations

---
