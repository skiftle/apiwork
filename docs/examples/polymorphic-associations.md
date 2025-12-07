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
      "id": "a1a63071-02cd-4c9a-9421-5e2ddd5a2eb7",
      "body": "Great post!",
      "authorName": "John Doe",
      "commentableType": "GentleOwl::Post",
      "commentableId": "0dcc94a6-5875-4cc9-9b55-12af089757f3",
      "createdAt": "2025-12-07T15:57:33.101Z"
    },
    {
      "id": "309d0ca1-a58b-4292-8957-2fe2f50dfbbb",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "commentableType": "GentleOwl::Video",
      "commentableId": "3a52143f-8a15-4414-b785-5d896d5f723a",
      "createdAt": "2025-12-07T15:57:33.102Z"
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
GET /gentle_owl/comments/79c922c2-c69d-42ab-b0c0-b4113c95935d
```

**Response** `200`

```json
{
  "comment": {
    "id": "79c922c2-c69d-42ab-b0c0-b4113c95935d",
    "body": "Great post!",
    "authorName": "John Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "cf28c30a-3fef-4f54-b352-63a450a02079",
    "createdAt": "2025-12-07T15:57:33.113Z"
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
    "commentable_id": "b7b8ca85-e12b-44bb-8ce7-b304fd3f15dc"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "cba29912-36ef-4fd6-a379-04564cc14018",
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "GentleOwl::Post",
    "commentableId": "b7b8ca85-e12b-44bb-8ce7-b304fd3f15dc",
    "createdAt": "2025-12-07T15:57:33.126Z"
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
    "commentable_id": "f8b32503-f71b-400e-9872-a93fe0f934a0"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "37c485ee-7623-48fe-9faf-d3ba86081861",
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "GentleOwl::Video",
    "commentableId": "f8b32503-f71b-400e-9872-a93fe0f934a0",
    "createdAt": "2025-12-07T15:57:33.134Z"
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
      "id": "20d759bd-c58b-4ff3-a932-3099fc4f04c2",
      "body": "Post comment",
      "authorName": "User 1",
      "commentableType": "GentleOwl::Post",
      "commentableId": "ef009f2d-6e42-4652-9667-6ceef60f589f",
      "createdAt": "2025-12-07T15:57:33.139Z"
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