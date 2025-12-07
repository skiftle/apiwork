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
  "comments": [
    {
      "id": "d1c4147c-8c9b-4f13-a74f-5bffd1d05c37",
      "body": "Great post!",
      "author_name": "John Doe",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "e4e93c95-ebf0-4700-8b75-b8d7a34e444b",
      "created_at": "2025-12-07T10:25:49.022Z"
    },
    {
      "id": "d2fa1a83-a4bd-4249-8e0d-5229e7d32a69",
      "body": "Helpful video!",
      "author_name": "Jane Doe",
      "commentable_type": "GentleOwl::Video",
      "commentable_id": "3c81e7fc-5990-475d-8c1b-b3895096380b",
      "created_at": "2025-12-07T10:25:49.024Z"
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
<summary>show</summary>

**Request**

```http
GET /gentle-owl/comments/4fce397d-e1ce-4f02-8f9d-9f26eb3b2289
```

**Response** `200`

```json
{
  "comment": {
    "id": "4fce397d-e1ce-4f02-8f9d-9f26eb3b2289",
    "body": "Great post!",
    "author_name": "John Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "4331abec-aec2-4d36-ad7b-2a827a0f13cc",
    "created_at": "2025-12-07T10:25:49.033Z"
  }
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
    "commentable_id": "2a0548ec-7001-4c7b-85e0-0bc139cac061"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "3c926d7e-0870-4205-b8b2-b35fe05e1a05",
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "2a0548ec-7001-4c7b-85e0-0bc139cac061",
    "created_at": "2025-12-07T10:25:49.045Z"
  }
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
    "commentable_id": "b71841be-03ac-45fe-8553-5d657e4e8a05"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "8d8c5e0e-74c1-4e34-9d54-9f30ccb06dc0",
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "b71841be-03ac-45fe-8553-5d657e4e8a05",
    "created_at": "2025-12-07T10:25:49.053Z"
  }
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
      "id": "e53c2f3f-206b-4e69-8ddd-3b7b9f3c9cdc",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "19e18dc9-794d-4a04-a274-96d7df0fdf30",
      "created_at": "2025-12-07T10:25:49.059Z"
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