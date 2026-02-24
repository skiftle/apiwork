---
order: 11
prev: false
next: false
---

# Adapter

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L5)

## Modules

- [Base](./base)
- [Builder](./builder/)
- [Capability](./capability/)
- [Serializer](./serializer/)
- [Wrapper](./wrapper/)

## Class Methods

### .find

`.find(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L36)

Finds an adapter by name.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The adapter name. |

</div>

**Returns**

Class&lt;[Adapter::Base](/reference/adapter/base)&gt;, `nil`

**See also**

- [.find!](#find!)

**Example**

```ruby
Apiwork::Adapter.find(:standard)
```

---

### .find!

`.find!(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L36)

Finds an adapter by name.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The adapter name. |

</div>

**Returns**

Class&lt;[Adapter::Base](/reference/adapter/base)&gt;

**See also**

- [.find](#find)

**Example**

```ruby
Apiwork::Adapter.find!(:standard)
```

---

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter.rb#L36)

Registers an adapter.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`klass`** | `Class<Adapter::Base>` |  | The adapter class with adapter_name set. |

</div>

**See also**

- [Adapter::Base](/reference/adapter/base)

**Example**

```ruby
Apiwork::Adapter.register(JSONAPIAdapter)
```

---
