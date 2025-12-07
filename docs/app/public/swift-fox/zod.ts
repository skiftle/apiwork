import { z } from 'zod';

export const ContactSchema = z.object({
  email: z.string().optional(),
  id: z.string().optional(),
  name: z.string().optional(),
  notes: z.string().optional(),
  phone: z.string().optional()
});

export const ContactCreatePayloadSchema = z.object({
  email: z.string().nullable().optional(),
  name: z.string(),
  notes: z.string().optional(),
  phone: z.string().optional()
});

export const ContactIncludeSchema = z.object({

});

export const ContactPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ContactUpdatePayloadSchema = z.object({
  email: z.string().nullable().optional(),
  name: z.string().optional(),
  notes: z.string().optional(),
  phone: z.string().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const PagePaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const ContactSchema = z.object({
  email: z.string().nullable().optional(),
  id: z.string(),
  name: z.string(),
  notes: z.string().optional(),
  phone: z.string().optional()
});

export const ContactsIndexRequestQuerySchema = z.object({
  include: ContactIncludeSchema.optional(),
  page: ContactPageSchema.optional()
});

export const ContactsIndexRequestSchema = z.object({
  query: ContactsIndexRequestQuerySchema
});

export const ContactsIndexResponseBodySchema = z.union([z.object({ contacts: z.array(ContactSchema).optional(), meta: z.object({}).optional(), pagination: PagePaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ContactsIndexResponseSchema = z.object({
  body: ContactsIndexResponseBodySchema
});

export const ContactsShowResponseBodySchema = z.union([z.object({ contact: ContactSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ContactsShowResponseSchema = z.object({
  body: ContactsShowResponseBodySchema
});

export const ContactsCreateRequestBodySchema = z.object({
  contact: ContactCreatePayloadSchema
});

export const ContactsCreateRequestSchema = z.object({
  body: ContactsCreateRequestBodySchema
});

export const ContactsCreateResponseBodySchema = z.union([z.object({ contact: ContactSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ContactsCreateResponseSchema = z.object({
  body: ContactsCreateResponseBodySchema
});

export const ContactsUpdateRequestBodySchema = z.object({
  contact: ContactUpdatePayloadSchema
});

export const ContactsUpdateRequestSchema = z.object({
  body: ContactsUpdateRequestBodySchema
});

export const ContactsUpdateResponseBodySchema = z.union([z.object({ contact: ContactSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ContactsUpdateResponseSchema = z.object({
  body: ContactsUpdateResponseBodySchema
});

export interface Contact {
  email?: null | string;
  id: string;
  name: string;
  notes?: string;
  phone?: string;
}

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
