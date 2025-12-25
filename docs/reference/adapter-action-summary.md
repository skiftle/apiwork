---
order: 5
prev: false
next: false
---

# Adapter::ActionSummary

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L26)

Request context passed to adapter render methods.

Contains the action name, HTTP method, and optional context.
Use predicates to branch logic based on action or method.

**Example: Check action type**

```ruby
def render_record(record, schema_class, action_summary)
  if action_summary.show?
    { data: serialize(record) }
  else
    { data: serialize(record), links: { self: url_for(record) } }
  end
end
```

**Example: Check HTTP method**

```ruby
def render_collection(collection, schema_class, action_summary)
  response = { data: collection.map { |r| serialize(r) } }
  response[:cache] = true if action_summary.get?
  response
end
```

## Instance Methods

### #context()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L37)

**Returns**

`Hash` — arbitrary context passed from the controller

---

### #create?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L69)

**Returns**

`Boolean` — true if this is a create action

---

### #delete?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L111)

**Returns**

`Boolean` — true if HTTP method is DELETE

---

### #destroy?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L81)

**Returns**

`Boolean` — true if this is a destroy action

---

### #get?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L87)

**Returns**

`Boolean` — true if HTTP method is GET

---

### #index?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L57)

**Returns**

`Boolean` — true if this is an index action

---

### #meta()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L45)

**Returns**

`Hash` — metadata for the response

---

### #method()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L33)

**Returns**

`Symbol` — the HTTP method (:get, :post, :patch, :put, :delete)

---

### #name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L29)

**Returns**

`Symbol` — the action name (:index, :show, :create, :update, :destroy, or custom)

---

### #patch?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L99)

**Returns**

`Boolean` — true if HTTP method is PATCH

---

### #post?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L93)

**Returns**

`Boolean` — true if HTTP method is POST

---

### #put?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L105)

**Returns**

`Boolean` — true if HTTP method is PUT

---

### #query()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L41)

**Returns**

`Hash` — parsed query parameters

---

### #show?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L63)

**Returns**

`Boolean` — true if this is a show action

---

### #update?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L75)

**Returns**

`Boolean` — true if this is an update action

---
