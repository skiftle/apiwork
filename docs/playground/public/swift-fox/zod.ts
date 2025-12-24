import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const ContactSchema = z.object({
  email: z.string().nullable(),
  id: z.string(),
  name: z.string(),
  notes: z.string(),
  phone: z.string()
});

export const ContactCreatePayloadSchema = z.object({
  email: z.string().nullable().optional(),
  name: z.string(),
  notes: z.string().optional(),
  phone: z.string().optional()
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

export const ErrorSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const ErrorResponseSchema = z.object({
  errors: z.array(ErrorSchema),
  layer: LayerSchema
});

export const ContactsIndexRequestQuerySchema = z.object({
  page: ContactPageSchema.optional()
});

export const ContactsIndexRequestSchema = z.object({
  query: ContactsIndexRequestQuerySchema
});

export const ContactsIndexResponseBodySchema = z.union([z.object({ contacts: z.array(ContactSchema).optional(), meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ContactsIndexResponseSchema = z.object({
  body: ContactsIndexResponseBodySchema
});

export const ContactsShowResponseBodySchema = z.union([z.object({ contact: ContactSchema, meta: z.object({}).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ContactsShowResponseSchema = z.object({
  body: ContactsShowResponseBodySchema
});

export const ContactsCreateRequestBodySchema = z.object({
  contact: ContactCreatePayloadSchema
});

export const ContactsCreateRequestSchema = z.object({
  body: ContactsCreateRequestBodySchema
});

export const ContactsCreateResponseBodySchema = z.union([z.object({ contact: ContactSchema, meta: z.object({}).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ContactsCreateResponseSchema = z.object({
  body: ContactsCreateResponseBodySchema
});

export const ContactsUpdateRequestBodySchema = z.object({
  contact: ContactUpdatePayloadSchema
});

export const ContactsUpdateRequestSchema = z.object({
  body: ContactsUpdateRequestBodySchema
});

export const ContactsUpdateResponseBodySchema = z.union([z.object({ contact: ContactSchema, meta: z.object({}).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ContactsUpdateResponseSchema = z.object({
  body: ContactsUpdateResponseBodySchema
});

export const ContactsDestroyResponse = z.never();

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
