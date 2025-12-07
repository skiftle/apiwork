<!-- Auto-generated. Do not edit. -->

## gentle_owl_comments

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| commentable_type | string | not null |
| commentable_id |  | not null |
| body | text | not null |
| author_name | string |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## gentle_owl_images

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| title | string | not null |
| url | string | not null |
| width | integer |  |
| height | integer |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## gentle_owl_posts

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| title | string | not null |
| body | text |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |

## gentle_owl_videos

| Column | Type | Constraints |
|--------|------|-------------|
| id |  | not null, primary key |
| title | string | not null |
| url | string | not null |
| duration | integer |  |
| created_at | datetime | not null |
| updated_at | datetime | not null |
