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
      "id": "3c2ea8e3-e3b8-49ba-9bdb-651a6595d689",
      "body": "Great post!",
      "authorName": "John Doe",
      "commentableType": "GentleOwl::Post",
      "commentableId": "e0b2f592-3fbf-473f-9153-a69c9586ab64",
      "createdAt": "2025-12-07T17:09:09.854Z"
    },
    {
      "id": "c02efb9c-5f6b-429f-9394-ab6eeff4e4ef",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "commentableType": "GentleOwl::Video",
      "commentableId": "e73cd431-eaf4-420a-b614-6c39bf4d3993",
      "createdAt": "2025-12-07T17:09:09.857Z"
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
GET /gentle_owl/comments/a07a684f-eb67-4672-ac95-cb5943324fd4
```

**Response** `200`

```json
{
  "comment": {
    "id": "a07a684f-eb67-4672-ac95-cb5943324fd4",
    "body": "Great post!",
    "authorName": "John Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "485343fc-962d-4085-86f2-7bb018c0c125",
    "createdAt": "2025-12-07T17:09:09.870Z"
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
    "commentable_id": "07555071-8423-488e-abd9-28c06f29909c"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "7e5f2791-8989-4575-8542-8705551d57cc",
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "07555071-8423-488e-abd9-28c06f29909c",
    "createdAt": "2025-12-07T17:09:09.884Z"
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
    "commentable_id": "4339187f-37c6-4f89-aa68-65073406356b"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "e3f78c99-22e0-44ad-90f2-98a4377697ed",
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "GentleOwl::Video",
    "commentableId": "4339187f-37c6-4f89-aa68-65073406356b",
    "createdAt": "2025-12-07T17:09:09.894Z"
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
      "id": "a0b2038a-7d98-4b0d-8d06-541a4faa4eb2",
      "body": "Post comment",
      "authorName": "User 1",
      "commentableType": "GentleOwl::Post",
      "commentableId": "c4daf061-02ef-417f-9eb6-6b684bab41dc",
      "createdAt": "2025-12-07T17:09:09.899Z"
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