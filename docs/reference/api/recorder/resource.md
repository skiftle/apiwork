---
order: 9
prev: false
next: false
---

# Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/recorder/resource.rb#L6)

## Instance Methods

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
