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

<small>`app/contracts/mighty_wolf/car_contract.rb`</small>

<<< @/playground/app/contracts/mighty_wolf/car_contract.rb

<small>`app/contracts/mighty_wolf/truck_contract.rb`</small>

<<< @/playground/app/contracts/mighty_wolf/truck_contract.rb

<small>`app/contracts/mighty_wolf/motorcycle_contract.rb`</small>

<<< @/playground/app/contracts/mighty_wolf/motorcycle_contract.rb

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
      "id": "7900de74-233c-5bc9-bc0c-6679f7a345a5",
      "brand": "Volvo",
      "model": "EX30",
      "year": null,
      "color": null,
      "doors": null
    },
    {
      "type": "motorcycle",
      "id": "7806556d-7175-57da-9ab8-a1d92437b144",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "engineCc": null
    },
    {
      "type": "truck",
      "id": "0cfa971d-c697-5cff-be68-cf775df891c1",
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
GET /mighty_wolf/vehicles/244334d1-b797-570d-8abf-3244124aa288
```

**Response** `200`

```json
{
  "vehicle": {
    "type": "car",
    "id": "244334d1-b797-570d-8abf-3244124aa288",
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
    "id": "28dc3c84-70c5-5b7c-974d-5295a40b1648",
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
    "id": "5f50c425-905a-59fb-aed6-64946b81714e",
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
    "id": "bc709869-2a84-54ce-8bad-69ffeb2112d5",
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