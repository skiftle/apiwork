---
order: 17
prev: false
next: false
---

# Adapter::Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L27)

Represents the request being processed through the adapter pipeline.

Request encapsulates query parameters and request body as they
flow through normalization and preparation hooks. Each transformation
step receives a request and returns a new request.

**Example: Creating a request**

```ruby
request = Adapter::Request.new(query: { page: 1 }, body: { title: "Hello" })
request.query  # => { page: 1 }
request.body   # => { title: "Hello" }
```

**Example: In adapter hooks**

```ruby
def normalize_request(request)
  Request.new(
    query: transform(request.query),
    body: transform(request.body)
  )
end
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L34)

**Returns**

`Hash` — the request body

---

### #initialize

`#initialize(body:, query:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L41)

Creates a new request context.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query` | `Hash` | the query parameters |
| `body` | `Hash` | the request body |

**Returns**

[Request](adapter-request) — a new instance of Request

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L30)

**Returns**

`Hash` — the query parameters

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L54)

Transforms both query and body with the same block.

**Returns**

[Request](adapter-request) — new context with transformed data

**Example**

```ruby
request.transform { |data| normalize(data) }
```

---

### #transform_body

`#transform_body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L78)

Transforms only the body.

**Returns**

[Request](adapter-request) — new context with transformed body

**Example**

```ruby
request.transform_body { |b| prepare(b) }
```

---

### #transform_query

`#transform_query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/request.rb#L66)

Transforms only the query.

**Returns**

[Request](adapter-request) — new context with transformed query

**Example**

```ruby
request.transform_query { |q| normalize(q) }
```

---
