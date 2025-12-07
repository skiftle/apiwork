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

<details>
<summary>Database Schema</summary>

<<< @/app/public/gentle-owl/schema.md

</details>

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
      "id": "50b036f5-d938-4abc-9d69-8929c5d315b6",
      "body": "Great post!",
      "author_name": "John Doe",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "4c90ce4b-f1c8-44f2-9ce7-508d563c27a7",
      "created_at": "2025-12-07T11:20:16.838Z"
    },
    {
      "id": "6b6f9e7a-b2d3-42eb-b5cf-580d42577eba",
      "body": "Helpful video!",
      "author_name": "Jane Doe",
      "commentable_type": "GentleOwl::Video",
      "commentable_id": "f4bb333e-7dd9-4211-8608-90e484dd8929",
      "created_at": "2025-12-07T11:20:16.841Z"
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
GET /gentle-owl/comments/effda81c-f881-45da-abc9-83b4c3e1a966
```

**Response** `200`

```json
{
  "comment": {
    "id": "effda81c-f881-45da-abc9-83b4c3e1a966",
    "body": "Great post!",
    "author_name": "John Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "084f87f1-3545-477b-862b-d4a3ee961da4",
    "created_at": "2025-12-07T11:20:16.851Z"
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
    "commentable_id": "dc57a569-d1dc-4389-a45b-6d629eb5f2d4"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "57701dbe-263d-4f4d-90dc-0a03c4005ae6",
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "dc57a569-d1dc-4389-a45b-6d629eb5f2d4",
    "created_at": "2025-12-07T11:20:16.863Z"
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
    "commentable_id": "b4f6ede3-537e-4cee-98de-8d8808dcce95"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "3ea987cf-61a2-4180-a08e-9a254278bf76",
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "b4f6ede3-537e-4cee-98de-8d8808dcce95",
    "created_at": "2025-12-07T11:20:16.870Z"
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
      "id": "9d2a16d5-f6de-4df3-be85-22b4741d6b8f",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "32e6a3bf-2ac9-4bee-99fd-c6d143aa57e5",
      "created_at": "2025-12-07T11:20:16.876Z"
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