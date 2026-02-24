import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
});

export const LineItemSchema = z.object({
  id: z.string(),
  productName: z.string(),
  quantity: z.number().int().nullable(),
  unitPrice: z.number().nullable()
});

export const LineItemNestedCreatePayloadSchema = z.object({
  OP: z.literal('create').optional(),
  productName: z.string(),
  quantity: z.number().int().nullable().optional(),
  unitPrice: z.number().nullable().optional()
});

export const LineItemNestedDeletePayloadSchema = z.object({
  OP: z.literal('delete').optional(),
  id: z.string()
});

export const LineItemNestedUpdatePayloadSchema = z.object({
  OP: z.literal('update').optional(),
  id: z.string().optional(),
  productName: z.string().optional(),
  quantity: z.number().int().nullable().optional(),
  unitPrice: z.number().nullable().optional()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const OrderPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ShippingAddressSchema = z.object({
  city: z.string(),
  country: z.string(),
  id: z.string(),
  postalCode: z.string(),
  street: z.string()
});

export const ShippingAddressNestedCreatePayloadSchema = z.object({
  OP: z.literal('create').optional(),
  city: z.string(),
  country: z.string(),
  postalCode: z.string(),
  street: z.string()
});

export const ShippingAddressNestedDeletePayloadSchema = z.object({
  OP: z.literal('delete').optional(),
  id: z.string()
});

export const ShippingAddressNestedUpdatePayloadSchema = z.object({
  OP: z.literal('update').optional(),
  city: z.string().optional(),
  country: z.string().optional(),
  id: z.string().optional(),
  postalCode: z.string().optional(),
  street: z.string().optional()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const LineItemNestedPayloadSchema = z.discriminatedUnion('OP', [
  LineItemNestedCreatePayloadSchema,
  LineItemNestedUpdatePayloadSchema,
  LineItemNestedDeletePayloadSchema
]);

export const OrderSchema = z.object({
  createdAt: z.iso.datetime(),
  id: z.string(),
  lineItems: z.array(LineItemSchema),
  orderNumber: z.string(),
  shippingAddress: ShippingAddressSchema,
  status: z.string().nullable(),
  total: z.number().nullable(),
  updatedAt: z.iso.datetime()
});

export const ShippingAddressNestedPayloadSchema = z.discriminatedUnion('OP', [
  ShippingAddressNestedCreatePayloadSchema,
  ShippingAddressNestedUpdatePayloadSchema,
  ShippingAddressNestedDeletePayloadSchema
]);

export const ErrorResponseBodySchema = ErrorSchema;

export const OrderCreatePayloadSchema = z.object({
  lineItems: z.array(LineItemNestedPayloadSchema).optional(),
  orderNumber: z.string(),
  shippingAddress: ShippingAddressNestedPayloadSchema.optional()
});

export const OrderCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  order: OrderSchema
});

export const OrderIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  orders: z.array(OrderSchema),
  pagination: OffsetPaginationSchema
});

export const OrderShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  order: OrderSchema
});

export const OrderUpdatePayloadSchema = z.object({
  lineItems: z.array(LineItemNestedPayloadSchema).optional(),
  orderNumber: z.string().optional(),
  shippingAddress: ShippingAddressNestedPayloadSchema.optional()
});

export const OrderUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  order: OrderSchema
});

export const OrdersIndexRequestQuerySchema = z.object({
  page: OrderPageSchema.optional()
});

export const OrdersIndexRequestSchema = z.object({
  query: OrdersIndexRequestQuerySchema
});

