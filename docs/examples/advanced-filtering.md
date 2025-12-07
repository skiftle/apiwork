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
      "id": "56ec4d11-26f1-4db9-8828-2c38298f761e",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.186Z",
      "updatedAt": "2025-12-07T13:30:59.186Z"
    },
    {
      "id": "9fc3d7d6-a38c-4ed5-9fe3-61448e074901",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.198Z",
      "updatedAt": "2025-12-07T13:30:59.198Z"
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
GET /bold_falcon/articles/8a528750-0869-419e-8d84-0b84722537e7
```

**Response** `200`

```json
{
  "article": {
    "id": "8a528750-0869-419e-8d84-0b84722537e7",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "viewCount": 0,
    "rating": null,
    "publishedOn": null,
    "createdAt": "2025-12-07T13:30:59.372Z",
    "updatedAt": "2025-12-07T13:30:59.372Z"
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
    "id": "58933ad8-4e64-4e47-9424-6ffb0dfecda1",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "viewCount": 0,
    "rating": null,
    "publishedOn": "2024-01-15",
    "createdAt": "2025-12-07T13:30:59.387Z",
    "updatedAt": "2025-12-07T13:30:59.387Z"
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
      "id": "587278fa-367e-42a1-a765-52a0460c8962",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.390Z",
      "updatedAt": "2025-12-07T13:30:59.390Z"
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
      "id": "49ba8a5a-7f1e-4858-8620-898b0cf2899f",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.403Z",
      "updatedAt": "2025-12-07T13:30:59.403Z"
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
      "id": "293c2eeb-e269-4096-a035-322bf9df2303",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2025-12-07T13:30:59.415Z",
      "updatedAt": "2025-12-07T13:30:59.415Z"
    },
    {
      "id": "a066b454-150f-40f6-9d39-284796f68e59",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-07T13:30:59.414Z",
      "updatedAt": "2025-12-07T13:30:59.414Z"
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
      "id": "bae7bc77-d5a3-4309-ab57-6e24a34646a2",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2025-12-07T13:30:59.425Z",
      "updatedAt": "2025-12-07T13:30:59.425Z"
    },
    {
      "id": "19462b9d-2e35-461c-820f-c95d7325da12",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-07T13:30:59.423Z",
      "updatedAt": "2025-12-07T13:30:59.423Z"
    },
    {
      "id": "714adcef-5180-4f75-a10a-f8559074a0c0",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2025-12-07T13:30:59.424Z",
      "updatedAt": "2025-12-07T13:30:59.424Z"
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
      "id": "0476c97e-5dc2-4689-b102-5feb32f5dfa8",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
      "createdAt": "2025-12-07T13:30:59.433Z",
      "updatedAt": "2025-12-07T13:30:59.433Z"
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
      "id": "59f57f73-c5a9-42a7-a14d-d9a901a7ac09",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.448Z",
      "updatedAt": "2025-12-07T13:30:59.448Z"
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
      "id": "99776af2-6ccd-48dc-8df8-10b9ee56a300",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.463Z",
      "updatedAt": "2025-12-07T13:30:59.463Z"
    },
    {
      "id": "5a848a78-3f60-481e-9f10-f08d331b02a3",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T13:30:59.466Z",
      "updatedAt": "2025-12-07T13:30:59.466Z"
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