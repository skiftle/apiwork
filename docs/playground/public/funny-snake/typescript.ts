export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Invoice {
  createdAt: string;
  id: string;
  issuedOn: string;
  notes: string;
  number: string;
  status: string;
  updatedAt: string;
}

export interface InvoicePayload {
  issuedOn: string;
  notes: string;
  number: string;
  status: string;
}

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';