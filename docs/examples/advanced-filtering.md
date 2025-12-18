---
order: 4
---

# Advanced Filtering

Complex queries with string patterns, numeric ranges, and logical operators

## API Definition

<small>`config/apis/bold_falcon.rb`</small>

<<< @/playground/config/apis/bold_falcon.rb

## Models

<small>`app/models/bold_falcon/category.rb`</small>

<<< @/playground/app/models/bold_falcon/category.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| slug | string |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/bold_falcon/article.rb`</small>

<<< @/playground/app/models/bold_falcon/article.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| body | text | ✓ |  |
| category_id | string | ✓ |  |
| created_at | datetime |  |  |
| published_on | date | ✓ |  |
| rating | decimal | ✓ |  |
| status | string | ✓ | draft |
| title | string |  |  |
| updated_at | datetime |  |  |
| view_count | integer | ✓ | 0 |

</details>

## Schemas

<small>`app/schemas/bold_falcon/category_schema.rb`</small>

<<< @/playground/app/schemas/bold_falcon/category_schema.rb

<small>`app/schemas/bold_falcon/article_schema.rb`</small>

<<< @/playground/app/schemas/bold_falcon/article_schema.rb

## Contracts

<small>`app/contracts/bold_falcon/article_contract.rb`</small>

<<< @/playground/app/contracts/bold_falcon/article_contract.rb

## Controllers

<small>`app/controllers/bold_falcon/articles_controller.rb`</small>

<<< @/playground/app/controllers/bold_falcon/articles_controller.rb

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
      "id": "4bcb2785-9a76-49ea-a1b8-05f7af56f7ab",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.494Z",
      "updatedAt": "2025-12-18T13:21:01.494Z"
    },
    {
      "id": "4a90e9d0-baa6-49d5-91d5-88be29185734",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.495Z",
      "updatedAt": "2025-12-18T13:21:01.495Z"
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
GET /bold_falcon/articles/3714030a-4383-4436-82fb-e22325e238fa
```

**Response** `200`

```json
{
  "article": {
    "id": "3714030a-4383-4436-82fb-e22325e238fa",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "viewCount": 0,
    "rating": null,
    "publishedOn": null,
    "createdAt": "2025-12-18T13:21:01.623Z",
    "updatedAt": "2025-12-18T13:21:01.623Z"
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
    "id": "aa89ce1c-c6c8-4fb2-9c2c-85478a0d1e4c",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "viewCount": 0,
    "rating": null,
    "publishedOn": "2024-01-15",
    "createdAt": "2025-12-18T13:21:01.639Z",
    "updatedAt": "2025-12-18T13:21:01.639Z"
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
      "id": "dabb2895-4638-4022-8032-59c347c30f9c",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.642Z",
      "updatedAt": "2025-12-18T13:21:01.642Z"
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
      "id": "c8d8842c-eea9-42f7-9d50-19f4da2fe1a4",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.655Z",
      "updatedAt": "2025-12-18T13:21:01.655Z"
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
      "id": "f530be96-b0c3-4884-96e8-a75114fbe1bf",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2025-12-18T13:21:01.668Z",
      "updatedAt": "2025-12-18T13:21:01.668Z"
    },
    {
      "id": "77c1d9c2-fb02-4c25-9e9f-78dec328b39f",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-18T13:21:01.666Z",
      "updatedAt": "2025-12-18T13:21:01.666Z"
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
      "id": "9681d3bc-fcb8-4cb5-a2cc-703f1bc22d4e",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2025-12-18T13:21:01.677Z",
      "updatedAt": "2025-12-18T13:21:01.677Z"
    },
    {
      "id": "edfc5837-b147-4db9-88de-e3429a6d6de6",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-18T13:21:01.675Z",
      "updatedAt": "2025-12-18T13:21:01.675Z"
    },
    {
      "id": "21fb81df-9997-4b3e-8379-b650f51f2159",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2025-12-18T13:21:01.676Z",
      "updatedAt": "2025-12-18T13:21:01.676Z"
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
      "id": "5ca02d34-c4ad-4b44-b72f-834e95fcc4c7",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
      "createdAt": "2025-12-18T13:21:01.685Z",
      "updatedAt": "2025-12-18T13:21:01.685Z"
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
      "id": "e89461be-4dbe-4485-9c29-3176e0d2f713",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.701Z",
      "updatedAt": "2025-12-18T13:21:01.701Z"
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
      "id": "0020a5a3-b04c-4ac6-b892-13413e43c700",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.716Z",
      "updatedAt": "2025-12-18T13:21:01.716Z"
    },
    {
      "id": "9c0eb673-267f-435b-94d6-16453ad4f0e0",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:21:01.718Z",
      "updatedAt": "2025-12-18T13:21:01.718Z"
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

<<< @/playground/public/bold-falcon/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/bold-falcon/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/bold-falcon/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/bold-falcon/openapi.yml

</details>