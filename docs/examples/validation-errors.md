---
order: 16
---

# Validation Errors

ActiveRecord validation errors captured and presented in a unified format

## API Definition

<small>`config/apis/happy_zebra.rb`</small>

<<< @/playground/config/apis/happy_zebra.rb

## Models

<small>`app/models/happy_zebra/user.rb`</small>

<<< @/playground/app/models/happy_zebra/user.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| email | string |  |  |
| updated_at | datetime |  |  |
| username | string |  |  |

:::

<small>`app/models/happy_zebra/profile.rb`</small>

<<< @/playground/app/models/happy_zebra/profile.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| bio | text | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |
| user_id | string |  |  |
| website | string | ✓ |  |

:::

<small>`app/models/happy_zebra/post.rb`</small>

<<< @/playground/app/models/happy_zebra/post.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| title | string |  |  |
| updated_at | datetime |  |  |
| user_id | string |  |  |

:::

<small>`app/models/happy_zebra/comment.rb`</small>

<<< @/playground/app/models/happy_zebra/comment.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| author | string |  |  |
| body | string |  |  |
| created_at | datetime |  |  |
| post_id | string |  |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/happy_zebra/user_representation.rb`</small>

<<< @/playground/app/representations/happy_zebra/user_representation.rb

<small>`app/representations/happy_zebra/profile_representation.rb`</small>

<<< @/playground/app/representations/happy_zebra/profile_representation.rb

<small>`app/representations/happy_zebra/post_representation.rb`</small>

<<< @/playground/app/representations/happy_zebra/post_representation.rb

<small>`app/representations/happy_zebra/comment_representation.rb`</small>

<<< @/playground/app/representations/happy_zebra/comment_representation.rb

## Contracts

<small>`app/contracts/happy_zebra/user_contract.rb`</small>

<<< @/playground/app/contracts/happy_zebra/user_contract.rb

<small>`app/contracts/happy_zebra/post_contract.rb`</small>

<<< @/playground/app/contracts/happy_zebra/post_contract.rb

<small>`app/contracts/happy_zebra/comment_contract.rb`</small>

<<< @/playground/app/contracts/happy_zebra/comment_contract.rb

## Controllers

<small>`app/controllers/happy_zebra/users_controller.rb`</small>

<<< @/playground/app/controllers/happy_zebra/users_controller.rb

<small>`app/controllers/happy_zebra/posts_controller.rb`</small>

<<< @/playground/app/controllers/happy_zebra/posts_controller.rb

<small>`app/controllers/happy_zebra/comments_controller.rb`</small>

<<< @/playground/app/controllers/happy_zebra/comments_controller.rb

## Request Examples

::: details Create valid user

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "bio": "Software developer",
      "website": "https://example.com"
    }
  }
}
```

**Response** `201`

```json
{
  "user": {
    "id": "571466c2-02cb-52cb-a9d1-7bd5f8e21034",
    "email": "john@example.com",
    "username": "johndoe",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "profile": {
      "id": "c8f3124b-cf0c-55c4-b8e7-106c58c6a686",
      "bio": "Software developer",
      "website": "https://example.com",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    "posts": []
  }
}
```

:::

::: details Invalid email format

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "not-an-email",
    "username": "johndoe"
  }
}
```

**Response** `422`

```json
{
  "issues": [
    {
      "code": "invalid",
      "detail": "Invalid",
      "meta": {},
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    }
  ],
  "layer": "domain"
}
```

:::

::: details Empty required fields

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "",
    "username": ""
  }
}
```

**Response** `422`

```json
{
  "issues": [
    {
      "code": "invalid",
      "detail": "Invalid",
      "meta": {},
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "required",
      "detail": "Required",
      "meta": {},
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "min",
      "detail": "Too short",
      "meta": {
        "min": 3
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    },
    {
      "code": "required",
      "detail": "Required",
      "meta": {},
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    }
  ],
  "layer": "domain"
}
```

:::

::: details Invalid nested profile

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "bio": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Extra text to push this well over the five hundred character limit that exists."
    }
  }
}
```

**Response** `422`

```json
{
  "issues": [
    {
      "code": "max",
      "detail": "Too long",
      "meta": {
        "max": 500
      },
      "path": [
        "user",
        "profile",
        "bio"
      ],
      "pointer": "/user/profile/bio"
    }
  ],
  "layer": "domain"
}
```

:::

::: details Create with deep nesting

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "deep@example.com",
    "username": "deepuser",
    "posts": [
      {
        "title": "My First Post",
        "comments": [
          {
            "body": "Great post!",
            "author": "Jane"
          },
          {
            "body": "Thanks for sharing",
            "author": "Bob"
          }
        ]
      }
    ]
  }
}
```

**Response** `201`

```json
{
  "user": {
    "id": "571466c2-02cb-52cb-a9d1-7bd5f8e21034",
    "email": "deep@example.com",
    "username": "deepuser",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "profile": null,
    "posts": [
      {
        "id": "f79aecb1-8fa0-5c07-8478-508eb2320f28",
        "title": "My First Post",
        "comments": [
          {
            "id": "59e8d0c6-28d3-518c-a286-d8e2dd65062a",
            "body": "Great post!",
            "author": "Jane"
          },
          {
            "id": "f3484847-e838-513d-8b33-1dd8a97dcb44",
            "body": "Thanks for sharing",
            "author": "Bob"
          }
        ]
      }
    ]
  }
}
```

:::

::: details Custom base error

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "same@example.com",
    "username": "same@example.com"
  }
}
```

**Response** `422`

```json
{
  "issues": [
    {
      "code": "conflict",
      "detail": "Conflict",
      "meta": {},
      "path": [
        "user"
      ],
      "pointer": "/user"
    }
  ],
  "layer": "domain"
}
```

:::

::: details Deep nested validation error

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "deep@example.com",
    "username": "deepuser",
    "posts": [
      {
        "title": "My Post",
        "comments": [
          {
            "body": "",
            "author": ""
          }
        ]
      }
    ]
  }
}
```

**Response** `422`

```json
{
  "issues": [
    {
      "code": "required",
      "detail": "Required",
      "meta": {},
      "path": [
        "user",
        "posts",
        "0",
        "comments",
        "0",
        "body"
      ],
      "pointer": "/user/posts/0/comments/0/body"
    },
    {
      "code": "required",
      "detail": "Required",
      "meta": {},
      "path": [
        "user",
        "posts",
        "0",
        "comments",
        "0",
        "author"
      ],
      "pointer": "/user/posts/0/comments/0/author"
    }
  ],
  "layer": "domain"
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/happy-zebra/introspection.json

:::

::: details TypeScript

<<< @/playground/public/happy-zebra/typescript.ts

:::

::: details Zod

<<< @/playground/public/happy-zebra/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/happy-zebra/openapi.yml

:::