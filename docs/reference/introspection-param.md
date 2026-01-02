---
order: 45
prev: false
next: false
---

# Introspection::Param

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L20)

Base class for parameter/field definitions.

Params are accessed via introspection - you never create them directly.

**Example: Accessing params via introspection**

```ruby
api = Apiwork::Introspection::API.new(MyApi)
action = api.resources[:invoices].actions[:show]
param = action.request.query[:page]
param.type         # => :integer
param.optional?    # => true
```

**Example: Type-specific subclasses**

```ruby
param = action.response.body  # => ArrayParam
param.of                      # => ObjectParam (element type)
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L118)

**Returns**

`Boolean` — whether this is an array type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L94)

**Returns**

`Object`, `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L100)

**Returns**

`Boolean` — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L76)

**Returns**

`Boolean` — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L82)

**Returns**

`String`, `nil` — field description

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L88)

**Returns**

`Object`, `nil` — example value

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L136)

**Returns**

`Boolean` — whether this is a literal type

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L64)

**Returns**

`Boolean` — whether this field can be null

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L124)

**Returns**

`Boolean` — whether this is an object type

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L70)

**Returns**

`Boolean` — whether this field is optional

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L112)

**Returns**

`Boolean` — whether this is a scalar type

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L106)

**Returns**

`String`, `nil` — discriminator tag for union variants

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L142)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L58)

**Returns**

`Symbol`, `nil` — type (:string, :integer, :array, :object, :union, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L130)

**Returns**

`Boolean` — whether this is a union type

---
