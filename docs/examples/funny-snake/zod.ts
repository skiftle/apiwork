import { z } from 'zod';

export const InvoiceLineSchema = z.object({
  created_at: z.iso.datetime().optional(),
  description: z.string().optional(),
  id: z.uuid().optional(),
  price: z.number().optional(),
  quantity: z.number().optional(),
  updated_at: z.iso.datetime().optional()
});

export const InvoicePayloadSchema = z.object({
  issued_on: z.iso.date().optional(),
  lines_attributes: z.array(z.string()).optional(),
  notes: z.string().optional(),
  number: z.string().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const InvoiceSchema = z.object({
  created_at: z.iso.datetime().optional(),
  id: z.uuid().optional(),
  issued_on: z.iso.date().optional(),
  lines: z.array(InvoiceLineSchema).optional(),
  number: z.string().optional(),
  status: z.string().optional(),
  updated_at: z.iso.datetime().optional()
});

export const InvoicesIndexRequestQuerySchema = z.object({
  filter: z.object({ status: z.string().optional() }).optional(),
  sort: z.object({ issued_on: z.enum(['asc', 'desc']).optional() }).optional()
});

export const InvoicesIndexRequestSchema = z.object({
  query: InvoicesIndexRequestQuerySchema
});

export const InvoicesIndexResponseBodySchema = z.object({ invoices: z.array(InvoiceSchema).optional() });

export const InvoicesIndexResponseSchema = z.object({
  body: InvoicesIndexResponseBodySchema
});

export const InvoicesShowResponseBodySchema = z.object({ invoice: InvoiceSchema.optional() });

export const InvoicesShowResponseSchema = z.object({
  body: InvoicesShowResponseBodySchema
});

export const InvoicesCreateRequestBodySchema = z.object({
  invoice: InvoicePayloadSchema
});

export const InvoicesCreateRequestSchema = z.object({
  body: InvoicesCreateRequestBodySchema
});

export const InvoicesCreateResponseBodySchema = z.object({ invoice: InvoiceSchema.optional() });

export const InvoicesCreateResponseSchema = z.object({
  body: InvoicesCreateResponseBodySchema
});

export const InvoicesUpdateRequestBodySchema = z.object({
  invoice: InvoicePayloadSchema
});

export const InvoicesUpdateRequestSchema = z.object({
  body: InvoicesUpdateRequestBodySchema
});

export const InvoicesUpdateResponseBodySchema = z.object({ invoice: InvoiceSchema.optional() });

export const InvoicesUpdateResponseSchema = z.object({
  body: InvoicesUpdateResponseBodySchema
});

export interface Invoice {
  created_at?: string;
  id?: string;
  issued_on?: string;
  lines?: InvoiceLine[];
  number?: string;
  status?: string;
  updated_at?: string;
}

export interface InvoiceLine {
  created_at?: string;
  description?: string;
  id?: string;
  price?: number;
  quantity?: number;
  updated_at?: string;
}

export interface InvoicePayload {
  issued_on?: string;
  lines_attributes?: string[];
  notes?: string;
  number?: string;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}
