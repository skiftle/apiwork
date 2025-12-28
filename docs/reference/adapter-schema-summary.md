---
order: 8
prev: false
next: false
---

# Adapter::SchemaSummary

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L27)

Aggregated schema information for type registration.

Passed to `register_api` in your adapter. Use to conditionally
register types based on what schemas define (filtering, sorting, pagination).

**Example: Conditional type registration**

```ruby
def register_api(registrar, schema_summary)
  if schema_summary.uses_offset_pagination?
    registrar.type :offset_pagination do
      param :page, type: :integer
      param :per_page, type: :integer
    end
  end

  if schema_summary.sortable?
    registrar.type :sort_param do
      param :field, type: :string
      param :direction, type: :string
    end
  end
end
```

## Instance Methods

### #filterable?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L54)

**Returns**

`Boolean` — true if any schema has filterable attributes

---

### #filterable_types()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L30)

**Returns**

`Array<Symbol>` — data types used in filterable attributes

---

### #has_index_actions?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L72)

**Returns**

`Boolean` — true if any resource has an index action

---

### #has_resources?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L66)

**Returns**

`Boolean` — true if the API has any resources registered

---

### #nullable_filterable_types()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L34)

**Returns**

`Array<Symbol>` — data types used in nullable filterable attributes

---

### #paginatable?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L60)

**Returns**

`Boolean` — true if any pagination strategy is used

---

### #sortable?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L48)

**Returns**

`Boolean` — true if any schema has sortable attributes or associations

---

### #uses_cursor_pagination?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L84)

**Returns**

`Boolean` — true if any schema uses cursor pagination

---

### #uses_offset_pagination?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/schema_summary.rb#L78)

**Returns**

`Boolean` — true if any schema uses offset pagination

---
