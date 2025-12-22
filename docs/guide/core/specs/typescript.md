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
spec :typescript do
  path '/types.ts'          # Custom endpoint path
  key_format :camel         # Transform keys to camelCase
end
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

## Type Ordering

Types are sorted in topological order so dependencies come first. Enums appear before types that use them, and custom types appear before schemas that reference them.

Recursive types (types that reference themselves) work naturally in TypeScript interfaces.

## JSDoc Comments

Descriptions from your Ruby code become JSDoc comments in TypeScript. This gives you hover documentation in VS Code and other editors.

```ruby
Apiwork::API.define '/api/v1' do
  type :invoice, description: 'Represents a customer invoice' do
    param :id, type: :string, description: 'Unique identifier'
    param :amount, type: :decimal, description: 'Total amount', example: 99.99
  end

  enum :status, values: %w[draft sent paid], description: 'Invoice status'
end
```

Generated TypeScript:

```typescript
/**
 * Represents a customer invoice
 */
export interface Invoice {
  /** Total amount @example 99.99 */
  amount: number;
  /** Unique identifier */
  id: string;
}

/**
 * Invoice status
 */
export type Status = 'draft' | 'paid' | 'sent';
```

Hover over types in your editor to see the descriptions.

This works for:

- Types and interfaces
- Properties
- Enums

No JSDoc is generated when `description` is missing. Changes to Ruby descriptions appear in the next TypeScript generation.
