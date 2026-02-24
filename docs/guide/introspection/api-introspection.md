---
order: 2
---

# API Introspection

API introspection returns the complete API structure as an [Introspection::API](../../reference/introspection/api/) object.

```ruby
api = Apiwork::API.introspect('/api/v1')
```

## Accessors

| Method        | Returns                                                                      |
| ------------- | ---------------------------------------------------------------------------- |
| `base_path`   | API base path                                                                |
| `info`        | [Info](../../reference/introspection/api/info/) object                    |
| `resources`   | Hash of [Resource](../../reference/introspection/api/resource.md) objects |
| `types`       | Hash of [Type](../../reference/introspection/type.md) objects             |
| `enums`       | Hash of [Enum](../../reference/introspection/enum.md) objects             |
| `error_codes` | Hash of [ErrorCode](../../reference/introspection/error-code.md) objects  |
| `raises`      | Array of API-level error code symbols                                        |

## Resources

```ruby
resource = api.resources[:invoices]

resource.identifier         # => "invoices"
resource.path               # => "invoices"
resource.parent_identifiers # => []
resource.resources          # => {} or nested resources
resource.actions            # => { index: Action, show: Action, ... }
```

For nested resources:

```ruby
comments = api.resources[:posts].resources[:comments]

comments.identifier         # => "comments"
comments.parent_identifiers # => ["posts"]
```

## Info

The `info` object exposes API metadata:

```ruby
info = api.info

info.title              # => "My API"
info.version            # => "1.0.0"
info.description        # => "Full description"
info.summary            # => "Short summary"
info.terms_of_service   # => "https://example.com/tos"
```

Nested objects for contact, license, and servers:

```ruby
info.contact&.name      # => "API Support"
info.contact&.email     # => "api@example.com"
info.contact&.url       # => "https://example.com/support"

info.license&.name      # => "MIT"
info.license&.url       # => "https://opensource.org/licenses/MIT"

info.servers.each do |server|
  server.url            # => "https://api.example.com"
  server.description    # => "Production"
end
```

## Actions

```ruby
action = api.resources[:invoices].actions[:create]

action.method       # => :post
action.path         # => "/invoices"
action.raises       # => [:bad_request, :not_found, :unprocessable_entity]
action.deprecated?  # => false
action.tags         # => ["Invoices"]
action.operation_id # => "createInvoice"
action.summary      # => "Create a new invoice"
action.description  # => "Creates an invoice and returns it"
```

## Request and Response

```ruby
request = action.request
request.query?  # => false
request.body?   # => true

request.body.each do |name, param|
  puts "#{name}: #{param.type}"
end
```

```ruby
response = action.response
response.no_content?  # => false

body = response.body
body.object?          # => true
body.shape[:invoice]  # => Param for the invoice
```

## Error Codes

```ruby
error_code = api.error_codes[:not_found]

error_code.status      # => 404
error_code.description # => "Not found"
```

## Locale

The `locale:` option produces translated descriptions:

```ruby
api = Apiwork::API.introspect('/api/v1', locale: :sv)
```

Translations come from I18n files.

## Caching

Results are cached per path and locale. In development, Rails reloading clears caches automatically.

#### See also

- [Introspection::API reference](../../reference/introspection/api/) — all introspection methods
