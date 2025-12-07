import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const InvoiceSchema = z.object({
  created_at: z.iso.datetime().optional(),
  customer: z.object({}),
  customer_id: z.string().optional(),
  id: z.string().optional(),
  issued_on: z.iso.date().optional(),
  lines: z.array(z.string()),
  notes: z.string().optional(),
  number: z.string().optional(),
  status: z.string().optional(),
  updated_at: z.iso.datetime().optional()
});

export const InvoiceCreatePayloadSchema = z.object({
  customer_id: z.string(),
  issued_on: z.iso.date().nullable().optional(),
  lines: z.array(z.string()).optional(),
  notes: z.string().nullable().optional(),
  number: z.string()
});

export const InvoiceCustomerIncludeSchema = z.object({

});

export const InvoiceLineIncludeSchema = z.object({

});

export const InvoicePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const InvoiceSortSchema = z.object({
  created_at: z.unknown().optional(),
  issued_on: z.unknown().optional(),
  status: z.unknown().optional(),
  updated_at: z.unknown().optional()
});

export const InvoiceUpdatePayloadSchema = z.object({
  customer_id: z.string().optional(),
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

export const InvoiceIncludeSchema = z.object({
  customer: InvoiceCustomerIncludeSchema.optional(),
  lines: InvoiceLineIncludeSchema.optional()
});

export const InvoiceFilterSchema: z.ZodType<InvoiceFilter> = z.lazy(() => z.object({
  _and: z.array(InvoiceFilterSchema).optional(),
  _not: InvoiceFilterSchema.optional(),
  _or: z.array(InvoiceFilterSchema).optional(),
  number: z.union([z.string(), StringFilterSchema]).optional(),
  status: z.union([z.string(), NullableStringFilterSchema]).optional()
}));

export const InvoiceSchema = z.object({
  created_at: z.iso.datetime(),
  customer_id: z.string(),
  id: z.string(),
  issued_on: z.iso.date().nullable().optional(),
  notes: z.string().nullable().optional(),
  number: z.string(),
  status: z.string().nullable().optional(),
  updated_at: z.iso.datetime()
});

export const InvoicesIndexRequestQuerySchema = z.object({
  filter: z.union([InvoiceFilterSchema, z.array(InvoiceFilterSchema)]).optional(),
  include: InvoiceIncludeSchema.optional(),
  page: InvoicePageSchema.optional(),
  sort: z.union([InvoiceSortSchema, z.array(InvoiceSortSchema)]).optional()
});

export const InvoicesIndexRequestSchema = z.object({
  query: InvoicesIndexRequestQuerySchema
});

export const InvoicesIndexResponseBodySchema = z.union([z.object({ invoices: z.array(InvoiceSchema).optional(), meta: z.object({}).optional(), pagination: PagePaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const InvoicesIndexResponseSchema = z.object({
  body: InvoicesIndexResponseBodySchema
});

export const InvoicesShowRequestQuerySchema = z.object({
  include: InvoiceIncludeSchema.optional()
});

export const InvoicesShowRequestSchema = z.object({
  query: InvoicesShowRequestQuerySchema
});

export const InvoicesShowResponseBodySchema = z.union([z.object({ invoice: InvoiceSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const InvoicesShowResponseSchema = z.object({
  body: InvoicesShowResponseBodySchema
});

export const InvoicesCreateRequestQuerySchema = z.object({
  include: InvoiceIncludeSchema.optional()
});

export const InvoicesCreateRequestBodySchema = z.object({
  invoice: InvoiceCreatePayloadSchema
});

export const InvoicesCreateRequestSchema = z.object({
  query: InvoicesCreateRequestQuerySchema,
  body: InvoicesCreateRequestBodySchema
});

export const InvoicesCreateResponseBodySchema = z.union([z.object({ invoice: InvoiceSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const InvoicesCreateResponseSchema = z.object({
  body: InvoicesCreateResponseBodySchema
});

export const InvoicesUpdateRequestQuerySchema = z.object({
  include: InvoiceIncludeSchema.optional()
});

export const InvoicesUpdateRequestBodySchema = z.object({
  invoice: InvoiceUpdatePayloadSchema
});

export const InvoicesUpdateRequestSchema = z.object({
  query: InvoicesUpdateRequestQuerySchema,
  body: InvoicesUpdateRequestBodySchema
});

export const InvoicesUpdateResponseBodySchema = z.union([z.object({ invoice: InvoiceSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const InvoicesUpdateResponseSchema = z.object({
  body: InvoicesUpdateResponseBodySchema
});

export const InvoicesArchiveRequestQuerySchema = z.object({
  include: InvoiceIncludeSchema.optional()
});

export const InvoicesArchiveRequestSchema = z.object({
  query: InvoicesArchiveRequestQuerySchema
});

export const InvoicesArchiveResponseBodySchema = z.union([z.object({ invoice: InvoiceSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const InvoicesArchiveResponseSchema = z.object({
  body: InvoicesArchiveResponseBodySchema
});

export interface Invoice {
  created_at: string;
  customer_id: string;
  id: string;
  issued_on?: null | string;
  notes?: null | string;
  number: string;
  status?: null | string;
  updated_at: string;
}

export interface Invoice {
  created_at?: string;
  customer: object;
  customer_id?: string;
  id?: string;
  issued_on?: string;
  lines: string[];
  notes?: string;
  number?: string;
  status?: string;
  updated_at?: string;
}

export interface InvoiceCreatePayload {
  customer_id: string;
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
  created_at?: unknown;
  issued_on?: unknown;
  status?: unknown;
  updated_at?: unknown;
}

export interface InvoiceUpdatePayload {
  customer_id?: string;
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

export type InvoicesArchiveResponseBody = { invoice: Invoice; meta?: object } | { issues?: Issue[] };

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

export type InvoicesCreateResponseBody = { invoice: Invoice; meta?: object } | { issues?: Issue[] };

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

export type InvoicesIndexResponseBody = { invoices?: Invoice[]; meta?: object; pagination?: PagePagination } | { issues?: Issue[] };

export interface InvoicesShowRequest {
  query: InvoicesShowRequestQuery;
}

export interface InvoicesShowRequestQuery {
  include?: InvoiceInclude;
}

export interface InvoicesShowResponse {
  body: InvoicesShowResponseBody;
}

export type InvoicesShowResponseBody = { invoice: Invoice; meta?: object } | { issues?: Issue[] };

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

export type InvoicesUpdateResponseBody = { invoice: Invoice; meta?: object } | { issues?: Issue[] };

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

export interface StringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}
