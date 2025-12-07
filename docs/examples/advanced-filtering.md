---
order: 4
---

# Advanced Filtering

Complex queries with string patterns, numeric ranges, and logical operators

## API Definition

<small>`config/apis/bold_falcon.rb`</small>

<<< @/app/config/apis/bold_falcon.rb

## Models

<small>`app/models/bold_falcon/article.rb`</small>

<<< @/app/app/models/bold_falcon/article.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| category_id | string | ✓ |  |
| title | string |  |  |
| body | text | ✓ |  |
| status | string | ✓ | draft |
| view_count | integer | ✓ | 0 |
| rating | decimal | ✓ |  |
| published_on | date | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/bold_falcon/category.rb`</small>

<<< @/app/app/models/bold_falcon/category.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| name | string |  |  |
| slug | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/bold_falcon/article_schema.rb`</small>

<<< @/app/app/schemas/bold_falcon/article_schema.rb

<small>`app/schemas/bold_falcon/category_schema.rb`</small>

<<< @/app/app/schemas/bold_falcon/category_schema.rb

## Contracts

<small>`app/contracts/bold_falcon/article_contract.rb`</small>

<<< @/app/app/contracts/bold_falcon/article_contract.rb

## Controllers

<small>`app/controllers/bold_falcon/articles_controller.rb`</small>

<<< @/app/app/controllers/bold_falcon/articles_controller.rb

---



## Request Examples

<details>
<summary>List all articles</summary>

**Request**

```http
GET /bold_falcon/articles
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "917f1a5d-9419-4344-b125-e9cb2b07cee5",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:41.923Z",
      "updatedAt": "2025-12-07T14:49:41.923Z"
    },
    {
      "id": "94b7b72b-4954-4b3f-a1ed-99c7d69de2d5",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:41.941Z",
      "updatedAt": "2025-12-07T14:49:41.941Z"
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
<summary>Get article details</summary>

**Request**

```http
GET /bold_falcon/articles/5b490768-e819-4a0d-9b19-37ffd107a07a
```

**Response** `200`

```json
{
  "article": {
    "id": "5b490768-e819-4a0d-9b19-37ffd107a07a",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "viewCount": 0,
    "rating": null,
    "publishedOn": null,
    "createdAt": "2025-12-07T14:49:42.177Z",
    "updatedAt": "2025-12-07T14:49:42.177Z"
  }
}
```

</details>

<details>
<summary>Create a new article</summary>

**Request**

```http
POST /bold_falcon/articles
Content-Type: application/json

{
  "article": {
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "published_on": "2024-01-15"
  }
}
```

**Response** `201`

```json
{
  "article": {
    "id": "52583264-12f1-4656-810b-b98695e7575b",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "viewCount": 0,
    "rating": null,
    "publishedOn": "2024-01-15",
    "createdAt": "2025-12-07T14:49:42.191Z",
    "updatedAt": "2025-12-07T14:49:42.191Z"
  }
}
```

</details>

<details>
<summary>Filter by status</summary>

**Request**

```http
GET /bold_falcon/articles?filter[status][eq]=published
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "ecfb2c0b-ecca-49e0-9e01-754359a7089d",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:42.194Z",
      "updatedAt": "2025-12-07T14:49:42.194Z"
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

<details>
<summary>Filter by title pattern</summary>

**Request**

```http
GET /bold_falcon/articles?filter[title][contains]=Rails
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "697dfe50-de73-49dd-a880-bc097f1c868e",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:42.206Z",
      "updatedAt": "2025-12-07T14:49:42.206Z"
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

<details>
<summary>Sort by date</summary>

**Request**

```http
GET /bold_falcon/articles?sort[published_on]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "eba7324a-fdb8-4db4-8409-4346a9479f99",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2025-12-07T14:49:42.219Z",
      "updatedAt": "2025-12-07T14:49:42.219Z"
    },
    {
      "id": "c0024dcf-6dee-49e4-bb86-fc3848f76540",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-07T14:49:42.218Z",
      "updatedAt": "2025-12-07T14:49:42.218Z"
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
<summary>Multiple sort fields</summary>

**Request**

```http
GET /bold_falcon/articles?sort[status]=asc&sort[published_on]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "1642f9f5-36d3-482f-8739-9cd486bc8a19",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2025-12-07T14:49:42.228Z",
      "updatedAt": "2025-12-07T14:49:42.228Z"
    },
    {
      "id": "b6746bf9-c11c-4e57-8ff9-8b1fa02f0ce7",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-07T14:49:42.226Z",
      "updatedAt": "2025-12-07T14:49:42.226Z"
    },
    {
      "id": "a0474976-31d5-4c0f-8a38-980eb39694af",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2025-12-07T14:49:42.227Z",
      "updatedAt": "2025-12-07T14:49:42.227Z"
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

</details>

<details>
<summary>Filter by date range</summary>

**Request**

```http
GET /bold_falcon/articles?filter[published_on][gte]=2024-01-01&filter[published_on][lt]=2024-02-01
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "59fc9527-2fe2-40d4-99ef-0e623e5e19ba",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
      "createdAt": "2025-12-07T14:49:42.236Z",
      "updatedAt": "2025-12-07T14:49:42.236Z"
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

<details>
<summary>Filter by view count</summary>

**Request**

```http
GET /bold_falcon/articles?filter[view_count][gt]=100
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "500cb064-8a4a-4b07-83c9-db4c8a019b54",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:42.250Z",
      "updatedAt": "2025-12-07T14:49:42.250Z"
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

<details>
<summary>Combined filter and sort</summary>

**Request**

```http
GET /bold_falcon/articles?filter[status][eq]=published&sort[view_count]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "3db9486e-74b9-4478-bdaa-63bd3ee0f06b",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:42.267Z",
      "updatedAt": "2025-12-07T14:49:42.267Z"
    },
    {
      "id": "33e7d615-8dc8-4e07-9edd-911fa34a9c05",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T14:49:42.268Z",
      "updatedAt": "2025-12-07T14:49:42.268Z"
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
<summary>Filter by category</summary>

**Request**

```http
GET /bold_falcon/articles?filter[category][name][eq]=Technology
```

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "filter",
        "category"
      ],
      "pointer": "/filter/category",
      "meta": {
        "field": "category",
        "allowed": [
          "_and",
          "_or",
          "_not",
          "title",
          "status",
          "view_count",
          "rating",
          "published_on"
        ]
      }
    }
  ]
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/bold-falcon/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/bold-falcon/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/bold-falcon/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/bold-falcon/openapi.yml

</details>