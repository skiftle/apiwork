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
      "id": "8f56fbba-c86e-4a2e-8716-6829339d9d58",
      "brand": "Volvo",
      "model": "EX30",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "type": "motorcycle",
      "id": "5584c7fd-8eb8-444f-89ab-1cfc5dc331a7",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engineCc": null
    },
    {
      "type": "truck",
      "id": "bac70bfd-4630-460f-94d7-929e337b68cd",
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
GET /mighty_wolf/vehicles/e3bc32e9-4fc5-4013-aaff-4e4b08919673
```

**Response** `200`

```json
{
  "vehicle": {
    "type": "car",
    "id": "e3bc32e9-4fc5-4013-aaff-4e4b08919673",
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
    "id": "a266376e-65ae-4a17-87a6-ab6afc694347",
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
    "id": "cecac8e1-0b63-4887-976e-5f86c4430ad6",
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
    "id": "23f48441-f5eb-4b9c-9b9a-ccf088ea7aa4",
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