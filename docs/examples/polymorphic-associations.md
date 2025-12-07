---
order: 6
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos, images)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/app/config/apis/gentle_owl.rb

## Models

<small>`app/models/gentle_owl/comment.rb`</small>

<<< @/app/app/models/gentle_owl/comment.rb

<small>`app/models/gentle_owl/image.rb`</small>

<<< @/app/app/models/gentle_owl/image.rb

<small>`app/models/gentle_owl/post.rb`</small>

<<< @/app/app/models/gentle_owl/post.rb

<small>`app/models/gentle_owl/video.rb`</small>

<<< @/app/app/models/gentle_owl/video.rb

## Schemas

<small>`app/schemas/gentle_owl/comment_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/comment_schema.rb

<small>`app/schemas/gentle_owl/image_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/image_schema.rb

<small>`app/schemas/gentle_owl/post_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/post_schema.rb

<small>`app/schemas/gentle_owl/video_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/video_schema.rb

## Contracts

<small>`app/contracts/gentle_owl/comment_contract.rb`</small>

<<< @/app/app/contracts/gentle_owl/comment_contract.rb

## Controllers

<small>`app/controllers/gentle_owl/comments_controller.rb`</small>

<<< @/app/app/controllers/gentle_owl/comments_controller.rb

---



## Request Examples

### Index

**Request**

```http
GET /gentle-owl/comments
```

**Response** `200`

```json
{
  "comments": [],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 0,
    "items": 0
  }
}
```

### Show

**Request**

```http
GET /gentle-owl/comments/9bbd58a9-045d-4dda-9457-f8191e6f027c
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

### Create Post Comment

**Request**

```http
POST /gentle-owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "62c2505c-5a4f-4ed6-8456-1601afc9d8dd"
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

### Create Video Comment

**Request**

```http
POST /gentle-owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "2f2844d5-b84f-48dc-8093-f47dcf477fb3"
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

### Filter By Type

**Request**

```http
GET /gentle-owl/comments?filter[commentable_type][eq]=GentleOwl::Post
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "f326a119-c907-4e27-b15d-e13d722d9cf8",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "76cdf1e9-38c5-40cb-9104-0e92145dd47b",
      "created_at": "2025-12-07T08:33:55.881Z"
    }
  ],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 1,
    "items": 1
  }
}
```

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/gentle-owl/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/gentle-owl/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/gentle-owl/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/gentle-owl/openapi.yml

</details>