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
POST /happy-zebra/users
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
    "id": "63f55eeb-6e3a-4208-9de3-10cf3abe72ba",
    "created_at": "2025-12-07T12:02:58.138Z",
    "updated_at": "2025-12-07T12:02:58.138Z",
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "id": "eaf0e6a3-c7c8-46d8-a22a-9f05c7016b74",
      "created_at": "2025-12-07T12:02:58.139Z",
      "updated_at": "2025-12-07T12:02:58.139Z",
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
POST /happy-zebra/users
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
POST /happy-zebra/users
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
POST /happy-zebra/users
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
POST /happy-zebra/users
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
    "id": "4dbdf6a1-67df-4505-953e-be556840deca",
    "created_at": "2025-12-07T12:02:58.172Z",
    "updated_at": "2025-12-07T12:02:58.172Z",
    "email": "deep@example.com",
    "username": "deepuser",
    "profile": null,
    "posts": [
      {
        "id": "80ee2cca-d085-4016-a742-13c33ab4fd9f",
        "title": "My First Post",
        "comments": [
          {
            "id": "5217d2df-5b29-4c51-a8e3-e73986811766",
            "body": "Great post!",
            "author": "Jane"
          },
          {
            "id": "b3f1597f-e29c-49f0-8cf6-273d5ba73355",
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
POST /happy-zebra/users
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