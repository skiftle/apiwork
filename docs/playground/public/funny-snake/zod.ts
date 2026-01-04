import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

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

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const InvoicesIndexResponseBodySchema = z.never();

export const InvoicesIndexResponseSchema = z.object({
  body: InvoicesIndexResponseBodySchema
});

export const InvoicesShowResponseBodySchema = z.never();

export const InvoicesShowResponseSchema = z.object({
  body: InvoicesShowResponseBodySchema
});

export const InvoicesCreateResponseBodySchema = z.never();

export const InvoicesCreateResponseSchema = z.object({
  body: InvoicesCreateResponseBodySchema
});

export const InvoicesUpdateResponseBodySchema = z.never();

export const InvoicesUpdateResponseSchema = z.object({
  body: InvoicesUpdateResponseBodySchema
});

export const InvoicesDestroyResponseBodySchema = z.never();

export const InvoicesDestroyResponseSchema = z.object({
  body: InvoicesDestroyResponseBodySchema
});

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
