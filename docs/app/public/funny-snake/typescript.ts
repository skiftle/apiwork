export interface Invoice {
  created_at: string;
  id: string;
  issued_on: string;
  notes: string;
  number: string;
  status: string;
  updated_at: string;
}

export interface InvoicePayload {
  issued_on: string;
  notes: string;
  number: string;
  status: string;
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