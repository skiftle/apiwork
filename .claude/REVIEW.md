# REVIEW.md

Checklista för kodgranskning. Använd detta dokument för att verifiera att koden följer projektets konventioner.

---

## Namngivning

### Boolean-metoder och variabler

- **Metoder:** Använd `?` suffix, inte `is_` prefix
- **Instansvariabler:** Substantiv utan prefix

```ruby
# ❌ Java-style
@is_active
def is_valid?

# ✅ Ruby-style
@active
def valid?
```

### Klassreferenser

- Variabler som håller klassreferenser ska ha `_class` suffix

```ruby
# ❌
@schema
@contract

# ✅
@schema_class
@contract_class
```

### Parameter-till-instansvariabel

- Om en parameter tilldelas direkt till en instansvariabel, använd samma namn

```ruby
# ❌ Inkonsekvent
def initialize(schema_class)
  @owner_schema_class = schema_class
end

# ✅ Konsekvent
def initialize(owner_schema_class)
  @owner_schema_class = owner_schema_class
end
```

### Inga förkortningar

- Skriv ut hela ord

```ruby
# ❌
assoc_def
attr_def
param_val

# ✅
association_definition
attribute_definition
parameter_value
```

---

## Blockparametrar

### Undvik underscore för oanvända parametrar

- Omstrukturera för att undvika behovet

```ruby
# ❌
hash.any? { |_, value| value.active? }

# ✅
hash.values.any?(&:active?)
```

### Namnge alltid blockparametrar

```ruby
# ❌
items.map { |_1| _1.name }

# ✅
items.map { |item| item.name }
```

---

## Intermediate Variables

### Skapa bara när det ger klarhet

- Komplexa uttryck som behöver ett namn
- Kedjor med 3+ metodanrop

### Skapa inte för

- Enkla metodanrop som används 1-2 gånger
- Uttryck som redan är tydliga från kontexten

```ruby
# ❌ Onödig variabel
schema_class = definition.schema_class
serialize(schema_class)

# ✅ Direkt användning
serialize(definition.schema_class)

# ✅ Motiverad variabel (komplext uttryck)
filtered_active_users = users.select(&:active?).reject(&:banned?).sort_by(&:name)
```

---

## Dokumentation

### Synlighetsnivåer

| Nivå | YARD | Kommentarer |
|------|------|-------------|
| `@api public` | Ja | Ja |
| Semi-public | Nej | Nej |
| Private | Nej | Nej |

### Semi-public metoder

- Metoder som behövs internt mellan klasser men inte är del av publikt API
- Använd `attr_writer` eller `attr_accessor` istället för `attr_reader` + manuell setter
- **Ingen dokumentation överhuvudtaget**

```ruby
# ❌ Semi-public med dokumentation
# Sets the visited types for cycle detection.
attr_writer :visited_types

# ✅ Semi-public utan dokumentation
attr_writer :visited_types
```

---

## Class Layout

Ordning inom en klass:

1. Constants (`ALLOWED_FORMATS = ...`)
2. `class_attribute` / `attr_*` deklarationer
3. `class << self` block (om det finns)
4. `initialize`
5. Public instance methods
6. `private`
7. Private methods

```ruby
class Example
  CONSTANT = 'value'.freeze

  attr_reader :name, :type
  attr_writer :internal_state

  class << self
    def build(...)
    end
  end

  def initialize(name)
    @name = name
  end

  def process
  end

  private

  def validate!
  end
end
```

---

## Defensive Code

### Undvik

| Pattern | Problem |
|---------|---------|
| `value&.method` | Döljer nil där nil inte borde vara |
| `value \|\| default` | Döljer oväntad nil |
| `respond_to?(:method)` | Metoden borde alltid finnas |
| `x == false` | Använd `unless x` |

### Defaults i signaturen

```ruby
# ❌ Defensive default
def initialize(active: nil)
  @active = active || false
end

# ✅ Default i signatur
def initialize(active: false)
  @active = active
end
```

### Undantag: Detekteringslogik

När `nil` betyder "inte angiven" och behöver skiljas från `false`:

```ruby
def initialize(optional: nil)
  optional = detect_optional if optional.nil?
  optional = false if optional.nil?  # Fallback efter detektion
  @optional = optional
end
```

---

## Guards

### En guard per rad

```ruby
# ❌
return if abstract? || @model_class.nil?

# ✅
return if abstract?
return if @model_class.nil?
```

### Positiv logik

```ruby
# ❌
if !user.active?
unless user.active? && user.verified?

# ✅
unless user.active?
if user.inactive? || user.unverified?
```
