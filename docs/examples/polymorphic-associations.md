---
order: 6
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos, images)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/playground/config/apis/gentle_owl.rb

## Models

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

## Representations

<small>`app/representations/gentle_owl/comment_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/comment_representation.rb

<small>`app/representations/gentle_owl/post_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/post_representation.rb

<small>`app/representations/gentle_owl/video_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/video_representation.rb

<small>`app/representations/gentle_owl/image_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/image_representation.rb

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
      "id": "d1ff1866-6fad-545c-839e-2d972eb5729c",
      "body": "Great post!",
      "authorName": "John Doe",
      "commentableType": "GentleOwl::Post",
      "commentableId": "96988365-65b2-5455-a8a8-491aa772ba47",
      "createdAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "6027b33b-0a17-5c68-bcc1-527ae6105f2c",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "commentableType": "GentleOwl::Video",
      "commentableId": "df4ddc5a-953d-52f5-b5b5-7ddf16fa8f57",
      "createdAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

</details>

<details>
<summary>Get comment details</summary>

**Request**

```http
GET /gentle_owl/comments/b90c16e5-a438-5967-a734-10adf687faa5
```

**Response** `200`

```json
{
  "comment": {
    "id": "b90c16e5-a438-5967-a734-10adf687faa5",
    "body": "Great post!",
    "authorName": "John Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "f8bf7c21-5db9-52b1-bee8-5cb65c03ad75",
    "createdAt": "2024-01-01T12:00:00.000Z"
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
    "commentable_id": "f32a709f-0312-5981-a770-feaf25b51a04"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "dbce7141-50f8-54be-a575-221af6420d0a",
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "f32a709f-0312-5981-a770-feaf25b51a04",
    "createdAt": "2024-01-01T12:00:00.000Z"
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
    "commentable_id": "f78a691a-9f85-54c7-a39d-9f47d579942b"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "993459b6-a155-510a-9f23-be59835d3fee",
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "GentleOwl::Video",
    "commentableId": "f78a691a-9f85-54c7-a39d-9f47d579942b",
    "createdAt": "2024-01-01T12:00:00.000Z"
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
      "id": "050873ac-daa3-53e7-b684-62a96fa68421",
      "body": "Post comment",
      "authorName": "User 1",
      "commentableType": "GentleOwl::Post",
      "commentableId": "53f2f96c-84a9-5d43-a211-bd0081ca6808",
      "createdAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
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