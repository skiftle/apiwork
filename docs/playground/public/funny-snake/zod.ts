import { z } from 'zod';

export const InvoiceStatusSchema = z.enum(['draft', 'paid', 'sent']);

export const InvoiceSchema = z.object({
  createdAt: z.iso.datetime(),
  id: z.uuid(),
  issuedOn: z.iso.date(),
  notes: z.string(),
  number: z.string(),
  status: InvoiceStatusSchema,
  updatedAt: z.iso.datetime()
});

export const InvoiceCreatePayloadSchema = z.object({
  issuedOn: z.iso.date(),
  notes: z.string(),
  number: z.string(),
  status: InvoiceStatusSchema
});

export const InvoiceUpdatePayloadSchema = z.object({
  issuedOn: z.iso.date().optional(),
  notes: z.string().optional(),
  number: z.string().optional(),
  status: InvoiceStatusSchema.optional()
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
  invoice: InvoiceCreatePayloadSchema
});

export const InvoicesCreateRequestSchema = z.object({
  body: InvoicesCreateRequestBodySchema
});

export const InvoicesCreateResponseBodySchema = z.object({ invoice: InvoiceSchema });

export const InvoicesCreateResponseSchema = z.object({
  body: InvoicesCreateResponseBodySchema
});

export const InvoicesUpdateRequestBodySchema = z.object({
  invoice: InvoiceUpdatePayloadSchema
});

export const InvoicesUpdateRequestSchema = z.object({
  body: InvoicesUpdateRequestBodySchema
});

export const InvoicesUpdateResponseBodySchema = z.object({ invoice: InvoiceSchema });

export const InvoicesUpdateResponseSchema = z.object({
  body: InvoicesUpdateResponseBodySchema
});

export const InvoicesDestroyResponseSchema = z.never();

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
