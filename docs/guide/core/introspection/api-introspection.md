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
api.resources[:invoices].actions.each do |name, action|
  puts "#{action.method.upcase} #{action.path}"
  # GET /invoices
  # POST /invoices
  # GET /invoices/:id
  # ...
end
```

Use `each_resource` to iterate all resources including nested:

```ruby
api.each_resource do |resource, parent_path|
  resource.actions.each do |name, action|
    puts "#{action.method.upcase} #{action.path}"
  end
end
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
