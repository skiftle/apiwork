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

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "email"
      },
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "username"
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "profile"
      },
      "path": [
        "user",
        "profile"
      ],
      "pointer": "/user/profile"
    }
  ],
  "layer": "contract"
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

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "email"
      },
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "username"
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    }
  ],
  "layer": "contract"
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
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "email"
      },
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "username"
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    }
  ],
  "layer": "contract"
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

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "email"
      },
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "username"
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "profile"
      },
      "path": [
        "user",
        "profile"
      ],
      "pointer": "/user/profile"
    }
  ],
  "layer": "contract"
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

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "email"
      },
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "username"
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "posts"
      },
      "path": [
        "user",
        "posts"
      ],
      "pointer": "/user/posts"
    }
  ],
  "layer": "contract"
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

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "email"
      },
      "path": [
        "user",
        "email"
      ],
      "pointer": "/user/email"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "username"
      },
      "path": [
        "user",
        "username"
      ],
      "pointer": "/user/username"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "bio",
          "website"
        ],
        "field": "posts"
      },
      "path": [
        "user",
        "posts"
      ],
      "pointer": "/user/posts"
    }
  ],
  "layer": "contract"
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