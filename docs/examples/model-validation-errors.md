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

<small>`app/models/happy_zebra/post.rb`</small>

<<< @/app/app/models/happy_zebra/post.rb

<small>`app/models/happy_zebra/profile.rb`</small>

<<< @/app/app/models/happy_zebra/profile.rb

<small>`app/models/happy_zebra/user.rb`</small>

<<< @/app/app/models/happy_zebra/user.rb

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
<summary>create_valid</summary>

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
    "id": "5a98f4e4-9800-483e-84d9-4072a7780ae1",
    "created_at": "2025-12-07T10:25:49.217Z",
    "updated_at": "2025-12-07T10:25:49.217Z",
    "email": "john@example.com",
    "username": "johndoe",
    "profile": {
      "id": "05aa3091-5bd2-4a0b-9713-328833c2c474",
      "created_at": "2025-12-07T10:25:49.219Z",
      "updated_at": "2025-12-07T10:25:49.219Z",
      "bio": "Software developer",
      "website": "https://example.com"
    },
    "posts": []
  }
}
```

</details>

<details>
<summary>create_invalid_email</summary>

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
<summary>create_missing_fields</summary>

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
<summary>create_nested_invalid</summary>

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
<summary>create_deep_nested_valid</summary>

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
    "id": "94b82112-1c44-4f66-adb9-3cee013afc56",
    "created_at": "2025-12-07T10:25:49.292Z",
    "updated_at": "2025-12-07T10:25:49.292Z",
    "email": "deep@example.com",
    "username": "deepuser",
    "profile": null,
    "posts": [
      {
        "id": "04a688c9-0f5b-43be-945c-6a4a999b1605",
        "title": "My First Post",
        "comments": [
          {
            "id": "7c778ae7-0cb4-45e1-bebc-934f8d36a24a",
            "body": "Great post!",
            "author": "Jane"
          },
          {
            "id": "3a716658-7d85-40f2-9d62-54fc2ee29c74",
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
<summary>create_deep_nested_invalid</summary>

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