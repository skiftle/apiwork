---
order: 1
---

# Introduction

Apiwork is a contract-driven API layer for Rails. It sits at the boundary — where data comes in and goes out. You describe the shape once, and every client knows what to expect. That’s really the whole idea. Rails handles the inside of your app extremely well; Apiwork helps Rails speak more clearly at the edges.

---

# The Problem

Inside Rails, Ruby’s flexibility is a strength. Conventions carry a lot of weight. You call `post.author` and Rails knows how to find the right object. The types are implicit and Rails doesn’t need them written down.

But the moment the data leaves your app, those conventions don’t help anyone. A client has no built-in understanding of what your API returns, so you end up documenting it manually — an OpenAPI file here, some TypeScript interfaces there, maybe a Zod schema to be safe. Now you have two descriptions of the same thing: your models, and the specs you’ve written by hand. They drift. It’s almost unavoidable.

## The “alternative”

You could run your backend in TypeScript instead. It’s a good ecosystem, and the type system does help as a project grows. But the cost isn’t TypeScript itself — it’s everything you lose by stepping away from Rails: migrations, Active Record, background jobs, helpers, caching, test tools, and the simple speed of getting things done with a small team. Rails is good at the things around your API. What it doesn’t have is a structured way to describe the API boundary.

---

# The Solution

**Define it once. Use it everywhere.**

Apiwork gives Rails a small, focused language for describing the API boundary. Nothing more. You still write Rails as you always have — models, controllers, business logic — but now the edge of your API has a clear definition.

Apiwork consists of four parts:

### **1. API Definition**

Defines the overall shape: which resources exist and which actions they offer.

### **2. Contracts**

Describe exactly what an action accepts and returns. This alone removes the drift between “what Rails does” and “what the docs say”.

```ruby
class PostContract < Apiwork::Contract
  action :index do
    response { array(:post) }
  end
end
```

### **3. Schemas**

Schemas connect your models to your contracts. Most structure is inherited from the database, so you only specify what you want to expose. This makes it easy to mark fields as filterable, writable, sortable, and so on.

### **4. The Adapter**

Reads your contracts and schemas and handles the common API behaviors — filtering, sorting, pagination, eager loading. You can use the built-in adapter or provide your own. Schemas and adapters are optional; you can start small and add them only when they’re useful.

---

# One Source of Truth

When you put these pieces together, you get a single description of your API. That one description powers request and response validation, runtime behavior, and generation of OpenAPI, Zod schemas, and TypeScript types. No duplication. No guessing which version of the truth is correct.

---

# Still Rails

Apiwork doesn’t change how you build Rails apps. Controllers stay familiar. Models keep their validations, associations, and callbacks. You work the same way as before — there’s simply more clarity at the boundary.

For example:

```ruby
respond_with Post.all
```

…automatically picks up filtering, sorting, pagination and serialization defined by your schema. Mark an attribute as `writable: true` and nested writes work. Mark something `filterable: true` and clients can filter by it. It’s all declarative and fits naturally with Rails conventions.

---

# In Short

Apiwork gives Rails a clear, lightweight language for describing the API boundary — something Rails never needed internally, but that becomes essential once your app talks to a wider mix of clients. One boundary. One definition. One source of truth.

## What’s Next

- [Installation](./installation.md)
- [Core Concepts](./core-concepts.md)
- [Quick Start](./quick-start.md)
