---
order: 73
prev: false
next: false
---

# Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L16)

Represents the response being processed through the adapter pipeline.

Response encapsulates the response body as it flows through
transformation hooks.

**Example: Creating a response**

```ruby
response = Response.new(body: { id: 1, title: "Hello" })
response.body  # => { id: 1, title: "Hello" }
```

**Example: Transforming keys**

```ruby
response.transform { |data| camelize(data) }
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L19)

**Returns**

`Hash` — the response body

---

### #initialize

`#initialize(body:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L25)

Creates a new response context.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `body` | `Hash` | the response body |

**Returns**

[Response](response) — a new instance of Response

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L37)

Transforms the response body.

**Returns**

[Response](response) — new context with transformed body

**Example**

```ruby
response.transform { |data| camelize(data) }
```

---

### #transform_body

`#transform_body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L49)

Transforms the response body.

**Returns**

[Response](response) — new context with transformed body

**Example**

```ruby
response.transform_body { |data| camelize(data) }
```

---
