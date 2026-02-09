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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L355)

Block for defining collection actions.

Collection routes don't include :id: `/invoices/action`

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
collection do
  get :search
  post :bulk_create
end
```

**Example: yield style**

```ruby
collection do |collection|
  collection.get :search
  collection.post :bulk_create
end
```

---

### #concern

`#concern(concern_name, callable = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L451)

Defines a reusable concern.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`concern_name`** | `Symbol` |  | concern name |
| **`callable`** | `Proc` |  | optional callable instead of block |

</div>

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
concern :commentable do
  resources :comments
end

resources :posts, concerns: [:commentable]
```

**Example: yield style**

```ruby
concern :commentable do |resource|
  resource.resources :comments
end

resources :posts, concerns: [:commentable]
```

---

### #concerns

`#concerns(*concern_names, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L473)

Includes previously defined concerns.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`concern_names`** | `Array<Symbol>` |  | concern names to include |
| `options` | `Hash` | `{}` | options passed to the concern |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L425)

Defines a DELETE action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | action name(s) |
| `on` | `Symbol<:member, :collection>`, `nil` | `nil` |  |

</div>

**Returns**

`void`

**Example**

```ruby
member { delete :archive }
```

---

### #get

`#get(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L373)

Defines a GET action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | action name(s) |
| `on` | `Symbol<:member, :collection>`, `nil` | `nil` |  |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L329)

Block for defining member actions (operate on :id).

Member routes include :id in the path: `/invoices/:id/action`

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
member do
  post :send
  get :preview
end
```

**Example: yield style**

```ruby
member do |member|
  member.post :send
  member.get :preview
end
```

---

### #patch

`#patch(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L399)

Defines a PATCH action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | action name(s) |
| `on` | `Symbol<:member, :collection>`, `nil` | `nil` |  |

</div>

**Returns**

`void`

**Example**

```ruby
member { patch :mark_paid }
```

---

### #post

`#post(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L386)

Defines a POST action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | action name(s) |
| `on` | `Symbol<:member, :collection>`, `nil` | `nil` |  |

</div>

**Returns**

`void`

**Example**

```ruby
member { post :send }
```

---

### #put

`#put(action_names, on: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L412)

Defines a PUT action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | action name(s) |
| `on` | `Symbol<:member, :collection>`, `nil` | `nil` |  |

</div>

**Returns**

`void`

**Example**

```ruby
member { put :replace }
```

---

### #resource

`#resource(resource_name, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L246)

Defines a singular resource (no index, no :id in URL).

Default actions: :show, :create, :update, :destroy.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`resource_name`** | `Symbol` |  | resource name (singular) |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | concerns to include |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | route constraints |
| `contract` | `String`, `nil` | `nil` | custom contract path |
| `controller` | `String`, `nil` | `nil` | custom controller path |
| `defaults` | `Hash`, `nil` | `nil` | default route parameters |
| `except` | `Array<Symbol>`, `nil` | `nil` | actions to exclude |
| `only` | `Array<Symbol>`, `nil` | `nil` | only these CRUD actions |
| `param` | `Symbol`, `nil` | `nil` | custom ID parameter |
| `path` | `String`, `nil` | `nil` | custom URL segment |

</div>

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
resource :profile do
  resources :settings
end
```

**Example: yield style**

```ruby
resource :profile do |resource|
  resource.resources :settings
end
```

---

### #resources

`#resources(resource_name = nil, concerns: nil, constraints: nil, contract: nil, controller: nil, defaults: nil, except: nil, only: nil, param: nil, path: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L181)

Defines a plural resource with standard CRUD actions.

Default actions: :index, :show, :create, :update, :destroy.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`resource_name`** | `Symbol` |  | resource name (plural) |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | concerns to include |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | route constraints |
| `contract` | `String`, `nil` | `nil` | custom contract path |
| `controller` | `String`, `nil` | `nil` | custom controller path |
| `defaults` | `Hash`, `nil` | `nil` | default route parameters |
| `except` | `Array<Symbol>`, `nil` | `nil` | actions to exclude |
| `only` | `Array<Symbol>`, `nil` | `nil` | only these CRUD actions |
| `param` | `Symbol`, `nil` | `nil` | custom ID parameter |
| `path` | `String`, `nil` | `nil` | custom URL segment |

</div>

**Returns**

Hash{Symbol =&gt; [Resource](/reference/api/resource)}

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
resources :invoices do
  member { get :preview }
  resources :items
end
```

**Example: yield style**

```ruby
resources :invoices do |resource|
  resource.member { |member| member.get :preview }
  resource.resources :items
end
```

---

### #with_options

`#with_options(options = {}, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L300)

Applies options to all resources defined in the block.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `options` | `Hash` | `{}` | options to merge into nested resources |

</div>

**Returns**

`void`

**Yields** [Resource](/reference/api/resource)

**Example: instance_eval style**

```ruby
with_options only: [:index, :show] do
  resources :reports
  resources :analytics
end
```

**Example: yield style**

```ruby
with_options only: [:index, :show] do |resource|
  resource.resources :reports
  resource.resources :analytics
end
```

---
