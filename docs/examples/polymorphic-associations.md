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

<details>
<summary>index</summary>

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

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /gentle-owl/comments/326180c7-f431-4d12-a194-daaec734e05a
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

</details>

<details>
<summary>create_post_comment</summary>

**Request**

```http
POST /gentle-owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "a643e32a-7d33-434d-991f-046501458672"
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
<summary>create_video_comment</summary>

**Request**

```http
POST /gentle-owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "72b18ce4-8cc9-4974-aa65-4980aefaf2fd"
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
<summary>filter_by_type</summary>

**Request**

```http
GET /gentle-owl/comments?filter[commentable_type][eq]=GentleOwl::Post
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "3abd0494-3d9b-401d-832a-aeb985fdd100",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "0cf025b5-aa04-4336-86cb-b81f28652f2a",
      "created_at": "2025-12-07T08:42:27.366Z"
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

</details>

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