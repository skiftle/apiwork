---
order: 18
prev: false
next: false
---

# Adapter::Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/response.rb#L21)

Represents the response being processed through the adapter pipeline.

Response encapsulates the response body as it flows through
transformation hooks.

**Example: Creating a response context**

```ruby
response = Adapter::Response.new(body: { id: 1, title: "Hello" })
response.body  # => { id: 1, title: "Hello" }
```

**Example: In adapter hooks**

```ruby
def transform_response(response)
  Response.new(body: camelize_keys(response.body))
end
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/response.rb#L24)

**Returns**

`Hash` — the response body

---

### #initialize

`#initialize(body:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/response.rb#L30)

Creates a new response context.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | `Hash` | the response body |

**Returns**

[Response](adapter-response) — a new instance of Response

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/response.rb#L42)

Transforms the response body.

**Returns**

[Response](adapter-response) — new context with transformed body

**Example**

```ruby
response.transform { |data| camelize(data) }
```

---

### #transform_body

`#transform_body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/response.rb#L54)

Transforms the response body.

**Returns**

[Response](adapter-response) — new context with transformed body

**Example**

```ruby
response.transform_body { |data| camelize(data) }
```

---
