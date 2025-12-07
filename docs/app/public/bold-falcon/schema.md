<!-- Auto-generated. Do not edit. -->

## bold_falcon_articles

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| category_id |  | fk → bold_falcon_categories |
| title | string | not null |
| body | text |  |
| status | string | default: draft |
| view_count | integer | default: 0 |
| rating | decimal |  |
| published_on | date |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## bold_falcon_categories

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| name | string | not null |
| slug | string | not null |
| created_at | datetime | not null |
| updated_at | datetime | not null |
