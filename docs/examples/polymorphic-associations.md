---
order: 6
---

# Polymorphic Associations

Comments that belong to different content types (posts, videos, images)

## API Definition

<small>`config/apis/gentle_owl.rb`</small>

<<< @/playground/config/apis/gentle_owl.rb

## Models

<small>`app/models/gentle_owl/post.rb`</small>

<<< @/playground/app/models/gentle_owl/post.rb

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

<<< @/playground/app/models/gentle_owl/video.rb

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

<<< @/playground/app/models/gentle_owl/image.rb

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

<<< @/playground/app/models/gentle_owl/comment.rb

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

<<< @/playground/app/schemas/gentle_owl/post_schema.rb

<small>`app/schemas/gentle_owl/video_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/video_schema.rb

<small>`app/schemas/gentle_owl/image_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/image_schema.rb

<small>`app/schemas/gentle_owl/comment_schema.rb`</small>

<<< @/playground/app/schemas/gentle_owl/comment_schema.rb

## Contracts

<small>`app/contracts/gentle_owl/comment_contract.rb`</small>

<<< @/playground/app/contracts/gentle_owl/comment_contract.rb

## Controllers

<small>`app/controllers/gentle_owl/comments_controller.rb`</small>

<<< @/playground/app/controllers/gentle_owl/comments_controller.rb

---

## How It Works

The `belongs_to :commentable, polymorphic: [...]` declaration tells Apiwork to:

1. Generate a **discriminated union type** for the association
2. Allow **including** the associated record via `?include[commentable]=true`
3. Automatically resolve the correct schema based on `commentable_type`

## Request Examples

<details>
<summary>List comments with polymorphic association included</summary>

**Request**

```http
GET /gentle_owl/comments?include[commentable]=true
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "abc123",
      "body": "Great post!",
      "authorName": "John Doe",
      "createdAt": "2025-12-10T10:35:26.529Z",
      "commentable": {
        "commentableType": "Post",
        "id": "post-1",
        "title": "Hello World",
        "body": "Welcome to my blog..."
      }
    },
    {
      "id": "def456",
      "body": "Nice video!",
      "authorName": "Jane Doe",
      "createdAt": "2025-12-10T10:35:26.532Z",
      "commentable": {
        "commentableType": "Video",
        "id": "video-1",
        "title": "Tutorial",
        "url": "https://example.com/video.mp4",
        "duration": 120
      }
    },
    {
      "id": "ghi789",
      "body": "Beautiful image!",
      "authorName": "Bob Smith",
      "createdAt": "2025-12-10T10:35:26.535Z",
      "commentable": {
        "commentableType": "Image",
        "id": "image-1",
        "title": "Sunset",
        "url": "https://example.com/sunset.jpg",
        "width": 1920,
        "height": 1080
      }
    }
  ],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 1,
    "items": 3
  }
}
```

Note how each `commentable` object includes a `commentableType` discriminator field that identifies the type.

</details>

<details>
<summary>Get single comment with polymorphic association</summary>

**Request**

```http
GET /gentle_owl/comments/abc123?include[commentable]=true
```

**Response** `200`

```json
{
  "comment": {
    "id": "abc123",
    "body": "Great post!",
    "authorName": "John Doe",
    "createdAt": "2025-12-10T10:35:26.543Z",
    "commentable": {
      "commentableType": "Post",
      "id": "post-1",
      "title": "Hello World",
      "body": "Welcome to my blog..."
    }
  }
}
```

</details>

<details>
<summary>List comments without include (association omitted)</summary>

**Request**

```http
GET /gentle_owl/comments
```

**Response** `200`

```json
{
  "comments": [
    {
      "id": "abc123",
      "body": "Great post!",
      "authorName": "John Doe",
      "createdAt": "2025-12-10T10:35:26.529Z"
    },
    {
      "id": "def456",
      "body": "Nice video!",
      "authorName": "Jane Doe",
      "createdAt": "2025-12-10T10:35:26.532Z"
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

Without `include[commentable]=true`, the polymorphic association is not included in the response.

</details>

## Generated TypeScript

The polymorphic association generates a **discriminated union type**:

```typescript
export type CommentCommentable =
  | { commentableType: 'post' } & Post
  | { commentableType: 'video' } & Video
  | { commentableType: 'image' } & Image;

export interface Comment {
  id?: unknown;
  body?: string;
  authorName?: string;
  createdAt?: string;
  commentable?: CommentCommentable;
}
```

This allows TypeScript to narrow the type based on `commentableType`:

```typescript
function handleComment(comment: Comment) {
  if (comment.commentable?.commentableType === 'post') {
    // TypeScript knows this is a Post
    console.log(comment.commentable.title, comment.commentable.body);
  } else if (comment.commentable?.commentableType === 'video') {
    // TypeScript knows this is a Video
    console.log(comment.commentable.url, comment.commentable.duration);
  }
}
```

## Limitations

Polymorphic associations have restrictions:

| Feature | Supported | Reason |
|---------|-----------|--------|
| `include` | ✓ | Works with discriminated unions |
| `writable` | ✗ | Rails doesn't support nested attributes for polymorphic |
| `filterable` | ✗ | Cannot JOIN across multiple tables |
| `sortable` | ✗ | Cannot JOIN across multiple tables |

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