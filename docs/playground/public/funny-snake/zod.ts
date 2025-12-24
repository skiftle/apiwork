import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const ErrorSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const InvoiceSchema = z.object({
  createdAt: z.iso.datetime(),
  id: z.uuid(),
  issuedOn: z.iso.date(),
  notes: z.string(),
  number: z.string(),
  status: z.string(),
  updatedAt: z.iso.datetime()
});

export const InvoicePayloadSchema = z.object({
  issuedOn: z.iso.date(),
  notes: z.string(),
  number: z.string(),
  status: z.string()
});

export const ErrorResponseSchema = z.object({
  issues: z.array(ErrorSchema),
  layer: LayerSchema
});

export const InvoicesIndexResponseBodySchema = z.object({ invoices: z.array(InvoiceSchema) });

export const InvoicesIndexResponseSchema = z.object({
  body: InvoicesIndexResponseBodySchema
});

export const InvoicesShowResponseBodySchema = z.object({ invoice: InvoiceSchema });

export const InvoicesShowResponseSchema = z.object({
  body: InvoicesShowResponseBodySchema
});

export const InvoicesCreateRequestBodySchema = z.object({
  invoice: InvoicePayloadSchema
});

export const InvoicesCreateRequestSchema = z.object({
  body: InvoicesCreateRequestBodySchema
});

export const InvoicesCreateResponseBodySchema = z.object({ invoice: InvoiceSchema });

export const InvoicesCreateResponseSchema = z.object({
  body: InvoicesCreateResponseBodySchema
});

export const InvoicesUpdateRequestBodySchema = z.object({
  invoice: InvoicePayloadSchema
});

export const InvoicesUpdateRequestSchema = z.object({
  body: InvoicesUpdateRequestBodySchema
});

export const InvoicesUpdateResponseBodySchema = z.object({ invoice: InvoiceSchema });

export const InvoicesUpdateResponseSchema = z.object({
  body: InvoicesUpdateResponseBodySchema
});

export const InvoicesDestroyResponse = z.never();

export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  issues: Error[];
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
  invoice: InvoicePayload;
}

export interface InvoicesUpdateResponse {
  body: InvoicesUpdateResponseBody;
}

export type InvoicesUpdateResponseBody = { invoice: Invoice };

export type Layer = 'contract' | 'domain' | 'http';
