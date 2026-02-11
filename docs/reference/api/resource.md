---
order: 9
prev: false
next: false
---

# Resource

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L26)

Block context for defining API resources and routes.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L376)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L484)

Defines a reusable concern.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`concern_name`** | `Symbol` |  | The concern name. |
| **`callable`** | `Proc` |  | Optional callable instead of block. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L508)

Includes previously defined concerns.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`concern_names`** | `Array<Symbol>` |  | The concern names to include. |
| `options` | `Hash` | `{}` | The options passed to the concern. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L456)

Defines a DELETE action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | The action name(s). |
| `on` | `Symbol<:collection, :member>`, `nil` | `nil` | The scope. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L396)

Defines a GET action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | The action name(s). |
| `on` | `Symbol<:collection, :member>`, `nil` | `nil` | The scope. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L350)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L426)

Defines a PATCH action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | The action name(s). |
| `on` | `Symbol<:collection, :member>`, `nil` | `nil` | The scope. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L411)

Defines a POST action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | The action name(s). |
| `on` | `Symbol<:collection, :member>`, `nil` | `nil` | The scope. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L441)

Defines a PUT action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action_names`** | `Symbol`, `Array<Symbol>` |  | The action name(s). |
| `on` | `Symbol<:collection, :member>`, `nil` | `nil` | The scope. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L266)

Defines a singular resource (no index, no :id in URL).

Default actions: :show, :create, :update, :destroy.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`resource_name`** | `Symbol` |  | The resource name (singular). |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | The concerns to include. |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | The route constraints. |
| `contract` | `String`, `nil` | `nil` | The custom contract path. |
| `controller` | `String`, `nil` | `nil` | The custom controller path. |
| `defaults` | `Hash`, `nil` | `nil` | The default route parameters. |
| `except` | `Array<Symbol>`, `nil` | `nil` | The actions to exclude. |
| `only` | `Array<Symbol>`, `nil` | `nil` | The CRUD actions to include. |
| `param` | `Symbol`, `nil` | `nil` | The custom ID parameter. |
| `path` | `String`, `nil` | `nil` | The custom URL segment. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L191)

Defines a plural resource with standard CRUD actions.

Default actions: :index, :show, :create, :update, :destroy.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`resource_name`** | `Symbol` |  | The resource name (plural). |
| `concerns` | `Array<Symbol>`, `nil` | `nil` | The concerns to include. |
| `constraints` | `Hash`, `Proc`, `nil` | `nil` | The route constraints. |
| `contract` | `String`, `nil` | `nil` | The custom contract path. |
| `controller` | `String`, `nil` | `nil` | The custom controller path. |
| `defaults` | `Hash`, `nil` | `nil` | The default route parameters. |
| `except` | `Array<Symbol>`, `nil` | `nil` | The actions to exclude. |
| `only` | `Array<Symbol>`, `nil` | `nil` | The CRUD actions to include. |
| `param` | `Symbol`, `nil` | `nil` | The custom ID parameter. |
| `path` | `String`, `nil` | `nil` | The custom URL segment. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/resource.rb#L321)

Applies options to all resources defined in the block.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `options` | `Hash` | `{}` | The options to merge into nested resources. |

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
