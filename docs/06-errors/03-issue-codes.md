# Issue Codes

## Contract Validation

| Code | Meaning |
|------|---------|
| `:field_missing` | Required field not provided |
| `:invalid_type` | Value cannot be coerced to declared type |
| `:invalid_value` | Value fails validation (enum, min, max, literal) |
| `:field_unknown` | Unknown field provided |
| `:value_null` | Null value when not nullable |
| `:string_too_short` | String shorter than min length |
| `:string_too_long` | String longer than max length |
| `:array_too_small` | Array has fewer than min items |
| `:array_too_large` | Array has more than max items |
| `:max_depth_exceeded` | Nested structure exceeds max depth |

## Filtering

| Code | Meaning |
|------|---------|
| `:field_not_filterable` | Field is not filterable |
| `:unknown_column_type` | Column type cannot be determined |
| `:unsupported_column_type` | Column type not supported for filtering |
| `:invalid_enum_value` | Invalid value for enum field |
| `:invalid_date_format` | Invalid date format |
| `:null_not_allowed` | Null not allowed for this operation |
| `:invalid_operator` | Invalid filter operator |
| `:invalid_filter_value_type` | Filter value has wrong type |
| `:invalid_numeric_format` | Invalid numeric format |

## Sorting

| Code | Meaning |
|------|---------|
| `:field_not_sortable` | Field is not sortable |
| `:invalid_sort_params_type` | Sort params must be a hash |
| `:invalid_sort_direction` | Sort direction must be 'asc' or 'desc' |
| `:invalid_sort_value_type` | Invalid value type for sort |
| `:association_not_sortable` | Association is not sortable |

## Associations

| Code | Meaning |
|------|---------|
| `:association_not_found` | Association does not exist |
| `:association_resource_not_found` | Associated resource not found |
| `:invalid_association` | Invalid association configuration |
| `:missing_nested_attributes` | Model missing accepts_nested_attributes_for |

## Schema Configuration

| Code | Meaning |
|------|---------|
| `:model_not_found` | Model class not found |
| `:invalid_attribute` | Invalid attribute configuration |
| `:invalid_polymorphic_option` | Invalid polymorphic configuration |
| `:invalid_include_option` | Invalid include option |

## Cursor Pagination

| Code | Meaning |
|------|---------|
| `:invalid_cursor` | Invalid or malformed cursor |
