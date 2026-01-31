---
order: 72
prev: false
next: false
---

# Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L18)

Represents the request being processed through the adapter pipeline.

Request encapsulates query parameters and request body as they
flow through normalization and preparation hooks. Each transformation
step receives a request and returns a new request.

**Example: Creating a request**

```ruby
request = Request.new(query: { page: 1 }, body: { title: "Hello" })
request.query  # => { page: 1 }
request.body   # => { title: "Hello" }
```

**Example: Transforming keys**

```ruby
request.transform { |data| normalize(data) }
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L25)

**Returns**

`Hash` — the request body

---

### #initialize

`#initialize(body:, query:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L32)

Creates a new request context.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query` | `Hash` | the query parameters |
| `body` | `Hash` | the request body |

**Returns**

[Request](request) — a new instance of Request

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L21)

**Returns**

`Hash` — the query parameters

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L45)

Transforms both query and body with the same block.

**Returns**

[Request](request) — new context with transformed data

**Example**

```ruby
request.transform { |data| normalize(data) }
```

---

### #transform_body

`#transform_body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L69)

Transforms only the body.

**Returns**

[Request](request) — new context with transformed body

**Example**

```ruby
request.transform_body { |b| prepare(b) }
```

---

### #transform_query

`#transform_query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L57)

Transforms only the query.

**Returns**

[Request](request) — new context with transformed query

**Example**

```ruby
request.transform_query { |q| normalize(q) }
```

---
