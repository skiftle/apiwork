---
order: 8
prev: false
next: false
---

# Recorder

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder.rb#L5)

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

### #concern(name, callable = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/concern.rb#L7)

---

### #concerns(*names, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/concern.rb#L12)

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

### #initialize(metadata, namespaces)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder.rb#L13)

**Returns**

`Recorder` — a new instance of Recorder

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

### #metadata()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder.rb#L11)

Returns the value of attribute metadata.

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

### #resource(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/resource.rb#L71)

Defines a singular resource (no index action, no :id in URL).

Useful for resources where there's only one instance,
like user profile or application settings.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (singular) |
| `options` | `Hash` | resource options (same as resources) |

**Example: Singular resource**

```ruby
resource :profile
# Routes: GET /profile, PATCH /profile (no index, no :id)
```

**Example: With actions**

```ruby
resource :settings do
  member { post :reset }
end
```

---

### #resources(name, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/resource.rb#L32)

Defines a RESTful resource with standard CRUD actions.

Creates routes for index, show, create, update, destroy actions.
Nested resources and custom actions can be defined in the block.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | resource name (plural) |
| `options` | `Hash` | resource options |

**Example: Basic resource**

```ruby
resources :invoices
```

**Example: Limited actions**

```ruby
resources :invoices, only: [:index, :show]
```

**Example: With custom actions**

```ruby
resources :invoices do
  member { post :archive }
  resources :line_items
end
```

---

### #with_options(options = {}, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/resource.rb#L93)

---
