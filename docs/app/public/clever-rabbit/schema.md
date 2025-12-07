<!-- Auto-generated. Do not edit. -->

## clever_rabbit_line_items

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| order_id |  | not null, fk → clever_rabbit_orders |
| product_name | string | not null |
| quantity | integer | default: 1 |
| unit_price | decimal |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## clever_rabbit_orders

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| order_number | string | not null |
| status | string | default: pending |
| total | decimal |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## clever_rabbit_shipping_addresses

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| order_id |  | not null, fk → clever_rabbit_orders |
| street | string | not null |
| city | string | not null |
| postal_code | string | not null |
| country | string | not null |
| created_at | datetime | not null |
| updated_at | datetime | not null |
