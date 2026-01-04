---
order: 2
---

# API Introspection

Returns the complete API structure as an [Introspection::API](../../../reference/introspection-api.md) object.

```ruby
api = Apiwork::API.introspect('/api/v1')
```

---

## Accessors

| Method | Returns |
|--------|---------|
| `path` | API mount path |
| `info` | [Info](../../../reference/introspection-api-info.md) object |
| `resources` | Hash of [Resource](../../../reference/introspection-api-resource.md) objects |
| `types` | Hash of [Type](../../../reference/introspection-type.md) objects |
| `enums` | Hash of [Enum](../../../reference/introspection-enum.md) objects |
| `error_codes` | Hash of [ErrorCode](../../../reference/introspection-error-code.md) objects |
| `raises` | Array of API-level error code symbols |

---

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

---

## Actions

```ruby
action = api.resources[:invoices].actions[:create]

action.method     # => :post
action.path       # => "/invoices"
action.raises     # => [:bad_request, :not_found, :unprocessable_entity]
action.deprecated? # => false
```

---

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

---

## Locale

Pass `locale:` for translated descriptions:

```ruby
api = Apiwork::API.introspect('/api/v1', locale: :sv)
```

Translations come from your I18n files. See [i18n](../../advanced/i18n.md) for configuration.

---

## Caching

Results are cached per path and locale. In development, Rails reloading clears caches automatically.
