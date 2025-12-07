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
  "vehicles": [],
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
GET /mighty-wolf/vehicles/aeecd6f4-32aa-4261-9170-052d5b71eae4
```

**Response** `200`

```json
{
  "vehicle": {
    "kind": "car",
    "id": "aeecd6f4-32aa-4261-9170-052d5b71eae4",
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

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
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

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
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

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
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