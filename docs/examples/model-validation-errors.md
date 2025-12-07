---
order: 7
---

# Model Validation Errors

How Apiwork captures ActiveRecord validation errors and presents them in a unified format

## API Definition

<small>`config/apis/happy_zebra.rb`</small>

<<< @/app/config/apis/happy_zebra.rb

## Models

<small>`app/models/happy_zebra/profile.rb`</small>

<<< @/app/app/models/happy_zebra/profile.rb

<small>`app/models/happy_zebra/user.rb`</small>

<<< @/app/app/models/happy_zebra/user.rb

## Schemas

<small>`app/schemas/happy_zebra/profile_schema.rb`</small>

<<< @/app/app/schemas/happy_zebra/profile_schema.rb

<small>`app/schemas/happy_zebra/user_schema.rb`</small>

<<< @/app/app/schemas/happy_zebra/user_schema.rb

## Contracts

<small>`app/contracts/happy_zebra/user_contract.rb`</small>

<<< @/app/app/contracts/happy_zebra/user_contract.rb

## Controllers

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
    "id": "287e842a-8920-4625-a5a6-bd06bdb37b22",
    "created_at": "2025-12-07T09:46:47.401Z",
    "updated_at": "2025-12-07T09:46:47.401Z",
    "email": "john@example.com",
    "username": "johndoe",
    "profile": null
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