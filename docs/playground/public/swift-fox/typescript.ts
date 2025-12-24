export interface Contact {
  email: null | string;
  id: string;
  name: string;
  notes: string;
  phone: string;
}

export interface ContactCreatePayload {
  email?: null | string;
  name: string;
  notes?: string;
  phone?: string;
}

export interface ContactCreateSuccessResponseBody {
  contact: Contact;
  meta?: object;
}

export interface ContactIndexSuccessResponseBody {
  contacts: Contact[];
  meta?: object;
  pagination: OffsetPagination;
}

export interface ContactPage {
  number?: number;
  size?: number;
}

export interface ContactShowSuccessResponseBody {
  contact: Contact;
  meta?: object;
}

export interface ContactUpdatePayload {
  email?: null | string;
  name?: string;
  notes?: string;
  phone?: string;
}

export interface ContactUpdateSuccessResponseBody {
  contact: Contact;
  meta?: object;
}

export interface ContactsCreateRequest {
  body: ContactsCreateRequestBody;
}

export interface ContactsCreateRequestBody {
  contact: ContactCreatePayload;
}

export interface ContactsCreateResponse {
  body: ContactsCreateResponseBody;
}

export type ContactsCreateResponseBody = ContactCreateSuccessResponseBody | ErrorResponseBody;

export type ContactsDestroyResponse = never;

export interface ContactsIndexRequest {
  query: ContactsIndexRequestQuery;
}

export interface ContactsIndexRequestQuery {
  page?: ContactPage;
}

export interface ContactsIndexResponse {
  body: ContactsIndexResponseBody;
}

export type ContactsIndexResponseBody = ContactIndexSuccessResponseBody | ErrorResponseBody;

export interface ContactsShowResponse {
  body: ContactsShowResponseBody;
}

export type ContactsShowResponseBody = ContactShowSuccessResponseBody | ErrorResponseBody;

export interface ContactsUpdateRequest {
  body: ContactsUpdateRequestBody;
}

export interface ContactsUpdateRequestBody {
  contact: ContactUpdatePayload;
}

export interface ContactsUpdateResponse {
  body: ContactsUpdateResponseBody;
}

export type ContactsUpdateResponseBody = ContactUpdateSuccessResponseBody | ErrorResponseBody;

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}