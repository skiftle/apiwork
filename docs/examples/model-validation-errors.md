---
order: 7
---

# Model Validation Errors

How Apiwork captures ActiveRecord validation errors and presents them in a unified format

## API Definition

<small>`config/apis/happy_zebra.rb`</small>

<<< @/app/config/apis/happy_zebra.rb

## Models

<small>`app/models/happy_zebra/comment.rb`</small>

<<< @/app/app/models/happy_zebra/comment.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| post_id | string |  |  |
| body | string |  |  |
| author | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/happy_zebra/post.rb`</small>

<<< @/app/app/models/happy_zebra/post.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| user_id | string |  |  |
| title | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/happy_zebra/profile.rb`</small>

<<< @/app/app/models/happy_zebra/profile.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| user_id | string |  |  |
| bio | text | ✓ |  |
| website | string | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/happy_zebra/user.rb`</small>

<<< @/app/app/models/happy_zebra/user.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| email | string |  |  |
| username | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/happy_zebra/comment_schema.rb`</small>

<<< @/app/app/schemas/happy_zebra/comment_schema.rb

<small>`app/schemas/happy_zebra/post_schema.rb`</small>

<<< @/app/app/schemas/happy_zebra/post_schema.rb

<small>`app/schemas/happy_zebra/profile_schema.rb`</small>

<<< @/app/app/schemas/happy_zebra/profile_schema.rb

<small>`app/schemas/happy_zebra/user_schema.rb`</small>

<<< @/app/app/schemas/happy_zebra/user_schema.rb

## Contracts

<small>`app/contracts/happy_zebra/comment_contract.rb`</small>

<<< @/app/app/contracts/happy_zebra/comment_contract.rb

<small>`app/contracts/happy_zebra/post_contract.rb`</small>

<<< @/app/app/contracts/happy_zebra/post_contract.rb

<small>`app/contracts/happy_zebra/user_contract.rb`</small>

<<< @/app/app/contracts/happy_zebra/user_contract.rb

## Controllers

<small>`app/controllers/happy_zebra/comments_controller.rb`</small>

<<< @/app/app/controllers/happy_zebra/comments_controller.rb

<small>`app/controllers/happy_zebra/posts_controller.rb`</small>

<<< @/app/app/controllers/happy_zebra/posts_controller.rb

<small>`app/controllers/happy_zebra/users_controller.rb`</small>

<<< @/app/app/controllers/happy_zebra/users_controller.rb

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
    "id": "98a3b0ee-2d9f-45c4-9efb-337993514f8c",
    "createdAt": "2025-12-07T15:57:33.259Z",
    "updatedAt": "2025-12-07T15:57:33.259Z",
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "id": "9d0ee84d-8738-4294-8317-09f5fcf1e9e7",
      "createdAt": "2025-12-07T15:57:33.261Z",
      "updatedAt": "2025-12-07T15:57:33.261Z",
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
  "issues": [
    {
      "code": "invalid",
      "detail": "is invalid",
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email",
      "meta": {
        "attribute": "email"
      }
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
  "issues": [
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email",
      "meta": {
        "field": "email"
      }
    },
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username",
      "meta": {
        "field": "username"
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
  "issues": [
    {
      "code": "too_long",
      "detail": "is too long (maximum is 500 characters)",
      "path": [
        "user",
        "profile",
        "bio"
      ],
      "pointer": "/user/profile/bio",
      "meta": {
        "attribute": "bio",
        "count": 500
      }
    },
    {
      "code": "invalid",
      "detail": "is invalid",
      "path": [
        "user",
        "profile",
        "website"
      ],
      "pointer": "/user/profile/website",
      "meta": {
        "attribute": "website"
      }
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
    "id": "2ca6a082-068f-4705-8bba-f98afcc51a80",
    "createdAt": "2025-12-07T15:57:33.293Z",
    "updatedAt": "2025-12-07T15:57:33.293Z",
    "email": "deep@example.com",
    "username": "deepuser",
    "profile": null,
    "posts": [
      {
        "id": "11669fc4-fbfd-44b0-8866-28cf4cf8eb5d",
        "title": "My First Post",
        "comments": [
          {
            "id": "d6a38b4b-01c5-4c4a-ac3f-26d34a9b37f0",
            "body": "Great post!",
            "author": "Jane"
          },
          {
            "id": "191eb702-2d3d-4105-9a97-fb8e07ee12d1",
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
  "issues": [
    {
      "code": "blank",
      "detail": "can't be blank",
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
        "attribute": "body"
      }
    },
    {
      "code": "too_short",
      "detail": "is too short (minimum is 1 character)",
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
        "attribute": "body",
        "count": 1
      }
    },
    {
      "code": "blank",
      "detail": "can't be blank",
      "path": [
        "user",
        "posts",
        "0",
        "comments",
        "0",
        "author"
      ],
      "pointer": "/user/posts/0/comments/0/author",
      "meta": {
        "attribute": "author"
      }
    }
  ]
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/happy-zebra/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/happy-zebra/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/happy-zebra/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/happy-zebra/openapi.yml

</details>