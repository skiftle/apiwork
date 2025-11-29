# Introspection

Apiwork provides introspection methods to inspect your API at runtime.

## API Introspection

```ruby
api_class = Apiwork::API::Registry.find('/api/v1')

Apiwork::Introspection.api(api_class)
# Returns full API structure: resources, actions, types, enums
```

## Contract Introspection

```ruby
Apiwork::Introspection.contract(PostContract)
# Returns contract definition with all actions

Apiwork::Introspection.contract(PostContract, action: :create)
# Returns only the create action definition
```

## Types and Enums

```ruby
api_class = Apiwork::API::Registry.find('/api/v1')

Apiwork::Introspection.types(api_class)
# Returns all registered types

Apiwork::Introspection.enums(api_class)
# Returns all registered enums
```

## Action Definition

```ruby
action_def = PostContract.action_definition(:create)

Apiwork::Introspection.action_definition(action_def)
# Returns serialized action definition
```

## API Shortcut

The API class has an `introspect` method:

```ruby
api_class = Apiwork::API::Registry.find('/api/v1')
api_class.introspect
# Same as Apiwork::Introspection.api(api_class)
```

## Use Cases

- Debugging API structure
- Building custom documentation
- Generating client code
- Testing that definitions are correct
- Admin interfaces

## Output Structure

```ruby
Apiwork::Introspection.api(api_class)
# {
#   resources: {
#     posts: { path: "/posts", actions: {...} },
#     comments: { path: "/comments", actions: {...} }
#   },
#   types: {
#     address: { type: :object, shape: {...} },
#     ...
#   },
#   enums: {
#     status: { values: ["draft", "published"] },
#     ...
#   }
# }
```
