import { z } from 'zod';

export const InvoiceLineSchema = z.object({
  created_at: z.iso.datetime(),
  description: z.string(),
  id: z.uuid(),
  price: z.number(),
  quantity: z.number(),
  updated_at: z.iso.datetime()
});

export const InvoicePayloadSchema = z.object({
  issued_on: z.iso.date(),
  lines_attributes: z.array(z.string()),
  notes: z.string(),
  number: z.string()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const InvoiceSchema = z.object({
  created_at: z.iso.datetime(),
  id: z.uuid(),
  issued_on: z.iso.date(),
  lines: z.array(InvoiceLineSchema),
  number: z.string(),
  status: z.string(),
  updated_at: z.iso.datetime()
});

export const InvoicesIndexRequestQuerySchema = z.object({
  filter: z.object({ status: z.string() }),
  sort: z.object({ issued_on: z.enum(['asc', 'desc']) })
});

export const InvoicesIndexRequestSchema = z.object({
  query: InvoicesIndexRequestQuerySchema
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

export interface Invoice {
  created_at: string;
  id: string;
  issued_on: string;
  lines: InvoiceLine[];
  number: string;
  status: string;
  updated_at: string;
}

export interface InvoiceLine {
  created_at: string;
  description: string;
  id: string;
  price: number;
  quantity: number;
  updated_at: string;
}

export interface InvoicePayload {
  issued_on: string;
  lines_attributes: string[];
  notes: string;
  number: string;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}
