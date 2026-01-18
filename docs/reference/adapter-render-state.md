---
order: 15
prev: false
next: false
---

# Adapter::RenderState

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/render_state.rb#L26)

Runtime state passed to adapter render methods.

Contains the action and optional context.
Access action predicates via `state.action.index?`.

**Example: Check action type**

```ruby
def render_record(record, schema_class, state)
  if state.action.show?
    { data: serialize(record) }
  else
    { data: serialize(record), links: { self: url_for(record) } }
  end
end
```

**Example: Check HTTP method**

```ruby
def render_collection(collection, schema_class, state)
  response = { data: collection.map { |record| serialize(record) } }
  response[:cache] = true if state.action.get?
  response
end
```

## Instance Methods

### #action

`#action`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/render_state.rb#L29)

**Returns**

[Adapter::Action](adapter-action) — the current action

---

### #context

`#context`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/render_state.rb#L33)

**Returns**

`Hash` — arbitrary context passed from the controller

---

### #meta

`#meta`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/render_state.rb#L37)

**Returns**

`Hash` — metadata for the response

---

### #request

`#request`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/render_state.rb#L41)

**Returns**

[Adapter::Request](adapter-request), `nil` — the parsed request

---
