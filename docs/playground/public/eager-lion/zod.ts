import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const InvoiceSchema = z.object({
  createdAt: z.iso.datetime(),
  customer: z.object({}),
  customerId: z.string(),
  id: z.string(),
  issuedOn: z.iso.date().nullable(),
  lines: z.array(z.string()),
  notes: z.string().nullable(),
  number: z.string(),
  status: z.string().nullable(),
  updatedAt: z.iso.datetime()
});

export const InvoiceCreatePayloadSchema = z.object({
  customerId: z.string(),
  issuedOn: z.iso.date().nullable().optional(),
  lines: z.array(z.string()).optional(),
  notes: z.string().nullable().optional(),
  number: z.string()
});

export const InvoicePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const InvoiceSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  issuedOn: SortDirectionSchema.optional(),
  status: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const InvoiceUpdatePayloadSchema = z.object({
  customerId: z.string().optional(),
  issuedOn: z.iso.date().nullable().optional(),
  lines: z.array(z.string()).optional(),
  notes: z.string().nullable().optional(),
  number: z.string().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  startsWith: z.string().optional()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const InvoiceArchiveSuccessResponseBodySchema = z.object({
  invoice: InvoiceSchema,
  meta: z.object({}).optional()
});

export const InvoiceCreateSuccessResponseBodySchema = z.object({
  invoice: InvoiceSchema,
  meta: z.object({}).optional()
});

export const InvoiceShowSuccessResponseBodySchema = z.object({
  invoice: InvoiceSchema,
  meta: z.object({}).optional()
});

export const InvoiceUpdateSuccessResponseBodySchema = z.object({
  invoice: InvoiceSchema,
  meta: z.object({}).optional()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const InvoiceIndexSuccessResponseBodySchema = z.object({
  invoices: z.array(InvoiceSchema),
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema
});

export const InvoiceFilterSchema: z.ZodType<InvoiceFilter> = z.lazy(() => z.object({
  _and: z.array(InvoiceFilterSchema).optional(),
  _not: InvoiceFilterSchema.optional(),
  _or: z.array(InvoiceFilterSchema).optional(),
  number: z.union([z.string(), StringFilterSchema]).optional(),
  status: z.union([z.string(), NullableStringFilterSchema]).optional()
}));

export const InvoicesIndexRequestQuerySchema = z.object({
  filter: z.union([InvoiceFilterSchema, z.array(InvoiceFilterSchema)]).optional(),
  page: InvoicePageSchema.optional(),
  sort: z.union([InvoiceSortSchema, z.array(InvoiceSortSchema)]).optional()
});

export const InvoicesIndexRequestSchema = z.object({
  query: InvoicesIndexRequestQuerySchema
});

export const InvoicesIndexResponseBodySchema = z.union([InvoiceIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const InvoicesIndexResponseSchema = z.object({
  body: InvoicesIndexResponseBodySchema
});

export const InvoicesShowResponseBodySchema = z.union([InvoiceShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const InvoicesShowResponseSchema = z.object({
  body: InvoicesShowResponseBodySchema
});

export const InvoicesCreateRequestBodySchema = z.object({
  invoice: InvoiceCreatePayloadSchema
});

export const InvoicesCreateRequestSchema = z.object({
  body: InvoicesCreateRequestBodySchema
});

export const InvoicesCreateResponseBodySchema = z.union([InvoiceCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const InvoicesCreateResponseSchema = z.object({
  body: InvoicesCreateResponseBodySchema
});

export const InvoicesUpdateRequestBodySchema = z.object({
  invoice: InvoiceUpdatePayloadSchema
});

export const InvoicesUpdateRequestSchema = z.object({
  body: InvoicesUpdateRequestBodySchema
});

export const InvoicesUpdateResponseBodySchema = z.union([InvoiceUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const InvoicesUpdateResponseSchema = z.object({
  body: InvoicesUpdateResponseBodySchema
});

export const InvoicesDestroyResponse = z.never();

export const InvoicesArchiveResponseBodySchema = z.union([InvoiceArchiveSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const InvoicesArchiveResponseSchema = z.object({
  body: InvoicesArchiveResponseBodySchema
});

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Invoice {
  createdAt: string;
  customer: object;
  customerId: string;
  id: string;
  issuedOn: null | string;
  lines: string[];
  notes: null | string;
  number: string;
  status: null | string;
  updatedAt: string;
}

export interface InvoiceArchiveSuccessResponseBody {
  invoice: Invoice;
  meta?: object;
}

export interface InvoiceCreatePayload {
  customerId: string;
  issuedOn?: null | string;
  lines?: string[];
  notes?: null | string;
  number: string;
}

export interface InvoiceCreateSuccessResponseBody {
  invoice: Invoice;
  meta?: object;
}

export interface InvoiceFilter {
  _and?: InvoiceFilter[];
  _not?: InvoiceFilter;
  _or?: InvoiceFilter[];
  number?: StringFilter | string;
  status?: NullableStringFilter | string;
}

export interface InvoiceIndexSuccessResponseBody {
  invoices: Invoice[];
  meta?: object;
  pagination: OffsetPagination;
}

export interface InvoicePage {
  number?: number;
  size?: number;
}

export interface InvoiceShowSuccessResponseBody {
  invoice: Invoice;
  meta?: object;
}

export interface InvoiceSort {
  createdAt?: SortDirection;
  issuedOn?: SortDirection;
  status?: SortDirection;
  updatedAt?: SortDirection;
}

export interface InvoiceUpdatePayload {
  customerId?: string;
  issuedOn?: null | string;
  lines?: string[];
  notes?: null | string;
  number?: string;
}

export interface InvoiceUpdateSuccessResponseBody {
  invoice: Invoice;
  meta?: object;
}

export interface InvoicesArchiveResponse {
  body: InvoicesArchiveResponseBody;
}

export type InvoicesArchiveResponseBody = ErrorResponseBody | InvoiceArchiveSuccessResponseBody;

export interface InvoicesCreateRequest {
  body: InvoicesCreateRequestBody;
}

export interface InvoicesCreateRequestBody {
  invoice: InvoiceCreatePayload;
}

export interface InvoicesCreateResponse {
  body: InvoicesCreateResponseBody;
}

export type InvoicesCreateResponseBody = ErrorResponseBody | InvoiceCreateSuccessResponseBody;

export type InvoicesDestroyResponse = never;

export interface InvoicesIndexRequest {
  query: InvoicesIndexRequestQuery;
}

export interface InvoicesIndexRequestQuery {
  filter?: InvoiceFilter | InvoiceFilter[];
  page?: InvoicePage;
  sort?: InvoiceSort | InvoiceSort[];
}

export interface InvoicesIndexResponse {
  body: InvoicesIndexResponseBody;
}

export type InvoicesIndexResponseBody = ErrorResponseBody | InvoiceIndexSuccessResponseBody;

export interface InvoicesShowResponse {
  body: InvoicesShowResponseBody;
}

export type InvoicesShowResponseBody = ErrorResponseBody | InvoiceShowSuccessResponseBody;

export interface InvoicesUpdateRequest {
  body: InvoicesUpdateRequestBody;
}

export interface InvoicesUpdateRequestBody {
  invoice: InvoiceUpdatePayload;
}

export interface InvoicesUpdateResponse {
  body: InvoicesUpdateResponseBody;
}

export type InvoicesUpdateResponseBody = ErrorResponseBody | InvoiceUpdateSuccessResponseBody;

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface NullableStringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  startsWith?: string;
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}
