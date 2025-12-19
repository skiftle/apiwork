---
order: 3
---

# TypeScript

Generates TypeScript type definitions.

## Configuration

```ruby
Apiwork::API.define '/api/v1' do
  spec :typescript
end
```

## Options

```ruby
spec :typescript,
     path: '/types.ts',         # Custom endpoint path
     key_format: :camel      # Transform keys to camelCase
```

## Output

The generated output includes:

- Enum types
- Custom types
- Request/response interfaces per action

```typescript
// Enums
export type Status = 'draft' | 'published' | 'archived';

// Custom types
export interface Address {
  street: string;
  city: string;
  country: string;
}

// Resource types
export interface Post {
  id: number;
  title: string;
  body: string;
  status: Status;
  createdAt: string;
}

// Request types
export interface PostCreateRequest {
  post: {
    title: string;
    body?: string;
    status?: Status;
  };
}

// Response types
export interface PostShowResponse {
  post: Post;
}

export interface PostIndexResponse {
  posts: Post[];
}
```

## Usage

Download and use in your frontend:

```bash
curl http://localhost:3000/api/v1/.spec/typescript > src/api/types.ts
```

```typescript
import { Post, PostCreateRequest } from './api/types';

async function createPost(data: PostCreateRequest): Promise<Post> {
  const response = await fetch('/api/v1/posts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
  return response.json();
}
```
