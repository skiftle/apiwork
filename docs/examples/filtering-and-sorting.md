---
order: 3
---

# Filtering and Sorting

Complex queries with string patterns, numeric ranges, and logical operators

## API Definition

<small>`config/apis/bold_falcon.rb`</small>

<<< @/playground/config/apis/bold_falcon.rb

## Models

<small>`app/models/bold_falcon/article.rb`</small>

<<< @/playground/app/models/bold_falcon/article.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| body | text | ✓ |  |
| category_id | string | ✓ |  |
| created_at | datetime |  |  |
| published_on | date | ✓ |  |
| rating | decimal | ✓ |  |
| status | integer |  | 0 |
| title | string |  |  |
| updated_at | datetime |  |  |
| view_count | integer | ✓ | 0 |

:::

<small>`app/models/bold_falcon/category.rb`</small>

<<< @/playground/app/models/bold_falcon/category.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| slug | string |  |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/bold_falcon/article_representation.rb`</small>

<<< @/playground/app/representations/bold_falcon/article_representation.rb

<small>`app/representations/bold_falcon/category_representation.rb`</small>

<<< @/playground/app/representations/bold_falcon/category_representation.rb

## Contracts

<small>`app/contracts/bold_falcon/article_contract.rb`</small>

<<< @/playground/app/contracts/bold_falcon/article_contract.rb

## Controllers

<small>`app/controllers/bold_falcon/articles_controller.rb`</small>

<<< @/playground/app/controllers/bold_falcon/articles_controller.rb

## Request Examples

::: details Filter by status

**Request**

```http
GET /bold_falcon/articles?filter[status][eq]=published
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
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

::: details Filter by title pattern

**Request**

```http
GET /bold_falcon/articles?filter[title][contains]=Rails
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
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

::: details Sort by date

**Request**

```http
GET /bold_falcon/articles?sort[published_on]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "66187cb1-6c7d-57b9-95bb-6de6ad564dad",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
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

::: details Multiple sort fields

**Request**

```http
GET /bold_falcon/articles?sort[status]=asc&sort[published_on]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "e8c30b71-ec2b-5287-ba57-5143a67ded78",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "66187cb1-6c7d-57b9-95bb-6de6ad564dad",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 3,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

:::

::: details Filter by date range

**Request**

```http
GET /bold_falcon/articles?filter[published_on][gte]=2024-01-01&filter[published_on][lt]=2024-02-01
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
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

::: details Filter by view count

**Request**

```http
GET /bold_falcon/articles?filter[view_count][gt]=100
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
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

::: details Combined filter and sort

**Request**

```http
GET /bold_falcon/articles?filter[status][eq]=published&sort[view_count]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "e8c30b71-ec2b-5287-ba57-5143a67ded78",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
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

::: details Filter by category

**Request**

```http
GET /bold_falcon/articles?filter[category][name][eq]=Technology
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Tech Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
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

<<< @/playground/public/bold-falcon/introspection.json

:::

::: details TypeScript

<<< @/playground/public/bold-falcon/typescript.ts

:::

::: details Zod

<<< @/playground/public/bold-falcon/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/bold-falcon/openapi.yml

:::