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

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';
