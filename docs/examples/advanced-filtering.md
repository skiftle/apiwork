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
      "id": "72b0277e-4cf8-4fa4-acf6-8dec9dca4d75",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.416Z",
      "updatedAt": "2025-12-18T13:29:03.416Z"
    },
    {
      "id": "ca34dda5-f62e-4e54-93ab-6f55631a6877",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.420Z",
      "updatedAt": "2025-12-18T13:29:03.420Z"
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
GET /bold_falcon/articles/93fe5fc6-961d-4399-ad33-0ad9ca883c81
```

**Response** `200`

```json
{
  "article": {
    "id": "93fe5fc6-961d-4399-ad33-0ad9ca883c81",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "viewCount": 0,
    "rating": null,
    "publishedOn": null,
    "createdAt": "2025-12-18T13:29:03.545Z",
    "updatedAt": "2025-12-18T13:29:03.545Z"
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
    "id": "b37cf618-69bd-4dac-b1fa-d28eb57a3a16",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "viewCount": 0,
    "rating": null,
    "publishedOn": "2024-01-15",
    "createdAt": "2025-12-18T13:29:03.559Z",
    "updatedAt": "2025-12-18T13:29:03.559Z"
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
      "id": "ebee6722-9d91-483d-9c77-6ef07bde790e",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.561Z",
      "updatedAt": "2025-12-18T13:29:03.561Z"
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
      "id": "00f39827-0fc2-4493-b8e3-60b250341e31",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.574Z",
      "updatedAt": "2025-12-18T13:29:03.574Z"
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
      "id": "285c3073-2695-479b-8997-75be9ce49ed8",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2025-12-18T13:29:03.586Z",
      "updatedAt": "2025-12-18T13:29:03.586Z"
    },
    {
      "id": "6f02287f-ae0c-46f3-a46b-f9957db31cd6",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-18T13:29:03.586Z",
      "updatedAt": "2025-12-18T13:29:03.586Z"
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
      "id": "9536d1a5-b0eb-42e9-8e06-d5fc766d39dd",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2025-12-18T13:29:03.596Z",
      "updatedAt": "2025-12-18T13:29:03.596Z"
    },
    {
      "id": "7d4aab16-2e18-4f0e-ad29-3215ffc7d6a7",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2025-12-18T13:29:03.594Z",
      "updatedAt": "2025-12-18T13:29:03.594Z"
    },
    {
      "id": "11776d81-db8c-4818-924b-2f1140239b70",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2025-12-18T13:29:03.595Z",
      "updatedAt": "2025-12-18T13:29:03.595Z"
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
      "id": "b455f6f1-b6f7-4c55-a762-43665726b29a",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
      "createdAt": "2025-12-18T13:29:03.604Z",
      "updatedAt": "2025-12-18T13:29:03.604Z"
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
      "id": "a4064e02-04fc-40cd-824b-01be851f7778",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.621Z",
      "updatedAt": "2025-12-18T13:29:03.621Z"
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
      "id": "b17142ac-04a0-4e44-a32d-a0622e3023d3",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.637Z",
      "updatedAt": "2025-12-18T13:29:03.637Z"
    },
    {
      "id": "8d8226de-bed4-4d6f-b94e-ca1db6878806",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2025-12-18T13:29:03.639Z",
      "updatedAt": "2025-12-18T13:29:03.639Z"
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