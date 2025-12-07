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

export interface ContactFilter {
  _and?: ContactFilter[];
  _not?: ContactFilter;
  _or?: ContactFilter[];
}

export type ContactInclude = object;

export interface ContactPage {
  number?: number;
  size?: number;
}

export type ContactSort = object;

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

export interface ContactsIndexRequest {
  query: ContactsIndexRequestQuery;
}

export interface ContactsIndexRequestQuery {
  filter?: ContactFilter | ContactFilter[];
  include?: ContactInclude;
  page?: ContactPage;
  sort?: ContactSort | ContactSort[];
}

export interface ContactsIndexResponse {
  body: ContactsIndexResponseBody;
}

export type ContactsIndexResponseBody = { contacts?: Contact[]; meta?: object; pagination?: PagePagination } | { issues?: Issue[] };

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

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}