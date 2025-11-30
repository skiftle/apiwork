import { z } from 'zod';

export const OrderPrioritySchema = z.enum(['high', 'low', 'normal', 'urgent']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const OrderAddressSchema = z.object({
  city: z.string(),
  street: z.string()
});

export const OrdersCreateRequestBodySchema = z.object({
  priority: OrderPrioritySchema.optional(),
  shipping_address: OrderAddressSchema
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

export interface OrderAddress {
  city: string;
  street: string;
}

export type OrderPriority = 'high' | 'low' | 'normal' | 'urgent';
