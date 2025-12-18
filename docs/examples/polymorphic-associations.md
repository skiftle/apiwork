---
order: 6
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos, images)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/playground/config/apis/gentle_owl.rb

## Models

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

## Schemas

<small>`app/schemas/gentle_owl/post_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/post_schema.rb

<small>`app/schemas/gentle_owl/video_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/video_schema.rb

<small>`app/schemas/gentle_owl/image_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/image_schema.rb

<small>`app/schemas/gentle_owl/comment_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/comment_schema.rb

## Contracts

<small>`app/contracts/gentle_owl/comment_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/comment_contract.rb

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
      "id": "b7290c2f-3f6f-4e31-91fd-323b0ebda93d",
      "body": "Great post!",
      "authorName": "John Doe",
      "createdAt": "2025-12-18T13:21:02.180Z"
    },
    {
      "id": "3731f4ca-fb0f-4a69-afbe-4129fe85c29f",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "createdAt": "2025-12-18T13:21:02.183Z"
    }
  ],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 1,
    "items": 2
  }
}
```

</details>

<details>
<summary>Get comment details</summary>

**Request**

```http
GET /gentle_owl/comments/28f9bd95-565f-4a8c-8e43-afad88c5cddf
```

**Response** `200`

```json
{
  "comment": {
    "id": "28f9bd95-565f-4a8c-8e43-afad88c5cddf",
    "body": "Great post!",
    "authorName": "John Doe",
    "createdAt": "2025-12-18T13:21:02.194Z"
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
    "commentable_id": "06534b7c-aba5-4166-a909-45286495c34e"
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
      "path": [
        "comment",
        "commentable_type"
      ],
      "pointer": "/comment/commentable_type",
      "meta": {
        "field": "commentable_type",
        "allowed": [
          "body",
          "author_name"
        ]
      }
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "comment",
        "commentable_id"
      ],
      "pointer": "/comment/commentable_id",
      "meta": {
        "field": "commentable_id",
        "allowed": [
          "body",
          "author_name"
        ]
      }
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
    "commentable_id": "325e9792-020e-4f7d-9c59-0953538f928b"
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
      "path": [
        "comment",
        "commentable_type"
      ],
      "pointer": "/comment/commentable_type",
      "meta": {
        "field": "commentable_type",
        "allowed": [
          "body",
          "author_name"
        ]
      }
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "comment",
        "commentable_id"
      ],
      "pointer": "/comment/commentable_id",
      "meta": {
        "field": "commentable_id",
        "allowed": [
          "body",
          "author_name"
        ]
      }
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
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "filter"
      ],
      "pointer": "/filter",
      "meta": {
        "field": "filter",
        "allowed": [
          "sort",
          "page",
          "include"
        ]
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