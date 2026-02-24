---
order: 78
prev: false
next: false
---

# Issue

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L9)

Represents a validation issue found during request parsing.

Issues are returned when request parameters fail validation,
coercion, or constraint checks. Access via `contract.issues`.

## Instance Methods

### #as_json

`#as_json`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L68)

Converts this issue to a hash for JSON serialization.

**Returns**

`Hash`

---

### #code

`#code`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L30)

The code for this issue.

**Returns**

`Symbol`

---

### #detail

`#detail`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L30)

The detail for this issue.

**Returns**

`String`

---

### #meta

`#meta`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L30)

The meta for this issue.

**Returns**

`Hash`

---

### #pointer

`#pointer`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L46)

The pointer for this issue.

**Returns**

`String`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L54)

Converts this issue to a hash.

**Returns**

`Hash`

---

### #to_s

`#to_s`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L76)

Converts this issue to a string.

**Returns**

`String`

---
