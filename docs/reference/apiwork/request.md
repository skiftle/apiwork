---
order: 85
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
request.query # => { page: 1 }
request.body # => { title: "Hello" }
```

**Example: Transforming keys**

```ruby
request.transform { |data| normalize(data) }
```

## Instance Methods

### #body

`#body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L28)

The body for this request.

**Returns**

`Hash`

---

### #initialize

`#initialize(body:, query:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L38)

Creates a new request context.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`body`** | `Hash` |  | The body parameters. |
| **`query`** | `Hash` |  | The query parameters. |

</div>

**Returns**

[Request](/reference/apiwork/request) — a new instance of Request

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L51)

Transforms both query and body with the same block.

**Returns**

[Request](/reference/apiwork/request)

**Example**

```ruby
request.transform { |data| normalize(data) }
```

---

### #transform_body

`#transform_body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L75)

Transforms only the body.

**Returns**

[Request](/reference/apiwork/request)

**Example**

```ruby
request.transform_body { |body| prepare(body) }
```

---

### #transform_query

`#transform_query`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/request.rb#L63)

Transforms only the query.

**Returns**

[Request](/reference/apiwork/request)

**Example**

```ruby
request.transform_query { |query| normalize(query) }
```

---
