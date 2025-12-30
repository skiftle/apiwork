---
order: 6
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos, images)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/playground/config/apis/gentle_owl.rb

## Models

<small>`app/models/gentle_owl/comment.rb`</small>

<<< @/playground/app/models/gentle_owl/comment.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| author_name | string | ✓ |  |
| body | text |  |  |
| commentable_id | string |  |  |
| commentable_type | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/gentle_owl/post.rb`</small>

<<< @/playground/app/models/gentle_owl/post.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| body | text | ✓ |  |
| created_at | datetime |  |  |
| title | string |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/gentle_owl/video.rb`</small>

<<< @/playground/app/models/gentle_owl/video.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| duration | integer | ✓ |  |
| title | string |  |  |
| updated_at | datetime |  |  |
| url | string |  |  |

</details>

<small>`app/models/gentle_owl/image.rb`</small>

<<< @/playground/app/models/gentle_owl/image.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| height | integer | ✓ |  |
| title | string |  |  |
| updated_at | datetime |  |  |
| url | string |  |  |
| width | integer | ✓ |  |

</details>

## Schemas

<small>`app/schemas/gentle_owl/comment_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/comment_schema.rb

<small>`app/schemas/gentle_owl/post_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/post_schema.rb

<small>`app/schemas/gentle_owl/video_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/video_schema.rb

<small>`app/schemas/gentle_owl/image_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/image_schema.rb

## Contracts

<small>`app/contracts/gentle_owl/comment_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/comment_contract.rb

<small>`app/contracts/gentle_owl/post_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/post_contract.rb

<small>`app/contracts/gentle_owl/video_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/video_contract.rb

<small>`app/contracts/gentle_owl/image_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/image_contract.rb

## Controllers

<small>`app/controllers/gentle_owl/comments_controller.rb`</small>

<<< @/playground/app/controllers/gentle_owl/comments_controller.rb

---



## Request Examples

<details>
<summary>List all comments</summary>

**Request**

```http
GET /gentle_owl/comments
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "d1ff1866-6fad-545c-839e-2d972eb5729c",
      "body": "Great post!",
      "authorName": "John Doe",
      "createdAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "6027b33b-0a17-5c68-bcc1-527ae6105f2c",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "createdAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

</details>

<details>
<summary>Get comment details</summary>

**Request**

```http
GET /gentle_owl/comments/b90c16e5-a438-5967-a734-10adf687faa5
```

**Response** `200`

```json
{
  "comment": {
    "id": "b90c16e5-a438-5967-a734-10adf687faa5",
    "body": "Great post!",
    "authorName": "John Doe",
    "createdAt": "2024-01-01T12:00:00.000Z"
  }
}
```

</details>

<details>
<summary>Create comment on post</summary>

**Request**

```http
POST /gentle_owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "f32a709f-0312-5981-a770-feaf25b51a04"
  }
}
```

**Response** `400`

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "body",
          "author_name"
        ],
        "field": "commentable_type"
      },
      "path": [
        "comment",
        "commentable_type"
      ],
      "pointer": "/comment/commentable_type"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "body",
          "author_name"
        ],
        "field": "commentable_id"
      },
      "path": [
        "comment",
        "commentable_id"
      ],
      "pointer": "/comment/commentable_id"
    }
  ]
}
```

</details>

<details>
<summary>Create comment on video</summary>

**Request**

```http
POST /gentle_owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "f78a691a-9f85-54c7-a39d-9f47d579942b"
  }
}
```

**Response** `400`

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "body",
          "author_name"
        ],
        "field": "commentable_type"
      },
      "path": [
        "comment",
        "commentable_type"
      ],
      "pointer": "/comment/commentable_type"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "body",
          "author_name"
        ],
        "field": "commentable_id"
      },
      "path": [
        "comment",
        "commentable_id"
      ],
      "pointer": "/comment/commentable_id"
    }
  ]
}
```

</details>

<details>
<summary>Filter by content type</summary>

**Request**

```http
GET /gentle_owl/comments?filter[commentable_type][eq]=GentleOwl::Post
```

**Response** `400`

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [
          "sort",
          "page",
          "include"
        ],
        "field": "filter"
      },
      "path": [
        "filter"
      ],
      "pointer": "/filter"
    }
  ]
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/gentle-owl/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/gentle-owl/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/gentle-owl/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/gentle-owl/openapi.yml

</details>