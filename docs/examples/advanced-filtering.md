---
order: 4
---

# Advanced Filtering

Complex queries with string patterns, numeric ranges, and logical operators

## API Definition

<small>`config/apis/bold_falcon.rb`</small>

<<< @/playground/config/apis/bold_falcon.rb

## Models

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

## Representations

<small>`app/representations/bold_falcon/article_representation.rb`</small>

<<< @/playground/app/representations/bold_falcon/article_representation.rb

<small>`app/representations/bold_falcon/category_representation.rb`</small>

<<< @/playground/app/representations/bold_falcon/category_representation.rb

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
      "id": "980bb55a-45bc-531b-a571-31b7d4d0a0ce",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "66187cb1-6c7d-57b9-95bb-6de6ad564dad",
      "title": "Draft Article",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

</details>

<details>
<summary>Get article details</summary>

**Request**

```http
GET /bold_falcon/articles/e8c30b71-ec2b-5287-ba57-5143a67ded78
```

**Response** `200`

```json
{
  "article": {
    "id": "e8c30b71-ec2b-5287-ba57-5143a67ded78",
    "title": "Getting Started with Rails",
    "body": null,
    "status": "published",
    "viewCount": 0,
    "rating": null,
    "publishedOn": null,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
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

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [],
        "field": "title"
      },
      "path": [
        "article",
        "title"
      ],
      "pointer": "/article/title"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [],
        "field": "body"
      },
      "path": [
        "article",
        "body"
      ],
      "pointer": "/article/body"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [],
        "field": "status"
      },
      "path": [
        "article",
        "status"
      ],
      "pointer": "/article/status"
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "meta": {
        "allowed": [],
        "field": "published_on"
      },
      "path": [
        "article",
        "published_on"
      ],
      "pointer": "/article/published_on"
    }
  ],
  "layer": "contract"
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
      "id": "ab2b6c9d-5ec0-5e58-8784-fd8f52b28b17",
      "title": "Published Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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
      "id": "209174f0-a4ca-557e-bca2-357b6b2d3410",
      "title": "Getting Started with Rails",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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
      "id": "4927d610-8859-576f-a595-fa2b9ec5a4e0",
      "title": "New Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-06-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "f24078a2-72e4-5d67-ac6e-a664c08ad0ce",
      "title": "Old Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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
      "id": "7a18e4a4-1c8e-5d55-8453-5a34f0f49f83",
      "title": "Draft 2",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-03-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "7c5847bc-3b03-598a-8718-3ffa3ae2f0fd",
      "title": "Draft 1",
      "body": null,
      "status": "draft",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "3e4f8c34-7b92-5de6-a69c-4c7a2436bfd7",
      "title": "Published 1",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-02-01",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 3,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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
      "id": "e52ca88a-f9b7-5b6b-a410-ef1a92e2b4ca",
      "title": "January Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": "2024-01-15",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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
      "id": "7a0f2a70-2cbd-55df-ab66-00a91fb0ab2c",
      "title": "Popular Article",
      "body": null,
      "status": "published",
      "viewCount": 500,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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
      "id": "d6bbb0e1-5a89-5e90-be92-f678a9c7ab8a",
      "title": "Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 1000,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "f9b17d67-ea3b-594a-9ca1-50e6ebb5d91a",
      "title": "Less Popular Published",
      "body": null,
      "status": "published",
      "viewCount": 100,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
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

**Response** `200`

```json
{
  "articles": [
    {
      "id": "d33b1b6c-7d36-58ff-8512-bdbeb74ad459",
      "title": "Tech Article",
      "body": null,
      "status": "published",
      "viewCount": 0,
      "rating": null,
      "publishedOn": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
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