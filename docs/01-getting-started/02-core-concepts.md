# Core Concepts

Apiwork is built around three central components: the API definition, the contracts, and (optionally) schemas. Together they describe how your API is structured, which resources exist, which actions they expose, and the exact shape of both requests and responses.

## API Definition

The API definition acts similarly to Rails’ `routes.rb`, but focuses on the logical API structure rather than URL routing alone. It defines the resource tree and connects each resource to its contract and controller.

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :invoices do
    member do
      patch :archive
    end
  end
end
```

`resources` behaves as in Rails, and Apiwork uses the Rails router under the hood. The difference is that each resource must have a corresponding contract, ensuring every action has a well-defined structure.

## Contracts

A contract defines the actions a resource supports — such as `index`, `show`, or `create` — and the precise shape of both incoming requests and outgoing responses. Contracts can also define custom types, enums or shared structures used across actions.

```ruby
# app/contracts/invoice_contract.rb
class InvoiceContract < Apiwork::Contract::Base
  type :line do
    param :id, type: :uuid
    param :created_at, type: :datetime
    param :updated_at, type: :datetime
    param :description, type: :string
    param :quantity, type: :decimal
    param :price, type: :decimal
  end

  type :invoice do
    param :id, type: :uuid
    param :created_at, type: :datetime
    param :updated_at, type: :datetime
    param :number, type: :string
    param :issued_on, type: :date
    param :status, type: :string
    param :lines, type: :array, of: :line
  end

  type :payload do
    param :number, type: :string
    param :issued_on, type: :date
    param :notes, type: :string
    param :lines_attributes, type: :array do
      param :_destroy, type: :boolean
      param :id, type: :uuid
      param :description, type: :string
      param :quantity, type: :integer
      param :price, type: :decimal
    end
  end

  action :index do
    request do
      query do
        param :filter, type: :object do
          param :status, type: :string
        end
        param :sort, type: :object do
          param :issued_on, type: :string, enum: %w[asc desc]
        end
      end
    end

    response do
      body do
        param :invoices, type: :array, of: :invoice
      end
    end
  end

  action :show do
    response do
      body do
        param :invoice, type: :invoice
      end
    end
  end

  action :create do
    request do
      body do
        param :invoice, type: :payload, required: true
      end
    end

    response do
      body do
        param :invoice, type: :invoice
      end
    end
  end

  action :update do
    request do
      body do
        param :invoice, type: :payload, required: true
      end
    end

    response do
      body do
        param :invoice, type: :invoice
      end
    end
  end

  action :destroy

  action :archive do
    response do
      body do
        param :invoice, type: :invoice
      end
    end
  end
end
```

If a request does not match the contract, Apiwork rejects it immediately. If a response does not match, Apiwork logs the mismatch in development mode.

## Controllers

Your controllers remain familiar. You keep your own logic, your own queries and service calls. The only changes are:

- Input comes from `contract.query` or `contract.body` instead of `params`
- Output goes through `respond_with`, which enforces the contract

```ruby
before_action :set_invoice, only: %i[show update destroy archive]

def index
  invoices = Invoice.query(contract.query)
  respond_with invoices
end

def show
  respond_with invoice
end

def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end

def update
  invoice.update(contract.body[:invoice])
  respond_with invoice
end

def destroy
  invoice.destroy
  respond_with invoice
end

def archive
  invoice.archive
  respond_with invoice
end

private

attr_reader :invoice

def set_invoice
  @invoice = Invoice.find(params[:id])
end
```

Apiwork doesn’t change how you write controllers — it simply guarantees that whatever enters or leaves them matches the contract.

## Schemas

Schemas are optional, but they eliminate most manual contract definitions by mapping directly to your ActiveRecord models.

```ruby
# app/schemas/line_schema.rb
class LineSchema < Apiwork::Schema::Base
  attribute :id
  attribute :description, writable: true
  attribute :quantity, writable: true
  attribute :price, writable: true
end

# app/schemas/invoice_schema.rb
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
  attribute :number, writable: true, filterable: true
  attribute :issued_on, writable: true, sortable: true
  attribute :notes, writable: true
  attribute :status, filterable: true, sortable: true

  has_many :lines, writable: true, include: :always
  belongs_to :customer, include: :always
end
```

With `schema!` in your contract, Apiwork generates request bodies, response shapes, filter types, sort options and includes — all from the schema:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

Schemas run through adapters, which transform schema definitions into metadata used for filtering, sorting, pagination, eager loading and nested operations.

Apiwork ships with an ActiveRecord-aware adapter that automatically pulls in:

- Database column types
- Enum definitions
- Nullability rules
- Associations
- Default values

This lets Apiwork infer capabilities directly from the model.

## One Metadata Model

The API definition, contracts and schemas all feed into a unified metadata model. Because each piece builds on the same foundation, Apiwork can generate OpenAPI, Zod and TypeScript definitions that stay perfectly aligned with your server.

Documentation, typed clients and server behaviour all come from the same source of truth — eliminating duplication and keeping the entire API consistent end-to-end.

From the Invoice schema above, Apiwork generates the following typed output:

<details>
<summary>TypeScript</summary>

```typescript
export interface CursorPagination {
  next_cursor?: null | string;
  prev_cursor?: null | string;
}

