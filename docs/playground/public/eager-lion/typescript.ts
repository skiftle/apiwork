export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface InvoicesArchiveResponse {
  body: InvoicesArchiveResponseBody;
}

export type InvoicesArchiveResponseBody = never;

export interface InvoicesCreateResponse {
  body: InvoicesCreateResponseBody;
}

export type InvoicesCreateResponseBody = never;

export interface InvoicesDestroyResponse {
  body: InvoicesDestroyResponseBody;
}

export type InvoicesDestroyResponseBody = never;

export interface InvoicesIndexResponse {
  body: InvoicesIndexResponseBody;
}

export type InvoicesIndexResponseBody = never;

export interface InvoicesShowResponse {
  body: InvoicesShowResponseBody;
}

export type InvoicesShowResponseBody = never;

export interface InvoicesUpdateResponse {
  body: InvoicesUpdateResponseBody;
}

export type InvoicesUpdateResponseBody = never;

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';