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

export interface InvoiceFilter {
  _and?: InvoiceFilter[];
  _not?: InvoiceFilter;
  _or?: InvoiceFilter[];
  number?: StringFilter | string;
  status?: NullableStringFilter | string;
}

export type InvoiceInclude = object;

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