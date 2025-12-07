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
  "articles": [
    {
      "id": "b4216486-0538-4109-b05d-66dda2738754",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T09:41:44.301Z",
      "updated_at": "2025-12-07T09:41:44.301Z"
    },
    {
      "id": "15d25d8a-e4c7-4abb-b599-81aed4f75261",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T09:41:44.304Z",
      "updated_at": "2025-12-07T09:41:44.304Z"
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
GET /bold-falcon/articles/fcac94d3-7232-4347-93da-2dcf2fc9c097
```

**Response** `200`

```json
{
  "article": {
    "id": "fcac94d3-7232-4347-93da-2dcf2fc9c097",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "view_count": 0,
    "rating": null,
    "published_on": null,
    "created_at": "2025-12-07T09:41:44.490Z",
    "updated_at": "2025-12-07T09:41:44.490Z"
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
    "id": "a970dbec-35e5-4356-abec-54f135b2faaf",
    "title": "Getting Started with Rails",
    "body": "A comprehensive guide to Ruby on Rails",
    "status": "draft",
    "view_count": 0,
    "rating": null,
    "published_on": "2024-01-15",
    "created_at": "2025-12-07T09:41:44.520Z",
    "updated_at": "2025-12-07T09:41:44.520Z"
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
      "id": "33146b88-9558-44e3-b1a1-dff4b169f512",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T09:41:44.525Z",
      "updated_at": "2025-12-07T09:41:44.525Z"
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
      "id": "6acbe6c5-42d4-4d5f-b98a-fe93b36589f8",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "view_count": 0,
      "rating": null,
      "published_on": null,
      "created_at": "2025-12-07T09:41:44.539Z",
      "updated_at": "2025-12-07T09:41:44.539Z"
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