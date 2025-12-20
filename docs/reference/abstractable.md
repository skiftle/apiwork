---
order: 12
prev: false
next: false
---

# Abstractable

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/abstractable.rb#L27)

Concern that adds abstract class functionality.

Include this in base classes to mark them as abstract.
Abstract classes don't require a model and serve as base classes.

## Class Methods

### .abstract!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/abstractable.rb#L27)

Marks this class as abstract.

Abstract classes don't require a model and serve as base classes.
Subclasses automatically become non-abstract.

**Returns**

`void` — 

**Example**

```ruby
class ApplicationSchema < Apiwork::Schema::Base
  abstract!
end
```

---

### .abstract?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/abstractable.rb#L27)

Returns whether this class is abstract.

**Returns**

`Boolean` — true if abstract

---
