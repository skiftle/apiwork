# Integration Test Gap Analysis

## Summary

56 integration test files covering ~300+ test cases. Most @api public features have coverage, but several gaps exist.

**All features listed as gaps are confirmed to exist in lib/apiwork.** They just lack integration tests.

---

## Well Covered Features

### API Module
| Feature | Test File |
|---------|-----------|
| `resource` | api/standard_crud_endpoints_spec.rb |
| `key_format` | export/key_transformation_spec.rb |
| `adapter` | adapter/configuration_integration_spec.rb |
| `type/enum/union` | contract/custom_types_spec.rb, contract/literal_and_discriminated_union_spec.rb |
| `raises` | contract/error_codes_spec.rb |
| `info` | export/openapi_generation_spec.rb |
| `concern` | api/concerns_integration_spec.rb |
| `export` | export/openapi_generation_spec.rb, export/typescript_generation_spec.rb |
| nested resources | api/nested_resources_spec.rb |
| routing options | api/routing_dsl_override_spec.rb |

### Contract Module
| Feature | Test File |
|---------|-----------|
| `action` | contract/custom_actions_spec.rb |
| `scope` | contract/custom_type_scoping_spec.rb |
| `imports` | contract/contract_imports_spec.rb |
| `infer_schema` | contract/contract_override_spec.rb |
| input validation | contract/input_validation_spec.rb |
| action metadata | contract/action_metadata_spec.rb |
| format validation | contract/format_validation_spec.rb |
| min/max validation | contract/min_max_validation_spec.rb, contract/numeric_validation_spec.rb |
| writable context | contract/writable_context_spec.rb |
| serialization | contract/serialization_spec.rb |

### Schema Module
| Feature | Test File |
|---------|-----------|
| `model` | schema/missing_model_error_spec.rb |
| `root` | api/root_key_override_spec.rb |
| `attribute` | api/standard_crud_endpoints_spec.rb, schema/nullable_attribute_spec.rb |
| `has_many/belongs_to` | adapter/includes_spec.rb, adapter/association_filtering_spec.rb |
| nested attributes | schema/nested_attributes_spec.rb |
| `discriminator/variant` | schema/sti_spec.rb |
| `encode/decode` | schema/encode_decode_spec.rb |
| polymorphic | schema/polymorphic_associations_spec.rb |
| abstract base | schema/abstract_base_schema_spec.rb |

### Adapter Module
| Feature | Test File |
|---------|-----------|
| filtering | adapter/filtering_spec.rb, adapter/advanced_filtering_spec.rb, adapter/filter_operators_spec.rb |
| sorting | adapter/sorting_spec.rb, adapter/association_sorting_spec.rb |
| pagination | adapter/pagination_spec.rb, adapter/cursor_pagination_spec.rb |
| includes | adapter/includes_spec.rb |
| configuration | adapter/configuration_integration_spec.rb |
| validation errors | adapter/filter_validation_errors_spec.rb |

### Introspection Module
| Feature | Test File |
|---------|-----------|
| API.introspect | introspection/introspection_spec.rb |
| Contract.introspect | introspection/introspection_spec.rb |
| actions/types/enums | introspection/introspection_spec.rb |

### Controller Module
| Feature | Test File |
|---------|-----------|
| `context` | api/controller_context_spec.rb |
| `expose/expose_error` | api/error_response_spec.rb |

---

## Gaps - Missing Integration Tests

### Priority 1: Missing Features

#### 1. API.resource (singular resource)
No test for singular resources (e.g., `/api/v1/profile` without `:id`).

```ruby
# Expected usage
resource :profile do
  schema ProfileSchema
  contract ProfileContract
end
```

**Test needed:** Verify singular resource routing, CRUD without index/`:id`, serialization.

#### 2. Zod Export
Only TypeScript and OpenAPI exports are tested. No Zod tests.

**Test needed:** `spec/integration/export/zod_generation_spec.rb`

