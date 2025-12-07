---
order: 5
---

# Single Table Inheritance (STI)

Single Table Inheritance with automatic variant serialization and TypeScript union types

## API Definition

<small>`config/apis/mighty_wolf.rb`</small>

<<< @/app/config/apis/mighty_wolf.rb

## Models

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

<small>`app/models/mighty_wolf/car.rb`</small>

<<< @/app/app/models/mighty_wolf/car.rb

<small>`app/models/mighty_wolf/truck.rb`</small>

<<< @/app/app/models/mighty_wolf/truck.rb

<small>`app/models/mighty_wolf/motorcycle.rb`</small>

<<< @/app/app/models/mighty_wolf/motorcycle.rb

## Schemas

<small>`app/schemas/mighty_wolf/vehicle_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/vehicle_schema.rb

<small>`app/schemas/mighty_wolf/car_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/car_schema.rb

<small>`app/schemas/mighty_wolf/truck_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/truck_schema.rb

<small>`app/schemas/mighty_wolf/motorcycle_schema.rb`</small>

<<< @/app/app/schemas/mighty_wolf/motorcycle_schema.rb

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
      "type": "car",
      "id": "08a1869d-7742-4c6e-9fd3-1d0c7ab32da3",
      "brand": "Volvo",
      "model": "EX30",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "type": "motorcycle",
      "id": "6875ad92-40f4-49f1-87b9-28d297c64def",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engineCc": null
    },
    {
      "type": "truck",
      "id": "e7b63b0f-20ca-4865-9655-008aa0e72302",
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
GET /mighty_wolf/vehicles/874b69dd-8485-43fb-ac86-250906ec5317
```

**Response** `200`

```json
{
  "vehicle": {
    "type": "car",
    "id": "874b69dd-8485-43fb-ac86-250906ec5317",
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
    "id": "20c5899b-6bdb-4cbd-a6b2-b2fe50dfaa87",
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
    "id": "47cbcdf7-5879-4469-8308-32240389c0fb",
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
    "id": "2526db31-2c15-4fb5-9a94-53af949e6317",
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