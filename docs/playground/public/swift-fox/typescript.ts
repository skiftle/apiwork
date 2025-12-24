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

export interface ContactPage {
  number?: number;
  size?: number;
}

export interface ContactUpdatePayload {
  email?: null | string;
  name?: string;
  notes?: string;
  phone?: string;
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

export type ContactsCreateResponseBody = { contact: Contact; meta?: object } | { errors?: Error[] };

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

export type ContactsIndexResponseBody = { contacts?: Contact[]; meta?: object; pagination?: OffsetPagination } | { errors?: Error[] };

export interface ContactsShowResponse {
  body: ContactsShowResponseBody;
}

export type ContactsShowResponseBody = { contact: Contact; meta?: object } | { errors?: Error[] };

export interface ContactsUpdateRequest {
  body: ContactsUpdateRequestBody;
}

export interface ContactsUpdateRequestBody {
  contact: ContactUpdatePayload;
}

export interface ContactsUpdateResponse {
  body: ContactsUpdateResponseBody;
}

export type ContactsUpdateResponseBody = { contact: Contact; meta?: object } | { errors?: Error[] };

export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  errors: Error[];
  layer: Layer;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}