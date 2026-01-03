---
order: 55
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L53)

**Returns**

`Hash` — alias for to_h, for JSON serialization

---

### #code

`#code`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L12)

**Returns**

`Symbol` — the error code (e.g., :required, :type_mismatch)

---

### #detail

`#detail`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L16)

**Returns**

[String](introspection-string) — human-readable error message

---

### #meta

`#meta`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L20)

**Returns**

`Hash` — additional context about the error

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L24)

**Returns**

`Array<Symbol`, `Integer>` — path to the invalid field

---

### #pointer

`#pointer`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L35)

**Returns**

[String](introspection-string) — JSON Pointer to the invalid field (e.g., "/user/email")

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L41)

**Returns**

`Hash` — hash representation with code, detail, path, pointer, meta

---

### #to_s

`#to_s`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/issue.rb#L59)

**Returns**

[String](introspection-string) — human-readable string representation

---
