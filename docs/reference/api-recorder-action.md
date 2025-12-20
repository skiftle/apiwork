---
order: 8
prev: false
next: false
---

# API::Recorder::Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L6)

## Instance Methods

### #collection(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L43)

Defines collection actions (operate on the resource collection).

Collection actions don't include :id in the URL path.
Use inside a resources block.

**Example**

```ruby
resources :invoices do
  collection do
    get :search
    post :bulk_create
  end
end
# Routes: GET /invoices/search, POST /invoices/bulk_create
```

---

### #delete(actions, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L114)

Declares a DELETE action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `actions` | `Symbol, Array<Symbol>` | action name(s) |
| `options` | `Hash` | action options |

**Example**

```ruby
member { delete :remove_attachment }
```

---

### #get(actions, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L74)

Declares a GET action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `actions` | `Symbol, Array<Symbol>` | action name(s) |
| `options` | `Hash` | action options |

**Example: Inside member block**

```ruby
member { get :status }
```

**Example: With :on option**

```ruby
get :status, on: :member
```

---

### #member(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L22)

Defines member actions (operate on a specific resource).

Member actions include :id in the URL path.
Use inside a resources block.

**Example**

```ruby
resources :invoices do
  member do
    post :archive
    post :send_reminder
  end
end
# Routes: POST /invoices/:id/archive, POST /invoices/:id/send_reminder
```

---

### #patch(actions, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L58)

Declares a PATCH action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `actions` | `Symbol, Array<Symbol>` | action name(s) |
| `options` | `Hash` | action options |

**Example**

```ruby
member { patch :partial_update }
```

---

### #post(actions, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L88)

Declares a POST action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `actions` | `Symbol, Array<Symbol>` | action name(s) |
| `options` | `Hash` | action options |

**Example**

```ruby
member { post :archive }
collection { post :bulk_create }
```

---

### #put(actions, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/action.rb#L101)

Declares a PUT action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `actions` | `Symbol, Array<Symbol>` | action name(s) |
| `options` | `Hash` | action options |

**Example**

```ruby
member { put :replace }
```

---