export const OrdersIndexResponseBodySchema = z.union([OrderIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const OrdersIndexResponseSchema = z.object({
  body: OrdersIndexResponseBodySchema
});

export const OrdersShowResponseBodySchema = z.union([OrderShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const OrdersShowResponseSchema = z.object({
  body: OrdersShowResponseBodySchema
});

export const OrdersCreateRequestBodySchema = z.object({
  order: OrderCreatePayloadSchema
});

export const OrdersCreateRequestSchema = z.object({
  body: OrdersCreateRequestBodySchema
});

export const OrdersCreateResponseBodySchema = z.union([OrderCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const OrdersCreateResponseSchema = z.object({
  body: OrdersCreateResponseBodySchema
});

export const OrdersUpdateRequestBodySchema = z.object({
  order: OrderUpdatePayloadSchema
});

export const OrdersUpdateRequestSchema = z.object({
  body: OrdersUpdateRequestBodySchema
});

export const OrdersUpdateResponseBodySchema = z.union([OrderUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const OrdersUpdateResponseSchema = z.object({
  body: OrdersUpdateResponseBodySchema
});

export const OrdersDestroyResponseSchema = z.never();

export interface Error {
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

export interface Issue {
  code: string;
  detail: string;
  meta: Record<string, unknown>;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface LineItem {
  id: string;
  productName: string;
  quantity: null | number;
  unitPrice: null | number;
}

export interface LineItemNestedCreatePayload {
  OP?: 'create';
  productName: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

export interface LineItemNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type LineItemNestedPayload = LineItemNestedCreatePayload | LineItemNestedUpdatePayload | LineItemNestedDeletePayload;

export interface LineItemNestedUpdatePayload {
  OP?: 'update';
  id?: string;
  productName?: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Order {
  createdAt: string;
  id: string;
  lineItems: LineItem[];
  orderNumber: string;
  shippingAddress: ShippingAddress;
  status: null | string;
  total: null | number;
  updatedAt: string;
}

export interface OrderCreatePayload {
  lineItems?: LineItemNestedPayload[];
  orderNumber: string;
  shippingAddress?: ShippingAddressNestedPayload;
}

export interface OrderCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  orders: Order[];
  pagination: OffsetPagination;
}

export interface OrderPage {
  number?: number;
  size?: number;
}

export interface OrderShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderUpdatePayload {
  lineItems?: LineItemNestedPayload[];
  orderNumber?: string;
  shippingAddress?: ShippingAddressNestedPayload;
}

export interface OrderUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrdersCreateRequest {
  body: OrdersCreateRequestBody;
}

export interface OrdersCreateRequestBody {
  order: OrderCreatePayload;
}

export interface OrdersCreateResponse {
  body: OrdersCreateResponseBody;
}

export type OrdersCreateResponseBody = ErrorResponseBody | OrderCreateSuccessResponseBody;

export type OrdersDestroyResponse = never;

export interface OrdersIndexRequest {
  query: OrdersIndexRequestQuery;
}

export interface OrdersIndexRequestQuery {
  page?: OrderPage;
}

export interface OrdersIndexResponse {
  body: OrdersIndexResponseBody;
}

export type OrdersIndexResponseBody = ErrorResponseBody | OrderIndexSuccessResponseBody;

export interface OrdersShowResponse {
  body: OrdersShowResponseBody;
}

export type OrdersShowResponseBody = ErrorResponseBody | OrderShowSuccessResponseBody;

export interface OrdersUpdateRequest {
  body: OrdersUpdateRequestBody;
}

export interface OrdersUpdateRequestBody {
  order: OrderUpdatePayload;
}

export interface OrdersUpdateResponse {
  body: OrdersUpdateResponseBody;
}

export type OrdersUpdateResponseBody = ErrorResponseBody | OrderUpdateSuccessResponseBody;

export interface ShippingAddress {
  city: string;
  country: string;
  id: string;
  postalCode: string;
  street: string;
}

export interface ShippingAddressNestedCreatePayload {
  OP?: 'create';
  city: string;
  country: string;
  postalCode: string;
  street: string;
}

export interface ShippingAddressNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type ShippingAddressNestedPayload = ShippingAddressNestedCreatePayload | ShippingAddressNestedUpdatePayload | ShippingAddressNestedDeletePayload;

export interface ShippingAddressNestedUpdatePayload {
  OP?: 'update';
  city?: string;
  country?: string;
  id?: string;
  postalCode?: string;
  street?: string;
}
