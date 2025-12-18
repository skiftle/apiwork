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
    "id": "e3877308-69e3-49e5-a2c8-51c3bd274d1c",
    "createdAt": "2025-12-18T13:29:04.362Z",
    "updatedAt": "2025-12-18T13:29:04.362Z",
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "id": "b3976b9f-05af-4b58-99be-f8444aa23d56",
      "createdAt": "2025-12-18T13:29:04.364Z",
      "updatedAt": "2025-12-18T13:29:04.364Z",
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
    "id": "b4d8ccd0-7107-4940-b5b3-fd8b688a23f9",
    "createdAt": "2025-12-18T13:29:04.403Z",
    "updatedAt": "2025-12-18T13:29:04.403Z",
    "email": "deep@example.com",
    "username": "deepuser",
    "profile": null,
    "posts": [
      {
        "id": "6c16cc1a-652c-40c2-8be8-22cbd6638ea5",
        "title": "My First Post",
        "comments": [
          {
            "id": "b8fd5e2b-6343-4b2f-bfbc-498026adc188",
            "body": "Great post!",
            "author": "Jane"
          },
          {
            "id": "aef53ce7-48e8-4f72-90f2-c1140432a957",
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