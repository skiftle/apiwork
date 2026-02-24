export interface Invoice {
  createdAt: string;
  id: string;
  issuedOn: string;
  notes: string;
  number: string;
  status: InvoiceStatus;
  updatedAt: string;
}

export interface InvoiceCreatePayload {
  issuedOn: string;
  notes: string;
  number: string;
  status: InvoiceStatus;
}

export type InvoiceStatus = 'draft' | 'paid' | 'sent';

export interface InvoiceUpdatePayload {
  issuedOn?: string;
  notes?: string;
  number?: string;
  status?: InvoiceStatus;
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

export type InvoicesCreateResponseBody = { invoice: Invoice };

export type InvoicesDestroyResponse = never;

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
  invoice: InvoiceUpdatePayload;
}

export interface InvoicesUpdateResponse {
  body: InvoicesUpdateResponseBody;
}

export type InvoicesUpdateResponseBody = { invoice: Invoice };