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
GET /bold-falcon/articles/f1558af9-67a0-4526-a765-e8029fe6a9f2
```

**Response** `200`

```json
{
  "article": {
    "id": "f1558af9-67a0-4526-a765-e8029fe6a9f2",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "view_count": 0,
    "rating": null,
    "published_on": null,
    "created_at": "2025-12-07T08:54:43.741Z",
    "updated_at": "2025-12-07T08:54:43.741Z"
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
    "id": "308ce6c0-a14e-44a5-9ebe-21787d4dd1c5",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "view_count": 0,
    "rating": null,
    "published_on": "2024-01-15",
    "created_at": "2025-12-07T08:54:43.753Z",
    "updated_at": "2025-12-07T08:54:43.753Z"
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
      "id": "b0280e99-831d-459a-a4a4-d34143d4eba0",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T08:54:43.756Z",
      "updated_at": "2025-12-07T08:54:43.756Z"
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
      "id": "6dda7b25-500f-439c-a748-eee5ff290ca8",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T08:54:43.767Z",
      "updated_at": "2025-12-07T08:54:43.767Z"
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