#### 3. has_one Association
No dedicated test. Only has_many and belongs_to are tested.

```ruby
# Expected usage
has_one :profile
```

**Test needed:** Verify has_one serialization, includes, filtering.

#### 4. skip_contract_validation!
Controller class method not tested.

```ruby
# Expected usage
class PostsController < ApplicationController
  include Apiwork::Controller
  skip_contract_validation! only: [:legacy_action]
end
```

**Test needed:** Verify contract validation is skipped for specified actions.

### Priority 2: Incomplete Coverage

#### 5. API.path_format
Only `key_format` is tested. `path_format` for URL path transformation is not.

```ruby
# Expected usage
path_format :dasherize  # /user-profiles instead of /user_profiles
```

**Test needed:** Verify path segments are transformed correctly.

#### 6. Schema.description
Not tested in introspection/export output.

```ruby
# Expected usage
class PostSchema < Apiwork::Schema::Base
  description 'A blog post'
end
```

**Test needed:** Verify description appears in introspection and OpenAPI.

#### 7. Schema.example
Not tested in introspection/export output.

```ruby
# Expected usage
class PostSchema < Apiwork::Schema::Base
  example { title: 'Hello World' }
end
```

**Test needed:** Verify example appears in OpenAPI schemas.

#### 8. Schema.deprecated
Only action-level deprecation tested. Schema-level not tested.

```ruby
# Expected usage
class LegacySchema < Apiwork::Schema::Base
  deprecated
end
```

**Test needed:** Verify schema deprecation in introspection/OpenAPI.

### Priority 3: Edge Cases

#### 9. Introspection Param Types
Many param types not explicitly tested in introspection:
- `time`, `uuid`, `binary`, `decimal`
- Only string, integer, boolean, date, datetime are covered

**Test needed:** Verify introspection output for all param types.

#### 10. Nested Resources with Includes
Not tested: includes parameter on nested routes.

```
GET /posts/1/comments?include=author
```

**Test needed:** Verify includes work on nested resources.

#### 11. Custom Adapter Subclassing
No test for creating custom adapters.

```ruby
class JsonApiAdapter < Apiwork::Adapter::Base
  adapter_name :json_api
end
```

**Test needed:** Verify custom adapter registration and rendering.

---

## Implementation Order

### Phase 1: Core Missing Features (Priority 1)
1. **API.resource (singular)** - Create Profile model/schema/contract in dummy app, test CRUD
2. **Zod Export** - Write zod_generation_spec.rb mirroring typescript_generation_spec.rb
3. **has_one Association** - Add has_one to existing schemas, test serialization/includes
4. **skip_contract_validation!** - Add controller action that skips validation

### Phase 2: Metadata & Export Quality (Priority 2)
5. **path_format** - Test :kebab and other path transformations
6. **Schema.description** - Add descriptions to schemas, verify in OpenAPI
7. **Schema.example** - Add examples, verify in OpenAPI
8. **Schema.deprecated** - Mark schema deprecated, verify in exports

### Phase 3: Coverage Completeness (Priority 3)
9. **Introspection param types** - Add uuid/decimal/time columns, verify introspection
10. **Nested resources with includes** - Test include param on nested routes
11. **Custom adapter** - Create test adapter subclass

---

## Required Dummy App Changes

### For API.resource (singular):
```ruby
# db/migrate - Create profiles table
# app/models/profile.rb
# app/schemas/api/v1/profile_schema.rb
# app/contracts/api/v1/profile_contract.rb
# config/apis/v1.rb - Add resource :profile
```

### For has_one:
```ruby
# Add to existing model: has_one :settings or similar
# Update schema with has_one declaration
```

### For path_format:
```ruby
# Create new API with path_format :kebab
# Test /user-profiles route instead of /user_profiles
```

---

## Next Steps

1. Create dummy app fixtures for missing features
2. Write integration tests in priority order
3. Verify each feature works end-to-end via `bundle exec rspec spec/integration/`
