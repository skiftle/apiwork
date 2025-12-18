---
order: 5
---

# Single Table Inheritance (STI)

Single Table Inheritance with automatic variant serialization and TypeScript union types

## API Definition

<small>`config/apis/mighty_wolf.rb`</small>

<<< @/playground/config/apis/mighty_wolf.rb

## Models

<small>`app/models/mighty_wolf/vehicle.rb`</small>

<<< @/playground/app/models/mighty_wolf/vehicle.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| brand | string |  |  |
| color | string | ✓ |  |
| created_at | datetime |  |  |
| doors | integer | ✓ |  |
| engine_cc | integer | ✓ |  |
| model | string |  |  |
| payload_capacity | decimal | ✓ |  |
| type | string |  |  |
| updated_at | datetime |  |  |
| year | integer | ✓ |  |

</details>

<small>`app/models/mighty_wolf/car.rb`</small>

<<< @/playground/app/models/mighty_wolf/car.rb

<small>`app/models/mighty_wolf/truck.rb`</small>

<<< @/playground/app/models/mighty_wolf/truck.rb

<small>`app/models/mighty_wolf/motorcycle.rb`</small>

<<< @/playground/app/models/mighty_wolf/motorcycle.rb

## Schemas

<small>`app/schemas/mighty_wolf/vehicle_schema.rb`</small>

<<< @/playground/app/schemas/mighty_wolf/vehicle_schema.rb

<small>`app/schemas/mighty_wolf/car_schema.rb`</small>

<<< @/playground/app/schemas/mighty_wolf/car_schema.rb

<small>`app/schemas/mighty_wolf/truck_schema.rb`</small>

<<< @/playground/app/schemas/mighty_wolf/truck_schema.rb

<small>`app/schemas/mighty_wolf/motorcycle_schema.rb`</small>

<<< @/playground/app/schemas/mighty_wolf/motorcycle_schema.rb

## Contracts

<small>`app/contracts/mighty_wolf/vehicle_contract.rb`</small>

<<< @/playground/app/contracts/mighty_wolf/vehicle_contract.rb

## Controllers

<small>`app/controllers/mighty_wolf/vehicles_controller.rb`</small>

<<< @/playground/app/controllers/mighty_wolf/vehicles_controller.rb

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
      "type": "car",
      "id": "deb0aca7-a3ea-4ab1-9b4f-b1da937bbdd9",
      "brand": "Volvo",
      "model": "EX30",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "type": "motorcycle",
      "id": "b304a04c-f896-4222-a3cf-608cb82b1a7b",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engineCc": null
    },
    {
      "type": "truck",
      "id": "124fadee-039f-442d-a823-a21f1dcb5825",
      "brand": "Ford",
      "model": "F-150",
      "year": null,
      "color": null,
      "payloadCapacity": null
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
GET /mighty_wolf/vehicles/d2dcd9c8-977d-481c-b661-fd80fe251c2b
```

**Response** `200`

```json
{
  "vehicle": {
    "type": "car",
    "id": "d2dcd9c8-977d-481c-b661-fd80fe251c2b",
    "brand": "Volvo",
    "model": "EX30",
    "year": 2024,
    "color": "red",
    "doors": null
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
    "type": "car",
    "brand": "Volvo",
    "model": "EX30",
    "year": 2024,
    "color": "red"
  }
}
```

**Response** `201`

```json
{
  "vehicle": {
    "type": "car",
    "id": "9ce2bd5e-e2df-44c4-b66b-eb9f2b095744",
    "brand": "Volvo",
    "model": "EX30",
    "year": 2024,
    "color": "red",
    "doors": null
  }
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
    "type": "motorcycle",
    "brand": "Harley-Davidson",
    "model": "Street Glide",
    "year": 2023,
    "color": "black"
  }
}
```

**Response** `201`

```json
{
  "vehicle": {
    "type": "motorcycle",
    "id": "80c43b32-b482-4608-b7a3-e07d45f2c49f",
    "brand": "Harley-Davidson",
    "model": "Street Glide",
    "year": 2023,
    "color": "black",
    "engineCc": null
  }
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
    "type": "truck",
    "brand": "Ford",
    "model": "F-150",
    "year": 2024,
    "color": "blue"
  }
}
```

**Response** `201`

```json
{
  "vehicle": {
    "type": "truck",
    "id": "bba5738b-63af-4398-88b5-cadf7220ca36",
    "brand": "Ford",
    "model": "F-150",
    "year": 2024,
    "color": "blue",
    "payloadCapacity": null
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/mighty-wolf/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/mighty-wolf/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/mighty-wolf/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/mighty-wolf/openapi.yml

</details>