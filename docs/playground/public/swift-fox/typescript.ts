export interface Contact {
  email?: string;
  id?: string;
  name?: string;
  notes?: string;
  phone?: string;
}

export interface ContactCreatePayload {
  email?: null | string;
  name: string;
  notes?: string;
  phone?: string;
}

export type ContactInclude = object;

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

export type ContactsCreateResponseBody = { contact: Contact; meta?: object } | { issues?: Issue[] };

export type ContactsDestroyResponse = never;

export interface ContactsIndexRequest {
  query: ContactsIndexRequestQuery;
}

export interface ContactsIndexRequestQuery {
  include?: ContactInclude;
  page?: ContactPage;
}

export interface ContactsIndexResponse {
  body: ContactsIndexResponseBody;
}

export type ContactsIndexResponseBody = { contacts?: Contact[]; meta?: object; pagination?: OffsetPagination } | { issues?: Issue[] };

export interface ContactsShowResponse {
  body: ContactsShowResponseBody;
}

export type ContactsShowResponseBody = { contact: Contact; meta?: object } | { issues?: Issue[] };

export interface ContactsUpdateRequest {
  body: ContactsUpdateRequestBody;
}

export interface ContactsUpdateRequestBody {
  contact: ContactUpdatePayload;
}

export interface ContactsUpdateResponse {
  body: ContactsUpdateResponseBody;
}

export type ContactsUpdateResponseBody = { contact: Contact; meta?: object } | { issues?: Issue[] };

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}