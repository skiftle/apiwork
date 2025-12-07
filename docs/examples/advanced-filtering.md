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

<small>`app/models/bold_falcon/category.rb`</small>

<<< @/app/app/models/bold_falcon/category.rb

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
  "articles": [],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 0,
    "items": 0
  }
}
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /bold-falcon/articles/22a7d95b-1860-4567-a78d-0f9b0b37e3e0
```

**Response** `200`

```json
{
  "article": {
    "id": "22a7d95b-1860-4567-a78d-0f9b0b37e3e0",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "view_count": 0,
    "rating": null,
    "published_on": null,
    "created_at": "2025-12-07T08:42:27.023Z",
    "updated_at": "2025-12-07T08:42:27.023Z"
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
    "id": "73eb77cb-e6b3-468d-a11d-6a82b5dbd526",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "view_count": 0,
    "rating": null,
    "published_on": "2024-01-15",
    "created_at": "2025-12-07T08:42:27.037Z",
    "updated_at": "2025-12-07T08:42:27.037Z"
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
      "id": "9352d1fa-b9d5-4abc-b021-0f731d9bcea7",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T08:42:27.040Z",
      "updated_at": "2025-12-07T08:42:27.040Z"
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
      "id": "60aa93c3-7f47-4174-a8e8-609e4c368e59",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T08:42:27.052Z",
      "updated_at": "2025-12-07T08:42:27.052Z"
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