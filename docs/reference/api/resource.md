---
order: 9
prev: false
next: false
---

# Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L26)

DSL context for defining API resources and routes.

Resource provides the DSL available inside `resources` and `resource`
blocks. Methods include nested resources, custom actions, and concerns.

**Example: Defining resources with actions**

```ruby
Apiwork::API.define '/api/v1' do
  resources :invoices do
    member do
      post :send
      get :preview
    end

    collection do
      get :search
    end

    resources :items
  end
end
```

## Instance Methods

### #collection

`#collection(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L317)

Block for defining collection actions.

Collection routes don't include :id: `/invoices/action`

**Returns**

`void`

**Example**

```ruby
collection do
  get :search
  post :bulk_create
end
```

---

### #concern

`#concern(concern_name, callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L405)

Defines a reusable concern.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `concern_name` | `Symbol` | concern name |
| `callable` | `Proc` | optional callable instead of block |

**Returns**

`void`

**Example**

```ruby
concern :commentable do
  resources :comments
end

resources :posts, concerns: [:commentable]
```

---

### #concerns

`#concerns(*concern_names, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L421)

Includes previously defined concerns.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `concern_names` | `Array<Symbol>` | concern names to include |
| `options` | `Hash` | options passed to the concern |

**Returns**

`void`

**Example**

```ruby
resources :posts do
  concerns :commentable, :taggable
end
```

---

### #delete

`#delete(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L387)

Defines a DELETE action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_names` | `Symbol, Array<Symbol>` | action name(s) |
| `on` | `Symbol` | :member or :collection |

**Returns**

`void`

**Example**

```ruby
member { delete :archive }
```

---

### #get

`#get(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L335)

Defines a GET action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_names` | `Symbol, Array<Symbol>` | action name(s) |
| `on` | `Symbol` | :member or :collection |

**Returns**

`void`

**Example: Inside member block**

```ruby
member { get :preview }
```

**Example: With on parameter**

```ruby
get :search, on: :collection
```

---

### #member

`#member(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L298)

Block for defining member actions (operate on :id).

Member routes include :id in the path: `/invoices/:id/action`

**Returns**

`void`

**Example**

```ruby
member do
  post :send
  get :preview
end
```

---

### #patch

`#patch(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L361)

Defines a PATCH action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_names` | `Symbol, Array<Symbol>` | action name(s) |
| `on` | `Symbol` | :member or :collection |

**Returns**

`void`

**Example**

```ruby
member { patch :mark_paid }
```

---

### #post

`#post(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L348)

Defines a POST action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_names` | `Symbol, Array<Symbol>` | action name(s) |
| `on` | `Symbol` | :member or :collection |

**Returns**

`void`

**Example**

```ruby
member { post :send }
```

---

### #put

`#put(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L374)

Defines a PUT action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_names` | `Symbol, Array<Symbol>` | action name(s) |
| `on` | `Symbol` | :member or :collection |

**Returns**

`void`

**Example**

```ruby
member { put :replace }
```

---

### #resource

`#resource(resource_name, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L231)

Defines a singular resource (no index, no :id in URL).

Default actions: :show, :create, :update, :destroy.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `resource_name` | `Symbol` | resource name (singular) |
| `concerns` | `Array<Symbol>` | concerns to include |
| `constraints` | `Hash, Proc` | route constraints |
| `contract` | `String` | custom contract path |
| `controller` | `String` | custom controller path |
| `defaults` | `Hash` | default route parameters |
| `except` | `Array<Symbol>` | CRUD actions to exclude |
| `only` | `Array<Symbol>` | only these CRUD actions |
| `param` | `Symbol` | custom ID parameter |
| `path` | `String` | custom URL segment |

**Returns**

`void`

**Example**

```ruby
resource :profile
```

---

### #resources

`#resources(resource_name = nil, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L176)

Defines a plural resource with standard CRUD actions.

Default actions: :index, :show, :create, :update, :destroy.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `resource_name` | `Symbol` | resource name (plural) |
| `concerns` | `Array<Symbol>` | concerns to include |
| `constraints` | `Hash, Proc` | route constraints |
| `contract` | `String` | custom contract path |
| `controller` | `String` | custom controller path |
| `defaults` | `Hash` | default route parameters |
| `except` | `Array<Symbol>` | CRUD actions to exclude |
| `only` | `Array<Symbol>` | only these CRUD actions |
| `param` | `Symbol` | custom ID parameter |
| `path` | `String` | custom URL segment |

**Returns**

Hash{Symbol =&gt; [Resource](/reference/api/resource)} — resources hash when called without name

**Example: Basic resource**

```ruby
resources :invoices
```

**Example: With options**

```ruby
resources :invoices, only: [:index, :show] do
  member { get :preview }
end
```

---

### #with_options

`#with_options(options = {}, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L276)

Applies options to all resources defined in the block.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options` | `Hash` | options to merge into nested resources |

**Returns**

`void`

**Example**

```ruby
with_options only: [:index, :show] do
  resources :reports
  resources :analytics
end
```

---
