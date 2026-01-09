---
order: 13
prev: false
next: false
---

# Adapter::Capabilities

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L30)

API capabilities for conditional type registration.

Passed to `register_api` in your adapter. Query to determine
what types to register based on API structure and schema definitions.

**Example: Conditional type registration**

```ruby
def register_api(registrar, capabilities)
  if capabilities.sortable?
    registrar.type :sort_param do
      param :field, type: :string
      param :direction, type: :string
    end
  end
end
```

**Example: Query adapter option values**

```ruby
def register_api(registrar, capabilities)
  strategies = capabilities.options_for(:pagination, :strategy)
  if strategies.include?(:offset)
    registrar.type :offset_pagination do
      param :page, type: :integer
    end
  end
end
```

## Instance Methods

### #filter_types

`#filter_types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L33)

**Returns**

`Array<Symbol>` — data types used in filterable attributes

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L56)

**Returns**

`Boolean` — true if any schema has filterable attributes

---

### #index_actions?

`#index_actions?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L68)

**Returns**

`Boolean` — true if any resource has an index action

---

### #nullable_filter_types

`#nullable_filter_types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L37)

**Returns**

`Array<Symbol>` — data types used in nullable filterable attributes

---

### #options_for

`#options_for(option, key = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L77)

Returns all unique values for an adapter option across schemas.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `option` | `Symbol` | the option name |
| `key` | `Symbol, nil` | optional nested key |

**Returns**

`Set<Object>` — unique option values

---

### #resources?

`#resources?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L62)

**Returns**

`Boolean` — true if the API has any resources registered

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capabilities.rb#L50)

**Returns**

`Boolean` — true if any schema has sortable attributes or associations

---
