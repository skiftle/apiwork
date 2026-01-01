---
order: 8
prev: false
next: false
---

# Adapter::Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L17)

Describes a resource action.

Passed in the `actions` hash to [Adapter::Base#register_contract](adapter-base#register-contract).
Available at runtime via [Adapter::RenderState#action](adapter-render-state#action).

**Example**

```ruby
actions.each do |name, action|
  if action.collection?
    # index-style
  end
end
```

## Instance Methods

### #collection?

`#collection?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L44)

**Returns**

`Boolean` — true if action operates on a collection

---

### #create?

`#create?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L62)

**Returns**

`Boolean` — true if this is a create action

---

### #delete?

`#delete?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L104)

**Returns**

`Boolean` — true if HTTP method is DELETE

---

### #destroy?

`#destroy?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L74)

**Returns**

`Boolean` — true if this is a destroy action

---

### #get?

`#get?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L80)

**Returns**

`Boolean` — true if HTTP method is GET

---

### #index?

`#index?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L50)

**Returns**

`Boolean` — true if this is an index action

---

### #member?

`#member?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L38)

**Returns**

`Boolean` — true if action operates on a single resource

---

### #method

`#method`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L24)

**Returns**

`Symbol` — HTTP method (:get, :post, :patch, :delete)

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L20)

**Returns**

`Symbol` — action name (:index, :show, :create, :update, :destroy, or custom)

---

### #patch?

`#patch?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L92)

**Returns**

`Boolean` — true if HTTP method is PATCH

---

### #post?

`#post?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L86)

**Returns**

`Boolean` — true if HTTP method is POST

---

### #put?

`#put?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L98)

**Returns**

`Boolean` — true if HTTP method is PUT

---

### #read?

`#read?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L110)

**Returns**

`Boolean` — true if this is a read operation (GET request)

---

### #show?

`#show?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L56)

**Returns**

`Boolean` — true if this is a show action

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L28)

**Returns**

`Symbol` — action type (:member or :collection)

---

### #update?

`#update?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L68)

**Returns**

`Boolean` — true if this is an update action

---

### #write?

`#write?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/action.rb#L116)

**Returns**

`Boolean` — true if this is a write operation (POST, PATCH, PUT, DELETE)

---
