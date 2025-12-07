---
order: 5
---

# STI with Discriminated Unions

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
<summary>Database Schema</summary>

<<< @/app/public/mighty-wolf/schema.md

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
<summary>index</summary>

**Request**

```http
GET /mighty-wolf/vehicles
```

**Response** `200`

```json
{
  "vehicles": [
    {
      "kind": "car",
      "id": "d7630ae7-515d-4ee3-b8ae-7730d9cd8672",
      "brand": "Tesla",
      "model": "Model 3",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "kind": "motorcycle",
      "id": "cd26ed34-deec-4e4c-b7eb-60f7db4036f1",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engine_cc": null
    },
    {
      "kind": "truck",
      "id": "f2c22361-a86e-4517-863b-5839ea4dbdee",
      "brand": "Ford",
      "model": "F-150",
      "year": null,
      "color": null,
      "payload_capacity": null
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
<summary>show</summary>

**Request**

```http
GET /mighty-wolf/vehicles/e78b3d06-69fb-4646-98eb-e3f5ee4f418b
```

**Response** `200`

```json
{
  "vehicle": {
    "kind": "car",
    "id": "e78b3d06-69fb-4646-98eb-e3f5ee4f418b",
    "brand": "Tesla",
    "model": "Model 3",
    "year": 2024,
    "color": "red",
    "doors": null
  }
}
```

</details>

<details>
<summary>create_car</summary>

**Request**

```http
POST /mighty-wolf/vehicles
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

**Response** `201`

```json
{
  "vehicle": {
    "kind": "car",
    "id": "ec5b2ae5-78cb-4c3f-bf01-691e69ea9c29",
    "brand": "Tesla",
    "model": "Model 3",
    "year": 2024,
    "color": "red",
    "doors": null
  }
}
```

</details>

<details>
<summary>create_motorcycle</summary>

**Request**

```http
POST /mighty-wolf/vehicles
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

**Response** `201`

```json
{
  "vehicle": {
    "kind": "motorcycle",
    "id": "9ae0f997-ed3e-4b12-91ca-7a0ec1108979",
    "brand": "Harley-Davidson",
    "model": "Street Glide",
    "year": 2023,
    "color": "black",
    "engine_cc": null
  }
}
```

</details>

<details>
<summary>create_truck</summary>

**Request**

```http
POST /mighty-wolf/vehicles
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

**Response** `201`

```json
{
  "vehicle": {
    "kind": "truck",
    "id": "5a6fde8f-2aa0-4792-901f-46033f8f2a35",
    "brand": "Ford",
    "model": "F-150",
    "year": 2024,
    "color": "blue",
    "payload_capacity": null
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