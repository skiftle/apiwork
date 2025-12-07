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

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| commentable_type | string |  |  |
| commentable_id | string |  |  |
| body | text |  |  |
| author_name | string | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/gentle_owl/image.rb`</small>

<<< @/app/app/models/gentle_owl/image.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| title | string |  |  |
| url | string |  |  |
| width | integer | ✓ |  |
| height | integer | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/gentle_owl/post.rb`</small>

<<< @/app/app/models/gentle_owl/post.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| title | string |  |  |
| body | text | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/gentle_owl/video.rb`</small>

<<< @/app/app/models/gentle_owl/video.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| title | string |  |  |
| url | string |  |  |
| duration | integer | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

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
      "id": "ef42197f-7a37-4a4f-bcf7-c0026bb79d3c",
      "body": "Great post!",
      "authorName": "John Doe",
      "commentableType": "GentleOwl::Post",
      "commentableId": "143e43a0-2b7e-459e-87d1-f19e815e2d61",
      "createdAt": "2025-12-07T13:31:00.072Z"
    },
    {
      "id": "8dfa777b-0487-4709-9645-8d7f5cd7f3b7",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "commentableType": "GentleOwl::Video",
      "commentableId": "8e67a114-d621-4447-9f57-4640f0781f8b",
      "createdAt": "2025-12-07T13:31:00.076Z"
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
GET /gentle_owl/comments/0ff7d0cc-91f3-4a88-b6d5-d9d872c347b6
```

**Response** `200`

```json
{
  "comment": {
    "id": "0ff7d0cc-91f3-4a88-b6d5-d9d872c347b6",
    "body": "Great post!",
    "authorName": "John Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "4c2eb728-25ac-44e9-a6a6-0c7f906b55bf",
    "createdAt": "2025-12-07T13:31:00.097Z"
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
    "commentable_id": "d8271368-6bd8-4f12-b305-ce496ff521c9"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "37c43298-1db5-438c-842c-0f26ccb4fbc6",
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "d8271368-6bd8-4f12-b305-ce496ff521c9",
    "createdAt": "2025-12-07T13:31:00.124Z"
  }
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
    "commentable_id": "547d2dc4-164a-4657-b495-25e156da0c08"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "88c349ad-a07e-439c-aa01-8df9f382c2fe",
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "GentleOwl::Video",
    "commentableId": "547d2dc4-164a-4657-b495-25e156da0c08",
    "createdAt": "2025-12-07T13:31:00.142Z"
  }
}
```

</details>

<details>
<summary>Filter by content type</summary>

**Request**

```http
GET /gentle_owl/comments?filter[commentable_type][eq]=GentleOwl::Post
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "cb561ac6-bba8-4a25-925b-90e2431c8c22",
      "body": "Post comment",
      "authorName": "User 1",
      "commentableType": "GentleOwl::Post",
      "commentableId": "3e2d983d-f52c-4eb9-92e6-cebe2ffe5ba1",
      "createdAt": "2025-12-07T13:31:00.155Z"
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