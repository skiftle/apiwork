---
order: 8
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

### #collection?

`#collection?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L105)

**Returns**

`Boolean` — true if action operates on a collection

---

### #context

`#context`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L41)

**Returns**

`Hash` — arbitrary context passed from the controller

---

### #create?

`#create?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L81)

**Returns**

`Boolean` — true if this is a create action

---

### #delete?

`#delete?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L135)

**Returns**

`Boolean` — true if HTTP method is DELETE

---

### #destroy?

`#destroy?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L93)

**Returns**

`Boolean` — true if this is a destroy action

---

### #get?

`#get?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L111)

**Returns**

`Boolean` — true if HTTP method is GET

---

### #index?

`#index?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L69)

**Returns**

`Boolean` — true if this is an index action

---

### #member?

`#member?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L99)

**Returns**

`Boolean` — true if action operates on a single resource

---

### #meta

`#meta`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L49)

**Returns**

`Hash` — metadata for the response

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L33)

**Returns**

`Symbol` — the HTTP method (:get, :post, :patch, :put, :delete)

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L29)

**Returns**

`Symbol` — the action name (:index, :show, :create, :update, :destroy, or custom)

---

### #patch?

`#patch?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L123)

**Returns**

`Boolean` — true if HTTP method is PATCH

---

### #post?

`#post?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L117)

**Returns**

`Boolean` — true if HTTP method is POST

---

### #put?

`#put?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L129)

**Returns**

`Boolean` — true if HTTP method is PUT

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L45)

**Returns**

`Hash` — parsed query parameters

---

### #read?

`#read?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L141)

**Returns**

`Boolean` — true if this is a read operation (GET request)

---

### #show?

`#show?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L75)

**Returns**

`Boolean` — true if this is a show action

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L37)

**Returns**

`Symbol`, `nil` — the action type (:member or :collection)

---

### #update?

`#update?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L87)

**Returns**

`Boolean` — true if this is an update action

---

### #write?

`#write?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action_summary.rb#L147)

**Returns**

`Boolean` — true if this is a write operation (POST, PATCH, PUT, DELETE)

---
