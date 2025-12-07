<!-- Auto-generated. Do not edit. -->

## happy_zebra_comments

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| post_id | string | not null, fk → happy_zebra_posts |
| body | string | not null |
| author | string | not null |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## happy_zebra_posts

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| user_id | string | not null, fk → happy_zebra_users |
| title | string | not null |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## happy_zebra_profiles

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| user_id | string | not null, fk → happy_zebra_users |
| bio | text |  |
| website | string |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## happy_zebra_users

| Column | Type | Constraints |
|--------|------|-------------|
| id | string | not null, primary key |
| email | string | not null |
| username | string | not null |
| created_at | datetime | not null |
| updated_at | datetime | not null |
