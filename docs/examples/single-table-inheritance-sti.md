---
order: 5
---

# Single Table Inheritance (STI)

Single Table Inheritance with automatic variant serialization and TypeScript union types

## API Definition

<small>`config/apis/mighty_wolf.rb`</small>

<<< @/app/config/apis/mighty_wolf.rb

## Models

<small>`app/models/mighty_wolf/car.rb`</small>

<<< @/app/app/models/mighty_wolf/car.rb

<small>`app/models/mighty_wolf/motorcycle.rb`</small>

<<< @/app/app/models/mighty_wolf/motorcycle.rb

<small>`app/models/mighty_wolf/truck.rb`</small>

<<< @/app/app/models/mighty_wolf/truck.rb

<small>`app/models/mighty_wolf/vehicle.rb`</small>

<<< @/app/app/models/mighty_wolf/vehicle.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| type | string |  |  |
| brand | string |  |  |
| model | string |  |  |
| year | integer | ✓ |  |
| color | string | ✓ |  |
| doors | integer | ✓ |  |
| engine_cc | integer | ✓ |  |
| payload_capacity | decimal | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/mighty_wolf/car_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/car_schema.rb

<small>`app/schemas/mighty_wolf/motorcycle_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/motorcycle_schema.rb

<small>`app/schemas/mighty_wolf/truck_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/truck_schema.rb

<small>`app/schemas/mighty_wolf/vehicle_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/vehicle_schema.rb

## Contracts

<small>`app/contracts/mighty_wolf/vehicle_contract.rb`</small>

<<< @/app/app/contracts/mighty_wolf/vehicle_contract.rb

## Controllers

<small>`app/controllers/mighty_wolf/vehicles_controller.rb`</small>

<<< @/app/app/controllers/mighty_wolf/vehicles_controller.rb

---



## Request Examples

<details>
<summary>List all vehicles</summary>

**Request**

```http
GET /mighty_wolf/vehicles
```

**Response** `200`

```json
{
  "vehicles": [
    {
      "id": "f103c0a7-5c77-460f-ada5-e3a9761ab4c3",
      "type": "MightyWolf::Car",
      "brand": "Tesla",
      "model": "Model 3",
      "year": null,
      "color": null
    },
    {
      "id": "a5ca84f8-83f7-402b-91a2-856d2f6d9b5c",
      "type": "MightyWolf::Motorcycle",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null
    },
    {
      "id": "e769500f-5c97-47ff-9bc9-995d4ec98aba",
      "type": "MightyWolf::Truck",
      "brand": "Ford",
      "model": "F-150",
      "year": null,
      "color": null
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
<summary>Get vehicle details</summary>

**Request**

```http
GET /mighty_wolf/vehicles/7a897d31-c55e-4671-a40f-4c4a536f8702
```

**Response** `200`

```json
{
  "vehicle": {
    "id": "7a897d31-c55e-4671-a40f-4c4a536f8702",
    "type": "MightyWolf::Car",
    "brand": "Tesla",
    "model": "Model 3",
    "year": 2024,
    "color": "red"
  }
}
```

</details>

<details>
<summary>Create a car</summary>

**Request**

```http
POST /mighty_wolf/vehicles
Content-Type: application/json

{
  "vehicle": {
    "kind": "car",
    "brand": "Tesla",
    "model": "Model 3",
    "year": 2024,
    "color": "red"
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
      "path": [
        "vehicle",
        "kind"
      ],
      "pointer": "/vehicle/kind",
      "meta": {
        "field": "kind",
        "allowed": [
          "brand",
          "model",
          "year",
          "color"
        ]
      }
    }
  ]
}
```

</details>

<details>
<summary>Create a motorcycle</summary>

**Request**

```http
POST /mighty_wolf/vehicles
Content-Type: application/json

{
  "vehicle": {
    "kind": "motorcycle",
    "brand": "Harley-Davidson",
    "model": "Street Glide",
    "year": 2023,
    "color": "black"
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
      "path": [
        "vehicle",
        "kind"
      ],
      "pointer": "/vehicle/kind",
      "meta": {
        "field": "kind",
        "allowed": [
          "brand",
          "model",
          "year",
          "color"
        ]
      }
    }
  ]
}
```

</details>

<details>
<summary>Create a truck</summary>

**Request**

```http
POST /mighty_wolf/vehicles
Content-Type: application/json

{
  "vehicle": {
    "kind": "truck",
    "brand": "Ford",
    "model": "F-150",
    "year": 2024,
    "color": "blue"
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
      "path": [
        "vehicle",
        "kind"
      ],
      "pointer": "/vehicle/kind",
      "meta": {
        "field": "kind",
        "allowed": [
          "brand",
          "model",
          "year",
          "color"
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

<<< @/app/public/mighty-wolf/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/mighty-wolf/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/mighty-wolf/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/mighty-wolf/openapi.yml

</details>