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
      "id": "7dc2a155-4699-4f72-9fe3-0525a38fe661",
      "brand": "Tesla",
      "model": "Model 3",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "kind": "motorcycle",
      "id": "24b247ec-6001-45d9-b7e1-1fc3f942f196",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engine_cc": null
    },
    {
      "kind": "truck",
      "id": "3a483938-0d44-44e0-b8a0-98d52395dfa3",
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
GET /mighty-wolf/vehicles/2004b90d-cb03-4dd0-8842-3c9c264f3047
```

**Response** `200`

```json
{
  "vehicle": {
    "kind": "car",
    "id": "2004b90d-cb03-4dd0-8842-3c9c264f3047",
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
    "id": "274c0370-178d-49b9-a6a4-65039e45e810",
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
    "id": "30ae236c-0ba4-4075-a389-4436e94f9c4a",
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
    "id": "d7e5b9eb-9e58-4447-b509-694e9efb820a",
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