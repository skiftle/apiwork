export interface Customer {
  id: string;
  name: string;
}

export interface Error {
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

export interface Invoice {
  createdAt: string;
  customer: Customer;
  customerId: string;
  id: string;
  issuedOn: null | string;
  lines: Line[];
  notes: null | string;
  number: string;
  status: InvoiceStatus;
  updatedAt: string;
}

export interface InvoiceCreatePayload {
  customerId: string;
  issuedOn?: null | string;
  notes?: null | string;
  number: string;
  status?: InvoiceStatus;
}

export interface InvoiceCreateSuccessResponseBody {
  invoice: Invoice;
  meta?: Record<string, unknown>;
}

export interface InvoiceFilter {
  AND?: InvoiceFilter[];
  NOT?: InvoiceFilter;
  OR?: InvoiceFilter[];
  number?: StringFilter | string;
  status?: InvoiceStatusFilter;
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

export type InvoiceStatus = 'draft' | 'paid' | 'sent';

export type InvoiceStatusFilter = InvoiceStatus | { eq?: InvoiceStatus; in?: InvoiceStatus[] };

export interface InvoiceUpdatePayload {
  customerId?: string;
  issuedOn?: null | string;
  notes?: null | string;
  number?: string;
  status?: InvoiceStatus;
}

export interface InvoiceUpdateSuccessResponseBody {
  invoice: Invoice;
  meta?: Record<string, unknown>;
}

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