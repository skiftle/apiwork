import { z } from 'zod';

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const OrdersCreateRequestBodySchema = z.object({
  shipping_address: z.object({ city: z.string(), street: z.string() })
});

export const OrdersCreateRequestSchema = z.object({
  body: OrdersCreateRequestBodySchema
});

export const OrdersCreateResponseBodySchema = z.object({ id: z.number().int().optional(), status: z.string().optional() });

export const OrdersCreateResponseSchema = z.object({
  body: OrdersCreateResponseBodySchema
});

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}
