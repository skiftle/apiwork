<!-- Auto-generated. Do not edit. -->

## swift_fox_contacts

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| name | string | not null |
| email | string |  |
| phone | string |  |
| notes | string |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## swift_fox_posts

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | not null, primary key |
| title | string | not null |
| body | text |  |
| status | string | default: draft |
| created_at | datetime | not null |
| updated_at | datetime | not null |
