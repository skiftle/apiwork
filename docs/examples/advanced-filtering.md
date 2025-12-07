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
GET /bold-falcon/articles
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "181981b2-e45d-465a-9de9-2b7be4a78f1b",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.371Z",
      "updated_at": "2025-12-07T13:14:56.371Z"
    },
    {
      "id": "520fa5b9-b62e-4553-8db7-dad9bd8c2290",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.375Z",
      "updated_at": "2025-12-07T13:14:56.375Z"
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
GET /bold-falcon/articles/8ea34367-b8b2-4a96-91b6-0d88b0f3fc1e
```

**Response** `200`

```json
{
  "article": {
    "id": "8ea34367-b8b2-4a96-91b6-0d88b0f3fc1e",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "view_count": 0,
    "rating": null,
    "published_on": null,
    "created_at": "2025-12-07T13:14:56.604Z",
    "updated_at": "2025-12-07T13:14:56.604Z"
  }
}
```

</details>

<details>
<summary>Create a new article</summary>

**Request**

```http
POST /bold-falcon/articles
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
    "id": "7ce52ce6-953e-4355-91df-b866e41ef75c",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "view_count": 0,
    "rating": null,
    "published_on": "2024-01-15",
    "created_at": "2025-12-07T13:14:56.620Z",
    "updated_at": "2025-12-07T13:14:56.620Z"
  }
}
```

</details>

<details>
<summary>Filter by status</summary>

**Request**

```http
GET /bold-falcon/articles?filter[status][eq]=published
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "70093428-88f1-4941-ac2c-bfd415a1d826",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.623Z",
      "updated_at": "2025-12-07T13:14:56.623Z"
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
GET /bold-falcon/articles?filter[title][contains]=Rails
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "ea0699bd-2c31-4932-89f7-c745aa4440cc",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.646Z",
      "updated_at": "2025-12-07T13:14:56.646Z"
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
GET /bold-falcon/articles?sort[published_on]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "70e9b70a-4c42-4a34-a034-8314f5b15bab",
      "title": "New Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": "2024-06-01",
      "created_at": "2025-12-07T13:14:56.662Z",
      "updated_at": "2025-12-07T13:14:56.662Z"
    },
    {
      "id": "ad53ad12-8c66-4f97-bcff-b7232c0de052",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": "2024-01-01",
      "created_at": "2025-12-07T13:14:56.661Z",
      "updated_at": "2025-12-07T13:14:56.661Z"
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
GET /bold-falcon/articles?sort[status]=asc&sort[published_on]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "27ff4c22-b306-4c52-8b3f-f5564817ee32",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "view_count": 0,
      "rating": null,
      "published_on": "2024-03-01",
      "created_at": "2025-12-07T13:14:56.671Z",
      "updated_at": "2025-12-07T13:14:56.671Z"
    },
    {
      "id": "cbdcaa6e-db70-4a09-813e-c93089877ba3",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "view_count": 0,
      "rating": null,
      "published_on": "2024-01-01",
      "created_at": "2025-12-07T13:14:56.670Z",
      "updated_at": "2025-12-07T13:14:56.670Z"
    },
    {
      "id": "cfccd598-ec88-4662-a8b7-0e7ea81527d0",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": "2024-02-01",
      "created_at": "2025-12-07T13:14:56.671Z",
      "updated_at": "2025-12-07T13:14:56.671Z"
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
GET /bold-falcon/articles?filter[published_on][gte]=2024-01-01&filter[published_on][lt]=2024-02-01
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "d6fa4655-8a4b-4c32-8405-0e5321d83597",
      "title": "January Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": "2024-01-15",
      "created_at": "2025-12-07T13:14:56.679Z",
      "updated_at": "2025-12-07T13:14:56.679Z"
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
GET /bold-falcon/articles?filter[view_count][gt]=100
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "53ae7bb7-eb13-4b53-a4f1-53120b559212",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "view_count": 500,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.694Z",
      "updated_at": "2025-12-07T13:14:56.694Z"
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
GET /bold-falcon/articles?filter[status][eq]=published&sort[view_count]=desc
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "4636ab45-1e07-4e2c-9ce4-0c0d99417328",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "view_count": 1000,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.709Z",
      "updated_at": "2025-12-07T13:14:56.709Z"
    },
    {
      "id": "d303f7e5-3be9-4321-b69c-b5ae21251a58",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "view_count": 100,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T13:14:56.711Z",
      "updated_at": "2025-12-07T13:14:56.711Z"
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
GET /bold-falcon/articles?filter[category][name][eq]=Technology
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