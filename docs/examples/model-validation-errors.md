---
order: 7
---

# Model Validation Errors

How Apiwork captures ActiveRecord validation errors and presents them in a unified format

## API Definition

<small>`config/apis/happy_zebra.rb`</small>

<<< @/playground/config/apis/happy_zebra.rb

## Models

<small>`app/models/happy_zebra/user.rb`</small>

<<< @/playground/app/models/happy_zebra/user.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| email | string |  |  |
| updated_at | datetime |  |  |
| username | string |  |  |

</details>

<small>`app/models/happy_zebra/profile.rb`</small>

<<< @/playground/app/models/happy_zebra/profile.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| bio | text | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |
| user_id | string |  |  |
| website | string | ✓ |  |

</details>

<small>`app/models/happy_zebra/post.rb`</small>

<<< @/playground/app/models/happy_zebra/post.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| title | string |  |  |
| updated_at | datetime |  |  |
| user_id | string |  |  |

</details>

<small>`app/models/happy_zebra/comment.rb`</small>

<<< @/playground/app/models/happy_zebra/comment.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| author | string |  |  |
| body | string |  |  |
| created_at | datetime |  |  |
| post_id | string |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/happy_zebra/user_schema.rb`</small>

<<< @/playground/app/schemas/happy_zebra/user_schema.rb

<small>`app/schemas/happy_zebra/profile_schema.rb`</small>

<<< @/playground/app/schemas/happy_zebra/profile_schema.rb

<small>`app/schemas/happy_zebra/post_schema.rb`</small>

<<< @/playground/app/schemas/happy_zebra/post_schema.rb

<small>`app/schemas/happy_zebra/comment_schema.rb`</small>

<<< @/playground/app/schemas/happy_zebra/comment_schema.rb

## Contracts

<small>`app/contracts/happy_zebra/user_contract.rb`</small>

<<< @/playground/app/contracts/happy_zebra/user_contract.rb

<small>`app/contracts/happy_zebra/profile_contract.rb`</small>

<<< @/playground/app/contracts/happy_zebra/profile_contract.rb

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

---



## Request Examples

<details>
<summary>Create valid user</summary>

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
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "id": "c8f3124b-cf0c-55c4-b8e7-106c58c6a686",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "bio": "Software developer",
      "website": "https://example.com"
    },
    "posts": []
  }
}
```

</details>

<details>
<summary>Invalid email format</summary>

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
  "layer": "domain",
  "errors": [
    {
      "code": "invalid",
      "detail": "Invalid",
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email",
      "meta": {}
    }
  ]
}
```

</details>

<details>
<summary>Missing required fields</summary>

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

**Response** `400`

```json
{
  "layer": "contract",
  "errors": [
    {
      "code": "field_missing",
      "detail": "Required",
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email",
      "meta": {
        "field": "email",
        "type": "string"
      }
    },
    {
      "code": "field_missing",
      "detail": "Required",
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username",
      "meta": {
        "field": "username",
        "type": "string"
      }
    }
  ]
}
```

</details>

<details>
<summary>Invalid nested profile</summary>

**Request**

```http
POST /happy_zebra/users
Content-Type: application/json

{
  "user": {
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "bio": "This bio is way too long and exceeds the maximum allowed length of 500 characters. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Extra text to exceed limit.",
      "website": "not-a-valid-url"
    }
  }
}
```

**Response** `422`

```json
{
  "layer": "domain",
  "errors": [
    {
      "code": "max",
      "detail": "Too long",
      "path": [
        "user",
        "profile",
        "bio"
      ],
      "pointer": "/user/profile/bio",
      "meta": {
        "max": 500
      }
    },
    {
      "code": "invalid",
      "detail": "Invalid",
      "path": [
        "user",
        "profile",
        "website"
      ],
      "pointer": "/user/profile/website",
      "meta": {}
    }
  ]
}
```

</details>

<details>
<summary>Create with deep nesting</summary>

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
    "id": "4448fe72-0e01-5b7d-962d-1a20ce251a01",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "email": "deep@example.com",
    "username": "deepuser",
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

</details>

<details>
<summary>Deep nested validation error</summary>

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
  "layer": "domain",
  "errors": [
    {
      "code": "required",
      "detail": "Required",
      "path": [
        "user",
        "posts",
        "0",
        "comments",
        "0",
        "body"
      ],
      "pointer": "/user/posts/0/comments/0/body",
      "meta": {}
    },
    {
      "code": "min",
      "detail": "Too short",
      "path": [
        "user",
        "posts",
        "0",
        "comments",
        "0",
        "body"
      ],
      "pointer": "/user/posts/0/comments/0/body",
      "meta": {
        "min": 1
      }
    },
    {
      "code": "required",
      "detail": "Required",
      "path": [
        "user",
        "posts",
        "0",
        "comments",
        "0",
        "author"
      ],
      "pointer": "/user/posts/0/comments/0/author",
      "meta": {}
    }
  ]
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/happy-zebra/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/happy-zebra/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/happy-zebra/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/happy-zebra/openapi.yml

</details>