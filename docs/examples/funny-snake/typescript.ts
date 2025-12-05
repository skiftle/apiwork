export interface Invoice {
  created_at: string;
  id: string;
  issued_on: string;
  lines: InvoiceLine[];
  number: string;
  status: string;
  updated_at: string;
}

export interface InvoiceLine {
  created_at: string;
  description: string;
  id: string;
  price: number;
  quantity: number;
  updated_at: string;
}

export interface InvoicePayload {
  issued_on: string;
  lines_attributes: string[];
  notes: string;
  number: string;
}

export interface InvoicesCreateRequest {
  body: InvoicesCreateRequestBody;
}

export interface InvoicesCreateRequestBody {
  invoice: InvoicePayload;
}

export interface InvoicesCreateResponse {
  body: InvoicesCreateResponseBody;
}

export type InvoicesCreateResponseBody = { invoice: Invoice };

export interface InvoicesIndexRequest {
  query: InvoicesIndexRequestQuery;
}

export interface InvoicesIndexRequestQuery {
  filter: { status: string };
  sort: { issued_on: 'asc' | 'desc' };
}

export interface InvoicesIndexResponse {
  body: InvoicesIndexResponseBody;
}

export type InvoicesIndexResponseBody = { invoices: Invoice[] };

export interface InvoicesShowResponse {
  body: InvoicesShowResponseBody;
}

export type InvoicesShowResponseBody = { invoice: Invoice };

export interface InvoicesUpdateRequest {
  body: InvoicesUpdateRequestBody;
}

export interface InvoicesUpdateRequestBody {
  invoice: InvoicePayload;
}

export interface InvoicesUpdateResponse {
  body: InvoicesUpdateResponseBody;
}

export type InvoicesUpdateResponseBody = { invoice: Invoice };

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}