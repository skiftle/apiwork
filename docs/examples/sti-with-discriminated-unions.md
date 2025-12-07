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
      "id": "145ae747-c0e4-446f-95d1-695b1642281a",
      "brand": "Tesla",
      "model": "Model 3",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "kind": "motorcycle",
      "id": "f333aa29-f308-4b1c-bf68-058a850f9388",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engine_cc": null
    },
    {
      "kind": "truck",
      "id": "9b7db6df-877a-4e1f-8e48-b72434fc155b",
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
GET /mighty-wolf/vehicles/2d022142-341f-4648-b3b1-e3905c939368
```

**Response** `200`

```json
{
  "vehicle": {
    "kind": "car",
    "id": "2d022142-341f-4648-b3b1-e3905c939368",
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
    "id": "93608c46-1ca6-40d0-922f-dfa10670c707",
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
    "id": "0d30c286-c40c-4908-8976-acea73e365b9",
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
    "id": "d29a059f-5426-4734-98da-d748371280dd",
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