export interface Invoice {
  created_at?: string;
  customer: null | object;
  id?: unknown;
  issued_on?: string;
  lines: string[];
  notes?: string;
  number?: string;
  status?: string;
  updated_at?: string;
}

export interface InvoiceCreatePayload {
  issued_on?: null | string;
  lines?: string[];
  notes?: null | string;
  number: string;
}

export type InvoiceCustomerInclude = object;

export interface InvoiceFilter {
  _and?: InvoiceFilter[];
  _not?: InvoiceFilter;
  _or?: InvoiceFilter[];
  number?: StringFilter | string;
  status?: NullableStringFilter | string;
}

export interface InvoiceInclude {
  customer?: InvoiceCustomerInclude;
  lines?: InvoiceLineInclude;
}

export type InvoiceLineInclude = object;

export interface InvoicePage {
  number?: number;
  size?: number;
}

export interface InvoiceSort {
  created_at?: SortDirection;
  issued_on?: SortDirection;
  status?: SortDirection;
  updated_at?: SortDirection;
}

export interface InvoiceUpdatePayload {
  issued_on?: null | string;
  lines?: string[];
  notes?: null | string;
  number?: string;
}

export interface InvoicesArchiveRequest {
  query: InvoicesArchiveRequestQuery;
}

export interface InvoicesArchiveRequestQuery {
  include?: InvoiceInclude;
}

export interface InvoicesArchiveResponse {
  body: InvoicesArchiveResponseBody;
}

export type InvoicesArchiveResponseBody = { invoice: Invoice; meta?: object } | { issues: Issue[] };

export interface InvoicesCreateRequest {
  query: InvoicesCreateRequestQuery;
  body: InvoicesCreateRequestBody;
}

export interface InvoicesCreateRequestBody {
  invoice: InvoiceCreatePayload;
}

export interface InvoicesCreateRequestQuery {
  include?: InvoiceInclude;
}

export interface InvoicesCreateResponse {
  body: InvoicesCreateResponseBody;
}

export type InvoicesCreateResponseBody = { invoice: Invoice; meta?: object } | { issues: Issue[] };

export interface InvoicesIndexRequest {
  query: InvoicesIndexRequestQuery;
}

export interface InvoicesIndexRequestQuery {
  filter?: InvoiceFilter | InvoiceFilter[];
  include?: InvoiceInclude;
  page?: InvoicePage;
  sort?: InvoiceSort | InvoiceSort[];
}

export interface InvoicesIndexResponse {
  body: InvoicesIndexResponseBody;
}

export type InvoicesIndexResponseBody = { invoices?: Invoice[]; meta?: object; pagination?: PagePagination } | { issues: Issue[] };

export interface InvoicesShowRequest {
  query: InvoicesShowRequestQuery;
}

export interface InvoicesShowRequestQuery {
  include?: InvoiceInclude;
}

export interface InvoicesShowResponse {
  body: InvoicesShowResponseBody;
}

export type InvoicesShowResponseBody = { invoice: Invoice; meta?: object } | { issues: Issue[] };

export interface InvoicesUpdateRequest {
  query: InvoicesUpdateRequestQuery;
  body: InvoicesUpdateRequestBody;
}

export interface InvoicesUpdateRequestBody {
  invoice: InvoiceUpdatePayload;
}

export interface InvoicesUpdateRequestQuery {
  include?: InvoiceInclude;
}

export interface InvoicesUpdateResponse {
  body: InvoicesUpdateResponseBody;
}

export type InvoicesUpdateResponseBody = { invoice: Invoice; meta?: object } | { issues: Issue[] };

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface NullableStringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  starts_with?: string;
}

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

export type SortDirectionFilter = SortDirection | { eq?: SortDirection; in?: SortDirection[] };

export interface StringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}
```
</details>

<details>
<summary>Zod</summary>

```typescript
import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CursorPaginationSchema = z.object({
  next_cursor: z.string().nullable().optional(),
  prev_cursor: z.string().nullable().optional()
});

export const InvoiceSchema = z.object({
  created_at: z.iso.datetime().optional(),
  customer: z.object({}).nullable(),
  id: z.unknown().optional(),
  issued_on: z.iso.date().optional(),
  lines: z.array(z.string()),
  notes: z.string().optional(),
  number: z.string().optional(),
  status: z.string().optional(),
  updated_at: z.iso.datetime().optional()
});

export const InvoiceCreatePayloadSchema = z.object({
  issued_on: z.iso.date().nullable().optional(),
  lines: z.array(z.string()).optional(),
  notes: z.string().nullable().optional(),
  number: z.string()
});

export const InvoicePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const InvoiceSortSchema = z.object({
  created_at: SortDirectionSchema.optional(),
  issued_on: SortDirectionSchema.optional(),
  status: SortDirectionSchema.optional(),
  updated_at: SortDirectionSchema.optional()
});

export const InvoiceUpdatePayloadSchema = z.object({
  issued_on: z.iso.date().nullable().optional(),
  lines: z.array(z.string()).optional(),
  notes: z.string().nullable().optional(),
  number: z.string().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  starts_with: z.string().optional()
});

export const PagePaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  starts_with: z.string().optional()
});

// ... request/response schemas for each action
```
</details>
