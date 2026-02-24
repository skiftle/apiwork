---
order: 9
---

# Single Table Inheritance

Single Table Inheritance with automatic variant serialization and TypeScript union types

## API Definition

<small>`config/apis/mighty_wolf.rb`</small>

<<< @/playground/config/apis/mighty_wolf.rb

## Models

<small>`app/models/mighty_wolf/vehicle.rb`</small>

<<< @/playground/app/models/mighty_wolf/vehicle.rb

::: details Database Table

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

:::

<small>`app/models/mighty_wolf/car.rb`</small>

<<< @/playground/app/models/mighty_wolf/car.rb

<small>`app/models/mighty_wolf/truck.rb`</small>

<<< @/playground/app/models/mighty_wolf/truck.rb

<small>`app/models/mighty_wolf/motorcycle.rb`</small>

<<< @/playground/app/models/mighty_wolf/motorcycle.rb

## Representations

<small>`app/representations/mighty_wolf/vehicle_representation.rb`</small>

<<< @/playground/app/representations/mighty_wolf/vehicle_representation.rb

<small>`app/representations/mighty_wolf/car_representation.rb`</small>

<<< @/playground/app/representations/mighty_wolf/car_representation.rb

<small>`app/representations/mighty_wolf/truck_representation.rb`</small>

<<< @/playground/app/representations/mighty_wolf/truck_representation.rb

<small>`app/representations/mighty_wolf/motorcycle_representation.rb`</small>

<<< @/playground/app/representations/mighty_wolf/motorcycle_representation.rb

## Contracts

<small>`app/contracts/mighty_wolf/vehicle_contract.rb`</small>

<<< @/playground/app/contracts/mighty_wolf/vehicle_contract.rb

## Controllers

<small>`app/controllers/mighty_wolf/vehicles_controller.rb`</small>

<<< @/playground/app/controllers/mighty_wolf/vehicles_controller.rb

## Request Examples

::: details List all vehicles

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
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "doors": 4
    },
    {
      "type": "motorcycle",
      "id": "7806556d-7175-57da-9ab8-a1d92437b144",
      "brand": "Harley-Davidson",
      "model": "Street Glide",
      "year": null,
      "color": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "engineCc": 1868
    },
    {
      "type": "truck",
      "id": "0cfa971d-c697-5cff-be68-cf775df891c1",
      "brand": "Ford",
      "model": "F-150",
      "year": null,
      "color": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "payloadCapacity": "5000.0"
    }
  ],
  "pagination": {
    "items": 3,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

:::

::: details Get vehicle details

**Request**

```http
GET /mighty_wolf/vehicles/7900de74-233c-5bc9-bc0c-6679f7a345a5
```

**Response** `200`

```json
{
  "vehicle": {
    "type": "car",
    "id": "7900de74-233c-5bc9-bc0c-6679f7a345a5",
    "brand": "Volvo",
    "model": "EX30",
    "year": 2024,
    "color": "red",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "doors": 4
  }
}
```

:::

::: details Create a car

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
    "color": "red",
    "doors": 4
  }
}
```

**Response** `201`

```json
{
  "vehicle": {
    "type": "car",
    "id": "7900de74-233c-5bc9-bc0c-6679f7a345a5",
    "brand": "Volvo",
    "model": "EX30",
    "year": 2024,
    "color": "red",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "doors": 4
  }
}
```

:::

::: details Create a truck

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
    "color": "blue",
    "payloadCapacity": 5000
  }
}
```

**Response** `201`

```json
{
  "vehicle": {
    "type": "truck",
    "id": "0cfa971d-c697-5cff-be68-cf775df891c1",
    "brand": "Ford",
    "model": "F-150",
    "year": 2024,
    "color": "blue",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "payloadCapacity": "5000.0"
  }
}
```

:::

::: details Filter by vehicle type

**Request**

```http
GET /mighty_wolf/vehicles?filter[type][eq]=car
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
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "doors": null
    }
  ],
  "pagination": {
    "items": 1,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/mighty-wolf/introspection.json

:::

::: details TypeScript

<<< @/playground/public/mighty-wolf/typescript.ts

:::

::: details Zod

<<< @/playground/public/mighty-wolf/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/mighty-wolf/openapi.yml

:::