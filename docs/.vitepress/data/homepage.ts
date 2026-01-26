export interface WhyPoint {
  icon: string;
  title: string;
  description: string;
}

export interface CodeBlock {
  language: "ruby" | "typescript" | "json";
  code: string;
}

export interface Feature {
  icon: string;
  title: string;
  titleAccent: string;
  description: string;
  codeBlocks: CodeBlock[];
  alt?: boolean;
  wide?: boolean;
  blobVariant?: 1 | 2 | 3 | 4;
}

export interface MoreFeature {
  icon: string;
  name: string;
  description: string;
}

export const whyPoints: WhyPoint[] = [
  {
    icon: "database",
    title: "Your database stays the source of truth",
    description:
      "Apiwork reads directly from ActiveRecord and the database, so you don't repeat field definitions, enums, or nullability.",
  },
  {
    icon: "layout",
    title: "Your API behavior is explicit by default",
    description:
      "Requests, responses, errors, filtering, and pagination are defined in one place — not implied across controllers.",
  },
  {
    icon: "box",
    title: "No drift between backend and clients",
    description:
      "Documentation, types, and validation are generated from the same contracts that run in production.",
  },
  {
    icon: "code",
    title: "Controllers focus on business logic",
    description:
      "Unknown input never reaches your code. Controllers stay boring, predictable, and easy to reason about.",
  },
];

export const features: Feature[] = [
  {
    icon: "pencil",
    title: "Define your",
    titleAccent: "API",
    description:
      "One declarative block defines your entire API surface. Resources, key format, routing — all in one place. Think routes.rb, but for your entire API layer.",
    blobVariant: 1,
    codeBlocks: [
      {
        language: "ruby",
        code: `Apiwork::API.define '/api/v1' do
  key_format :camel

  resources :invoices do
    resources :payments
  end
end`,
      },
    ],
  },
  {
    icon: "layout",
    title: "Shape your",
    titleAccent: "contracts",
    description:
      "One definition validates requests, shapes responses, and generates documentation. Apiwork turns Ruby's expressive syntax into a declarative type system for APIs — describing dates, enums, nested objects, and discriminated unions with exact semantics across every output format.",
    alt: true,
    blobVariant: 2,
    codeBlocks: [
      {
        language: "ruby",
        code: `class InvoiceContract < Apiwork::Contract::Base
  enum :status, values: %i[draft sent due paid]

  action :index do
    request do
      query do
        string? :status, enum: :status
      end
    end

    response do
      body do
        array :invoices do
          object do
            uuid :id
            string :number
            string :status, enum: :status
          end
        end
      end
    end
  end
end`,
      },
    ],
  },
  {
    icon: "database",
    title: "Let your models",
    titleAccent: "speak",
    description:
      "But why write contracts manually? Your database already knows. Column types, enums, nullability — inherited automatically. Apiwork handles filtering, sorting, and pagination. You just say what to expose.",
    blobVariant: 3,
    codeBlocks: [
      {
        language: "ruby",
        code: `class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :number, sortable: true
  attribute :issued_on
  attribute :status, filterable: true

  belongs_to :customer
  has_many :lines, writable: true
end`,
      },
      {
        language: "ruby",
        code: `class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end`,
      },
    ],
  },
  {
    icon: "code",
    title: "Focus on",
    titleAccent: "business logic",
    description:
      "Your controllers stay focused on what matters. Apiwork handles the boundaries — requests are validated before they reach you, responses serialized on the way out. Just use your params and expose data.",
    alt: true,
    blobVariant: 4,
    codeBlocks: [
      {
        language: "ruby",
        code: `class InvoicesController < ApplicationController
  def show
    invoice = Invoice.find(params[:id])
    expose invoice
  end

  def create
    invoice = Invoice.create(contract.body[:invoice])
    expose invoice
  end
end`,
      },
    ],
  },
  {
    icon: "warning",
    title: "Errors that",
    titleAccent: "make sense",
    description:
      "Validation errors, model errors, nested association errors — all reported the same way. JSON Pointers pinpoint exact fields, even deep in arrays. Your frontend knows exactly what went wrong and where.",
    blobVariant: 2,
    codeBlocks: [
      {
        language: "json",
        code: `{
  "layer": "domain",
  "issues": [
    {
      "code": "required",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": {}
    },
    {
      "code": "required",
      "detail": "Required",
      "path": ["invoice", "lines", 0, "description"],
      "pointer": "/invoice/lines/0/description",
      "meta": {}
    },
    {
      "code": "in",
      "detail": "Invalid value",
      "path": ["invoice", "lines", 1, "status"],
      "pointer": "/invoice/lines/1/status",
      "meta": {}
    }
  ]
}`,
      },
    ],
  },
  {
    icon: "box",
    title: "Zero",
    titleAccent: "drift",
    description:
      "TypeScript types, Zod schemas, and OpenAPI specs — all generated from your contracts. When your API changes, your frontend types update automatically. They can never go stale.",
    alt: true,
    wide: true,
    blobVariant: 1,
    codeBlocks: [
      {
        language: "typescript",
        code: `interface Invoice {
  id: string;
  number: string;
  amount: string;
  status: 'draft' | 'sent' | 'paid';
  dueDate: string;
}`,
      },
      {
        language: "typescript",
        code: `const InvoiceSchema = z.object({
  id: z.string().uuid(),
  number: z.string(),
  amount: z.string(),
  status: z.enum(['draft', 'sent', 'paid']),
  dueDate: z.string(),
});`,
      },
    ],
  },
];

export const moreFeatures: MoreFeature[] = [
  {
    icon: "filter",
    name: "Rich Filtering",
    description:
      "Filter by any attribute with operators like eq, gt, lt, contains, between, and more.",
  },
  {
    icon: "arrow-down",
    name: "Multi-field Sorting",
    description:
      "Sort by multiple fields with priority ordering and nested association support.",
  },
  {
    icon: "grid",
    name: "Offset Pagination",
    description:
      "Traditional page-based pagination with total counts and page metadata.",
  },
  {
    icon: "arrow-right",
    name: "Cursor Pagination",
    description:
      "Efficient cursor-based pagination for large datasets without total counts.",
  },
  {
    icon: "bolt",
    name: "Eager Loading",
    description:
      "Automatic N+1 query prevention with smart association preloading.",
  },
  {
    icon: "git-branch",
    name: "STI Support",
    description:
      "Single Table Inheritance with automatic type inference and discriminated unions.",
  },
  {
    icon: "squares",
    name: "Polymorphic",
    description:
      "Full polymorphic association support with discriminated union type generation.",
  },
  {
    icon: "folder-plus",
    name: "Nested Resources",
    description:
      "Deep association traversal with circular reference prevention.",
  },
  {
    icon: "globe",
    name: "i18n Ready",
    description:
      "Localized error messages, descriptions, and multi-language documentation.",
  },
  {
    icon: "warning",
    name: "Error Handling",
    description:
      "Structured, machine-readable errors with codes, paths, and detailed messages.",
  },
  {
    icon: "refresh",
    name: "Key Transform",
    description:
      "Automatic key case conversion between camelCase and snake_case.",
  },
  {
    icon: "edit",
    name: "Partial Updates",
    description:
      "PATCH operations with automatically generated partial types for updates.",
  },
];
