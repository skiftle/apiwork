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
<summary>index</summary>

**Request**

```http
GET /bold-falcon/articles
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "89779802-cdc6-4fdf-8cda-4a79adc3d015",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T11:45:00.783Z",
      "updated_at": "2025-12-07T11:45:00.783Z"
    },
    {
      "id": "cdbc949a-0dfe-4ea9-83ce-57e87e018498",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T11:45:00.786Z",
      "updated_at": "2025-12-07T11:45:00.786Z"
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
GET /bold-falcon/articles/04524900-4512-4dc2-a3d7-d84a40deef20
```

**Response** `200`

```json
{
  "article": {
    "id": "04524900-4512-4dc2-a3d7-d84a40deef20",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "view_count": 0,
    "rating": null,
    "published_on": null,
    "created_at": "2025-12-07T11:45:01.004Z",
    "updated_at": "2025-12-07T11:45:01.004Z"
  }
}
```

</details>

<details>
<summary>create</summary>

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
    "id": "75957448-08a9-4810-80b9-dd9a674e2d6e",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "view_count": 0,
    "rating": null,
    "published_on": "2024-01-15",
    "created_at": "2025-12-07T11:45:01.026Z",
    "updated_at": "2025-12-07T11:45:01.026Z"
  }
}
```

</details>

<details>
<summary>filter_by_status</summary>

**Request**

```http
GET /bold-falcon/articles?filter[status][eq]=published
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "9054000c-6cbd-4ea4-a5f6-c436a544720f",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T11:45:01.030Z",
      "updated_at": "2025-12-07T11:45:01.030Z"
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
<summary>filter_by_title_contains</summary>

**Request**

```http
GET /bold-falcon/articles?filter[title][contains]=Rails
```

**Response** `200`

```json
{
  "articles": [
    {
      "id": "80917b2f-74f8-404f-9549-e6412fd87f92",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T11:45:01.045Z",
      "updated_at": "2025-12-07T11:45:01.045Z"
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