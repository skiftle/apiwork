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
      "id": "02d84bfd-e733-435b-8ee7-09cb35f25913",
      "body": "Great post!",
      "author_name": "John Doe",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "1e8dfb54-d3b4-4aea-9ac5-11a31c2bdbb6",
      "created_at": "2025-12-07T11:45:01.468Z"
    },
    {
      "id": "c26f2209-a27a-4564-b6cc-ddcc0c206980",
      "body": "Helpful video!",
      "author_name": "Jane Doe",
      "commentable_type": "GentleOwl::Video",
      "commentable_id": "cb322209-00b2-43c9-ae5c-248e78a39595",
      "created_at": "2025-12-07T11:45:01.470Z"
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
GET /gentle-owl/comments/9e8b51fd-b620-4af1-a624-a74109f8854b
```

**Response** `200`

```json
{
  "comment": {
    "id": "9e8b51fd-b620-4af1-a624-a74109f8854b",
    "body": "Great post!",
    "author_name": "John Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "2c44d9ec-e37c-48a0-acfa-6c58c8708c92",
    "created_at": "2025-12-07T11:45:01.482Z"
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
    "commentable_id": "838155b7-6b6d-4570-8175-d5095377e135"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "2a9f044a-cec3-4ffa-8388-a638538cdc52",
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "838155b7-6b6d-4570-8175-d5095377e135",
    "created_at": "2025-12-07T11:45:01.495Z"
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
    "commentable_id": "295907f8-ac94-45ff-aeb1-1a387c521155"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "c84d3378-cc85-4395-9fc1-206666f45e66",
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "295907f8-ac94-45ff-aeb1-1a387c521155",
    "created_at": "2025-12-07T11:45:01.508Z"
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
      "id": "1ebb1e11-0691-46f3-8e76-d423575e9206",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "9f76419b-56c5-48e6-a163-8bee8bd3d5c9",
      "created_at": "2025-12-07T11:45:01.515Z"
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