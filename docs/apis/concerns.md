---
order: 4
---

# Concerns

Concerns allow you to extract reusable routing patterns and apply them to multiple resources.  
They help keep your API definition organised and prevent duplication when several resources share the same endpoint structure.

## Defining a Concern

```ruby
Apiwork::API.draw '/api/v1' do
  concern :auditable do
    member do
      get :audit_log
    end
  end

  resources :posts, concerns: [:auditable]
  resources :comments, concerns: [:auditable]
end
```

Both posts and comments now have a `GET /posts/:id/audit_log` and `GET /comments/:id/audit_log` endpoint.

## Multiple Concerns

```ruby
concern :auditable do
  member do
    get :audit_log
  end
end

concern :searchable do
  collection do
    get :search
  end
end

resources :posts, concerns: [:auditable, :searchable]
```

## Concerns with Nested Resources

```ruby
concern :commentable do
  resources :comments do
    member do
      patch :approve
      patch :reject
    end

    collection do
      get :pending
    end
  end
end

resources :posts, concerns: [:commentable]
resources :articles, concerns: [:commentable]
```

Both posts and articles now have nested comment routes with approve, reject, and pending actions.
