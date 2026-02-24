---
order: 6
---

# Includes

Load associations on demand with include query parameters

## API Definition

<small>`config/apis/loyal_hound.rb`</small>

<<< @/playground/config/apis/loyal_hound.rb

## Models

<small>`app/models/loyal_hound/author.rb`</small>

<<< @/playground/app/models/loyal_hound/author.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/loyal_hound/book.rb`</small>

<<< @/playground/app/models/loyal_hound/book.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| author_id | string |  |  |
| created_at | datetime |  |  |
| published_on | date | ✓ |  |
| title | string |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/loyal_hound/review.rb`</small>

<<< @/playground/app/models/loyal_hound/review.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| body | text | ✓ |  |
| book_id | string |  |  |
| created_at | datetime |  |  |
| rating | integer |  |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/loyal_hound/book_representation.rb`</small>

<<< @/playground/app/representations/loyal_hound/book_representation.rb

<small>`app/representations/loyal_hound/author_representation.rb`</small>

<<< @/playground/app/representations/loyal_hound/author_representation.rb

<small>`app/representations/loyal_hound/review_representation.rb`</small>

<<< @/playground/app/representations/loyal_hound/review_representation.rb

## Contracts

<small>`app/contracts/loyal_hound/book_contract.rb`</small>

<<< @/playground/app/contracts/loyal_hound/book_contract.rb

## Controllers

<small>`app/controllers/loyal_hound/books_controller.rb`</small>

<<< @/playground/app/controllers/loyal_hound/books_controller.rb

## Request Examples

::: details List without includes

**Request**

```http
GET /loyal_hound/books
```

**Response** `200`

```json
{
  "books": [
    {
      "id": "85b98b2f-99ee-554a-90ea-b7894ab980dc",
      "title": "Pride and Prejudice",
      "publishedOn": "1813-01-28",
      "authorId": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "54317f80-8b94-5a49-8235-e05c73330abc",
      "title": "Sense and Sensibility",
      "publishedOn": "1811-10-30",
      "authorId": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
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

::: details Include author

**Request**

```http
GET /loyal_hound/books?include[author]=true
```

**Response** `200`

```json
{
  "books": [
    {
      "id": "85b98b2f-99ee-554a-90ea-b7894ab980dc",
      "title": "Pride and Prejudice",
      "publishedOn": "1813-01-28",
      "authorId": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "author": {
        "id": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
        "name": "Jane Austen"
      }
    },
    {
      "id": "54317f80-8b94-5a49-8235-e05c73330abc",
      "title": "Sense and Sensibility",
      "publishedOn": "1811-10-30",
      "authorId": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "author": {
        "id": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
        "name": "Jane Austen"
      }
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

::: details Include reviews

**Request**

```http
GET /loyal_hound/books?include[reviews]=true
```

**Response** `200`

```json
{
  "books": [
    {
      "id": "85b98b2f-99ee-554a-90ea-b7894ab980dc",
      "title": "Pride and Prejudice",
      "publishedOn": "1813-01-28",
      "authorId": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "reviews": [
        {
          "id": "6865e56a-0f49-5318-85dc-dc3942d92649",
          "rating": 5,
          "body": "A timeless classic"
        },
        {
          "id": "e56dbc23-e351-57f2-808e-651847b3d1c5",
          "rating": 4,
          "body": "Beautifully written"
        }
      ]
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

::: details Include both

**Request**

```http
GET /loyal_hound/books?include[author]=true&include[reviews]=true
```

**Response** `200`

```json
{
  "books": [
    {
      "id": "85b98b2f-99ee-554a-90ea-b7894ab980dc",
      "title": "Pride and Prejudice",
      "publishedOn": "1813-01-28",
      "authorId": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "author": {
        "id": "c9449e5d-d293-54b7-bbeb-3e1dd9682274",
        "name": "Jane Austen"
      },
      "reviews": [
        {
          "id": "6865e56a-0f49-5318-85dc-dc3942d92649",
          "rating": 5,
          "body": "A timeless classic"
        }
      ]
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

::: details Show with includes

**Request**

```http
GET /loyal_hound/books/e56dbc23-e351-57f2-808e-651847b3d1c5?include[author]=true&include[reviews]=true
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/loyal-hound/introspection.json

:::

::: details TypeScript

<<< @/playground/public/loyal-hound/typescript.ts

:::

::: details Zod

<<< @/playground/public/loyal-hound/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/loyal-hound/openapi.yml

:::