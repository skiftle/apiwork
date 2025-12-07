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
      "id": "804efe08-7a04-4ebb-8c65-73ebffa8794c",
      "body": "Great post!",
      "author_name": "John Doe",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "fd02106b-4416-443b-ad50-745c58c01689",
      "created_at": "2025-12-07T09:01:01.322Z"
    },
    {
      "id": "68e114f2-fc9f-48ad-beaf-0dc272a4742a",
      "body": "Helpful video!",
      "author_name": "Jane Doe",
      "commentable_type": "GentleOwl::Video",
      "commentable_id": "61189863-affa-4555-bb5a-b4dbb405b3e7",
      "created_at": "2025-12-07T09:01:01.324Z"
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
GET /gentle-owl/comments/4e3d8bba-dd1d-4933-984c-03a46e22443f
```

**Response** `200`

```json
{
  "comment": {
    "id": "4e3d8bba-dd1d-4933-984c-03a46e22443f",
    "body": "Great post!",
    "author_name": "John Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "8a091178-9497-471b-97b6-95a9a8c19f3d",
    "created_at": "2025-12-07T09:01:01.333Z"
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
    "commentable_id": "3f487da4-36b0-4519-86f4-119476c551cd"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "9fefbc21-95db-4407-a65d-a8fa06093315",
    "body": "This is a great article!",
    "author_name": "Jane Doe",
    "commentable_type": "GentleOwl::Post",
    "commentable_id": "3f487da4-36b0-4519-86f4-119476c551cd",
    "created_at": "2025-12-07T09:01:01.343Z"
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
    "commentable_id": "e12c8b13-499b-4538-a7a9-50ec2ad5787c"
  }
}
```

**Response** `201`

```json
{
  "comment": {
    "id": "ec16f2bc-6429-4a82-a743-883debe89be1",
    "body": "Very helpful video!",
    "author_name": "Bob Smith",
    "commentable_type": "GentleOwl::Video",
    "commentable_id": "e12c8b13-499b-4538-a7a9-50ec2ad5787c",
    "created_at": "2025-12-07T09:01:01.350Z"
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
      "id": "db7d2db2-8b5f-4cf7-9740-eeb1b65c0e19",
      "body": "Post comment",
      "author_name": "User 1",
      "commentable_type": "GentleOwl::Post",
      "commentable_id": "aaffaeb9-64b9-4ae6-9e5e-39e0194ff2a2",
      "created_at": "2025-12-07T09:01:01.355Z"
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