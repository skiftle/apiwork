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
      "id": "4051fb85-17ae-491f-a767-426675453514",
      "brand": "Tesla",
      "model": "Model 3",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "kind": "motorcycle",
      "id": "f2f8687c-2a66-4a39-a863-c2757231d751",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engine_cc": null
    },
    {
      "kind": "truck",
      "id": "596ca2c5-1606-48ae-9e77-2bdf72e9715d",
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
GET /mighty-wolf/vehicles/629f65cc-9d14-430f-99eb-0089e8c02bf0
```

**Response** `200`

```json
{
  "vehicle": {
    "kind": "car",
    "id": "629f65cc-9d14-430f-99eb-0089e8c02bf0",
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
    "id": "41ca7fc2-72ba-4ca4-b2a6-c8bea60d6953",
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
    "id": "34b3f1f0-18c5-41e0-9223-b2176e05d00d",
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
    "id": "c718c818-675d-4394-9a70-431401e1b21b",
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