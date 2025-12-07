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
      "id": "e50f45d0-ad0e-4093-81c2-99d456d93266",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.343Z",
      "updatedAt": "2025-12-07T15:57:32.343Z"
    },
    {
      "id": "36b3c14e-1023-4ad1-b1cf-d81f30366db8",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.346Z",
      "updatedAt": "2025-12-07T15:57:32.346Z"
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
GET /bold_falcon/articles/f0f080ce-a8bf-4a32-9bb6-b2ca9c82bed4
```

**Response** `200`

```json
{
  "article": {
    "id": "f0f080ce-a8bf-4a32-9bb6-b2ca9c82bed4",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "viewCount": 0,
    "rating": null,
    "publishedOn": null,
    "createdAt": "2025-12-07T15:57:32.465Z",
    "updatedAt": "2025-12-07T15:57:32.465Z"
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
    "id": "3ff0f36b-7fa0-4189-8dad-604a468be3d7",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "viewCount": 0,
    "rating": null,
    "publishedOn": "2024-01-15",
    "createdAt": "2025-12-07T15:57:32.481Z",
    "updatedAt": "2025-12-07T15:57:32.481Z"
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
      "id": "6387d994-4194-4636-a42f-c7c8974b3847",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.484Z",
      "updatedAt": "2025-12-07T15:57:32.484Z"
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
      "id": "9ca9d075-c54c-4b5b-ada3-ba87079523fa",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.498Z",
      "updatedAt": "2025-12-07T15:57:32.498Z"
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
      "id": "31e0ef1d-b449-4758-a24e-ecc1255710f0",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2025-12-07T15:57:32.509Z",
      "updatedAt": "2025-12-07T15:57:32.509Z"
    },
    {
      "id": "6e47d23b-0601-4a74-ae59-c8b13e4581d4",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-07T15:57:32.508Z",
      "updatedAt": "2025-12-07T15:57:32.508Z"
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
      "id": "a21ce6a7-5865-4bf3-9144-c124afd92d55",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2025-12-07T15:57:32.517Z",
      "updatedAt": "2025-12-07T15:57:32.517Z"
    },
    {
      "id": "8135a1f6-50a4-4a2f-a0bb-c0a462d4e226",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-07T15:57:32.516Z",
      "updatedAt": "2025-12-07T15:57:32.516Z"
    },
    {
      "id": "31541292-c475-4308-84bc-d88d8799b08e",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2025-12-07T15:57:32.516Z",
      "updatedAt": "2025-12-07T15:57:32.516Z"
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
      "id": "f48a190a-6b0d-4d61-854f-01cc34c3206c",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
      "createdAt": "2025-12-07T15:57:32.524Z",
      "updatedAt": "2025-12-07T15:57:32.524Z"
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
      "id": "99dbc28e-ee86-475a-8659-8b6e3edcb67e",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.538Z",
      "updatedAt": "2025-12-07T15:57:32.538Z"
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
      "id": "c5088701-60e5-4dd7-8347-769d0b96e447",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.552Z",
      "updatedAt": "2025-12-07T15:57:32.552Z"
    },
    {
      "id": "d6ed252e-4b18-45c5-aaa5-01530d47c32a",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-07T15:57:32.553Z",
      "updatedAt": "2025-12-07T15:57:32.553Z"
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