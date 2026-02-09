---
order: 86
prev: false
next: false
---

# Response

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L16)

Immutable value object representing a response.

Encapsulates body parameters. Transformations return new instances,
preserving immutability.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L21)

The body for this response.

**Returns**

`Hash`

---

### #initialize

`#initialize(body:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L27)

Creates a new response context.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`body`** | `Hash` |  | the body parameters |

</div>

**Returns**

[Response](/reference/response) — a new instance of Response

---

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L39)

Transforms the body parameters.

**Returns**

[Response](/reference/response)

**Example**

```ruby
response.transform { |data| camelize(data) }
```

---

### #transform_body

`#transform_body`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/response.rb#L51)

Transforms the body parameters.

**Returns**

[Response](/reference/response)

**Example**

```ruby
response.transform_body { |data| camelize(data) }
```

---
