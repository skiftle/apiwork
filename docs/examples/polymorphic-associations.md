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
GET /gentle-owl/comments
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "51c6047b-e3af-4680-a015-ed9f7dd65af4",
      "body": "Great post!",
      "author_name": "John Doe",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "da1202c6-b87b-4d73-9b0e-aa5d3af9542b",
      "created_at": "2025-12-07T12:02:58.009Z"
    },
    {
      "id": "72488de5-7018-46d0-b052-237123c0e46d",
      "body": "Helpful video!",
      "author_name": "Jane Doe",
      "commentable_type": "GentleOwl::Video",
      "commentable_id": "ee979791-d06e-4b95-9385-1f07ab300781",
      "created_at": "2025-12-07T12:02:58.011Z"
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
GET /gentle-owl/comments/dbfa4ac6-9566-40d2-a90d-7734fedd2f73
```

**Response** `200`

```json
{
  "comment": {
    "id": "dbfa4ac6-9566-40d2-a90d-7734fedd2f73",
    "body": "Great post!",
    "author_name": "John Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "649fc36e-4bc3-4dbc-8e3f-6a393375f551",
    "created_at": "2025-12-07T12:02:58.020Z"
  }
}
```

</details>

<details>
<summary>Create comment on post</summary>

**Request**

```http
POST /gentle-owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "cde2a9b7-80fd-4b6a-9de3-c02e0a0c776a"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "71a23e8e-b19c-4f3f-9d0f-3715be9862d0",
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "cde2a9b7-80fd-4b6a-9de3-c02e0a0c776a",
    "created_at": "2025-12-07T12:02:58.031Z"
  }
}
```

</details>

<details>
<summary>Create comment on video</summary>

**Request**

```http
POST /gentle-owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "34d5ba8c-bc1f-46de-91a7-d704d8fe97fd"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "eeffcda4-8e72-4a1c-8f59-b99ada4cd187",
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "34d5ba8c-bc1f-46de-91a7-d704d8fe97fd",
    "created_at": "2025-12-07T12:02:58.039Z"
  }
}
```

</details>

<details>
<summary>Filter by content type</summary>

**Request**

```http
GET /gentle-owl/comments?filter[commentable_type][eq]=GentleOwl::Post
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "5a8049b8-fd7b-4387-a85b-6f59fc3b9956",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "120421e9-eb9d-4dd3-8df9-961ac1e04868",
      "created_at": "2025-12-07T12:02:58.044Z"
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