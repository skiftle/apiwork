---
order: 1
---
# API Definitions

The API definition is the entry point to Apiwork. It declares which resources the API exposes and how the boundary is configured.

## What API Definitions Do

Every API definition sets up:

- **Base path** — where routes are mounted (`/api/v1`)
- **Namespace** — where Apiwork resolves controllers, contracts, and representations
- **Resources** — which endpoints exist and how they are nested
- **Configuration** — key format, adapter, pagination, and global defaults
- **Exports** — which formats to generate (OpenAPI, TypeScript, Zod)
- **Metadata** — title, version, and servers for documentation and exports

## A Minimal Definition

API definitions live in `config/apis/`. A minimal definition declares a base path and its resources:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  resources :posts
  resources :comments
end
```

The base path determines both the mount point and the namespace. `/api/v1` maps to `Api::V1` — so `resources :posts` expects `Api::V1::PostsController`, `Api::V1::PostContract`, and `Api::V1::PostRepresentation`.

Each definition is independent. Different API versions can have different configurations without affecting each other.

## Next Steps

- [Resources](./resources.md) — declaring endpoints, nesting, and action filtering
- [Configuration](./configuration.md) — key format, adapter, pagination defaults
- [Types](./types.md) — global types shared across contracts
- [Exports](./exports.md) — enabling OpenAPI, TypeScript, and Zod generation
- [Metadata](./metadata.md) — title, version, servers, and translations

#### See also

- [API::Base reference](../../reference/api/base.md) — all API definition methods and options
