---
order: 71
prev: false
next: false
---

# Request

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L17)

Immutable value object representing a request.

Encapsulates query and body parameters. Transformations return
new instances, preserving immutability.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L24)

**Returns**

`Hash` — the body parameters

---

### #initialize

`#initialize(body:, query:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L31)

Creates a new request context.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query` | `Hash` | the query parameters |
| `body` | `Hash` | the body parameters |

**Returns**

[Request](request) — a new instance of Request

---

### #query

`#query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L20)

**Returns**

`Hash` — the query parameters

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L44)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L68)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L56)

Transforms only the query.

**Returns**

[Request](request) — new context with transformed query

**Example**

```ruby
request.transform_query { |q| normalize(q) }
```

---
