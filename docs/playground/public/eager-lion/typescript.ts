export interface Customer {
  id: string;
  name: string;
}

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Invoice {
  createdAt: string;
  customer: Customer;
  customerId: string;
  id: string;
  issuedOn: null | string;
  lines: Line[];
  notes: null | string;
  number: string;
  status: null | string;
  updatedAt: string;
}

export interface InvoiceArchiveSuccessResponseBody {
  invoice: Invoice;
  meta?: Record<string, unknown>;
}

export interface InvoiceCreatePayload {
  customerId: string;
  issuedOn?: null | string;
  lines?: LineNestedPayload[];
  notes?: null | string;
  number: string;
}

export interface InvoiceCreateSuccessResponseBody {
  invoice: Invoice;
  meta?: Record<string, unknown>;
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
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface InvoicePage {
  number?: number;
  size?: number;
}

export interface InvoiceShowSuccessResponseBody {
  invoice: Invoice;
  meta?: Record<string, unknown>;
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
  lines?: LineNestedPayload[];
  notes?: null | string;
  number?: string;
}

export interface InvoiceUpdateSuccessResponseBody {
  invoice: Invoice;
  meta?: Record<string, unknown>;
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
  meta: Record<string, unknown>;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface Line {
  description: null | string;
  id: string;
  price: null | number;
  quantity: null | number;
}

export interface LineNestedCreatePayload {
  _destroy?: boolean;
  _type: 'create';
  description?: null | string;
  id?: string;
  price?: null | number;
  quantity?: null | number;
}

export type LineNestedPayload = LineNestedCreatePayload | LineNestedUpdatePayload;

export interface LineNestedUpdatePayload {
  _destroy?: boolean;
  _type: 'update';
  description?: null | string;
  id?: string;
  price?: null | number;
  quantity?: null | number;
}

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