---
order: 10
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/playground/config/apis/gentle_owl.rb

## Models

<small>`app/models/gentle_owl/comment.rb`</small>

<<< @/playground/app/models/gentle_owl/comment.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| author_name | string | ✓ |  |
| body | text |  |  |
| commentable_id | string |  |  |
| commentable_type | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/gentle_owl/post.rb`</small>

<<< @/playground/app/models/gentle_owl/post.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| body | text | ✓ |  |
| created_at | datetime |  |  |
| title | string |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/gentle_owl/video.rb`</small>

<<< @/playground/app/models/gentle_owl/video.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| duration | integer | ✓ |  |
| title | string |  |  |
| updated_at | datetime |  |  |
| url | string |  |  |

:::

## Representations

<small>`app/representations/gentle_owl/comment_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/comment_representation.rb

<small>`app/representations/gentle_owl/post_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/post_representation.rb

<small>`app/representations/gentle_owl/video_representation.rb`</small>

<<< @/playground/app/representations/gentle_owl/video_representation.rb

## Contracts

<small>`app/contracts/gentle_owl/comment_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/comment_contract.rb

## Controllers

<small>`app/controllers/gentle_owl/comments_controller.rb`</small>

<<< @/playground/app/controllers/gentle_owl/comments_controller.rb

## Request Examples

::: details List all comments

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
      "commentableType": "post",
      "commentableId": "96988365-65b2-5455-a8a8-491aa772ba47",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "6027b33b-0a17-5c68-bcc1-527ae6105f2c",
      "body": "Helpful video!",
      "authorName": "Jane Doe",
      "commentableType": "video",
      "commentableId": "df4ddc5a-953d-52f5-b5b5-7ddf16fa8f57",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
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

:::

::: details Get comment details

**Request**

```http
GET /gentle_owl/comments/d1ff1866-6fad-545c-839e-2d972eb5729c
```

**Response** `200`

```json
{
  "comment": {
    "id": "d1ff1866-6fad-545c-839e-2d972eb5729c",
    "body": "Great post!",
    "authorName": "John Doe",
    "commentableType": "post",
    "commentableId": "96988365-65b2-5455-a8a8-491aa772ba47",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Create comment on post

**Request**

```http
POST /gentle_owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "post",
    "commentableId": "96988365-65b2-5455-a8a8-491aa772ba47"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "d1ff1866-6fad-545c-839e-2d972eb5729c",
    "body": "This is a great article!",
    "authorName": "Jane Doe",
    "commentableType": "post",
    "commentableId": "96988365-65b2-5455-a8a8-491aa772ba47",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Create comment on video

**Request**

```http
POST /gentle_owl/comments
Content-Type: application/json

{
  "comment": {
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "video",
    "commentableId": "df4ddc5a-953d-52f5-b5b5-7ddf16fa8f57"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "d1ff1866-6fad-545c-839e-2d972eb5729c",
    "body": "Very helpful video!",
    "authorName": "Bob Smith",
    "commentableType": "video",
    "commentableId": "df4ddc5a-953d-52f5-b5b5-7ddf16fa8f57",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Filter by content type

**Request**

```http
GET /gentle_owl/comments?filter[commentableType][eq]=post
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "d1ff1866-6fad-545c-839e-2d972eb5729c",
      "body": "Post comment",
      "authorName": "User 1",
      "commentableType": "post",
      "commentableId": "96988365-65b2-5455-a8a8-491aa772ba47",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
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

:::

## Generated Output

::: details Introspection

<<< @/playground/public/gentle-owl/introspection.json

:::

::: details TypeScript

<<< @/playground/public/gentle-owl/typescript.ts

:::

::: details Zod

<<< @/playground/public/gentle-owl/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/gentle-owl/openapi.yml

:::