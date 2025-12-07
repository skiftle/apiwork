<!-- Auto-generated. Do not edit. -->

## eager_lion_customers

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| created_at | datetime | not null |
| name | string | not null |
| updated_at | datetime | not null |

## eager_lion_invoices

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| created_at | datetime | not null |
| customer_id | string | not null, fk → eager_lion_customers |
| issued_on | date |  |
| notes | string |  |
| number | string | not null |
| status | string |  |
| updated_at | datetime | not null |

## eager_lion_lines

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| created_at | datetime | not null |
| description | string |  |
| invoice_id | string | not null, fk → eager_lion_invoices |
| price | decimal |  |
| quantity | integer |  |
| updated_at | datetime | not null |
