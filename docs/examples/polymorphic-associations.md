---
order: 6
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos, images)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/app/config/apis/gentle_owl.rb

## Models

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

## Schemas

<small>`app/schemas/gentle_owl/post_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/post_schema.rb

<small>`app/schemas/gentle_owl/video_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/video_schema.rb

<small>`app/schemas/gentle_owl/image_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/image_schema.rb

<small>`app/schemas/gentle_owl/comment_schema.rb`</small>

<<< @/app/app/schemas/gentle_owl/comment_schema.rb

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
      "id": "cc30eb64-48a1-406d-9d3f-ef61374275ee",
      "body": "Great post!",
      "authorName": "John Doe",
      "commentableType": "GentleOwl::Post",
      "commentableId": "7d3fe100-309a-4e96-97a0-4e954eb65fb0",
      "createdAt": "2025-12-07T16:39:26.121Z"
    },
    {
      "id": "dcda03f5-9dca-40d3-9d24-d759f3eb2373",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "commentableType": "GentleOwl::Video",
      "commentableId": "414d68ba-81b7-45a2-9433-f55bbc0181ad",
      "createdAt": "2025-12-07T16:39:26.123Z"
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
GET /gentle_owl/comments/4a41c600-81b0-471f-80d7-45fd01483814
```

**Response** `200`

```json
{
  "comment": {
    "id": "4a41c600-81b0-471f-80d7-45fd01483814",
    "body": "Great post!",
    "authorName": "John Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "bf892321-73c7-4870-9b59-b334b6d25573",
    "createdAt": "2025-12-07T16:39:26.133Z"
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
    "commentable_id": "57156b43-f472-4349-8d3b-1ef3baf66583"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "d8c364ae-1459-45af-892b-c8ea8df3ca22",
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "57156b43-f472-4349-8d3b-1ef3baf66583",
    "createdAt": "2025-12-07T16:39:26.144Z"
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
    "commentable_id": "34db88e4-ce89-4e48-a918-341192ab3fd3"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "593e03e5-abfe-456c-ba84-760be6e14b8e",
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "GentleOwl::Video",
    "commentableId": "34db88e4-ce89-4e48-a918-341192ab3fd3",
    "createdAt": "2025-12-07T16:39:26.152Z"
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
      "id": "c379ccc1-0f43-489b-9424-f18fbaacb620",
      "body": "Post comment",
      "authorName": "User 1",
      "commentableType": "GentleOwl::Post",
      "commentableId": "4d530df0-b20e-49ad-bc25-98620caeef0e",
      "createdAt": "2025-12-07T16:39:26.157Z"
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