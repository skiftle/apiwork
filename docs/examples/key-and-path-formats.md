---
order: 15
---

# Key and Path Formats

PascalCase keys with `key_format :pascal` and kebab-case paths with `path_format :kebab`

## API Definition

<small>`config/apis/nimble_gecko.rb`</small>

<<< @/playground/config/apis/nimble_gecko.rb

## Models

<small>`app/models/nimble_gecko/meal_plan.rb`</small>

<<< @/playground/app/models/nimble_gecko/meal_plan.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| cook_time | integer | ✓ |  |
| created_at | datetime |  |  |
| serving_size | integer | ✓ |  |
| title | string |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/nimble_gecko/cooking_step.rb`</small>

<<< @/playground/app/models/nimble_gecko/cooking_step.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| duration_minutes | integer | ✓ |  |
| instruction | string |  |  |
| meal_plan_id | string |  |  |
| step_number | integer |  |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/nimble_gecko/meal_plan_representation.rb`</small>

<<< @/playground/app/representations/nimble_gecko/meal_plan_representation.rb

<small>`app/representations/nimble_gecko/cooking_step_representation.rb`</small>

<<< @/playground/app/representations/nimble_gecko/cooking_step_representation.rb

## Contracts

<small>`app/contracts/nimble_gecko/meal_plan_contract.rb`</small>

<<< @/playground/app/contracts/nimble_gecko/meal_plan_contract.rb

## Controllers

<small>`app/controllers/nimble_gecko/meal_plans_controller.rb`</small>

<<< @/playground/app/controllers/nimble_gecko/meal_plans_controller.rb

## Request Examples

::: details Create meal plan with PascalCase body

**Request**

```http
POST /nimble_gecko/meal-plans
Content-Type: application/json

{
  "MealPlan": {
    "Title": "Pasta Carbonara",
    "CookTime": 30,
    "ServingSize": 4,
    "CookingSteps": [
      {
        "StepNumber": 1,
        "Instruction": "Boil salted water",
        "DurationMinutes": 10
      },
      {
        "StepNumber": 2,
        "Instruction": "Cook pasta until al dente",
        "DurationMinutes": 8
      },
      {
        "StepNumber": 3,
        "Instruction": "Mix with egg yolk sauce",
        "DurationMinutes": 5
      }
    ]
  }
}
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

:::

::: details List meal plans

**Request**

```http
GET /nimble_gecko/meal-plans
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

:::

::: details Update meal plan with PascalCase body

**Request**

```http
PATCH /nimble_gecko/meal-plans/60e6912b-2e98-5f0c-892b-391c9c742417
Content-Type: application/json

{
  "MealPlan": {
    "CookTime": 25,
    "ServingSize": 6
  }
}
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/nimble-gecko/introspection.json

:::

::: details TypeScript

<<< @/playground/public/nimble-gecko/typescript.ts

:::

::: details Zod

<<< @/playground/public/nimble-gecko/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/nimble-gecko/openapi.yml

:::