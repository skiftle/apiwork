# Tests TODO: Resource param introspection

These tests must be written before shipping the `parent_param:` feature.

## 1. Custom param on resource itself

```ruby
resources :currencies, param: :code
```

Expected action paths:
- `index:   /currencies`
- `show:    /currencies/:code`
- `create:  /currencies`
- `update:  /currencies/:code`
- `destroy: /currencies/:code`

---

## 2. Custom param on parent affects nested resource paths

```ruby
resources :currencies, param: :code do
  resources :items
end
```

Expected paths for nested `items`:
- `index:   /:code/items`
- `show:    /:code/items/:id`
- `create:  /:code/items`
- `update:  /:code/items/:id`
- `destroy: /:code/items/:id`

---

## 3. Multiple levels of nesting with custom params

```ruby
resources :countries, param: :iso_code do
  resources :regions, param: :region_code do
    resources :cities
  end
end
```

Expected paths for `cities`:
- `index:   /:region_code/cities`
- `show:    /:region_code/cities/:id`

Expected paths for `regions`:
- `index:   /:iso_code/regions`
- `show:    /:iso_code/regions/:region_code`

---

## 4. Default behavior unchanged

```ruby
resources :posts do
  resources :comments
end
```

Expected paths for `comments`:
- `index:   /:post_id/comments`
- `show:    /:post_id/comments/:id`
- `create:  /:post_id/comments`
- `update:  /:post_id/comments/:id`
- `destroy: /:post_id/comments/:id`

---

## 5. parent_identifiers accessor

- `currencies.parent_identifiers` should be `[]`
- `items.parent_identifiers` should be `['currencies']`
- `regions.parent_identifiers` should be `['countries']`
- `cities.parent_identifiers` should be `['countries', 'regions']`
- `comments.parent_identifiers` should be `['posts']`

---

## Test file location

`spec/lib/introspection/resource_param_spec.rb`
