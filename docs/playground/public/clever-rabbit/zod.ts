import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  startsWith: z.string().optional()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const OrderSchema = z.object({
  createdAt: z.iso.datetime(),
  id: z.string(),
  lineItems: z.array(z.string()),
  orderNumber: z.string(),
  shippingAddress: z.object({}),
  status: z.string().nullable(),
  total: z.number().nullable(),
  updatedAt: z.iso.datetime()
});

export const OrderCreatePayloadSchema = z.object({
  lineItems: z.array(z.string()).optional(),
  orderNumber: z.string(),
  shippingAddress: z.object({}).optional()
});

export const OrderCreateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  order: OrderSchema
});

export const OrderFilterSchema = z.object({
  _and: z.array(z.unknown()).optional(),
  _not: z.unknown().optional(),
  _or: z.array(z.unknown()).optional(),
  status: z.union([z.string(), NullableStringFilterSchema]).optional()
});

export const OrderIndexSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  orders: z.array(OrderSchema),
  pagination: OffsetPaginationSchema
});

export const OrderPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const OrderShowSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  order: OrderSchema
});

export const OrderSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  status: SortDirectionSchema.optional()
});

export const OrderUpdatePayloadSchema = z.object({
  lineItems: z.array(z.string()).optional(),
  orderNumber: z.string().optional(),
  shippingAddress: z.object({}).optional()
});

export const OrderUpdateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  order: OrderSchema
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const OrdersIndexRequestQuerySchema = z.object({
  filter: z.union([OrderFilterSchema, z.array(z.string())]).optional(),
  page: OrderPageSchema.optional(),
  sort: z.union([OrderSortSchema, z.array(z.string())]).optional()
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

export const OrdersDestroyResponse = z.never();

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface NullableStringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  startsWith?: string;
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
  lineItems: string[];
  orderNumber: string;
  shippingAddress: object;
  status: null | string;
  total: null | number;
  updatedAt: string;
}

export interface OrderCreatePayload {
  lineItems?: string[];
  orderNumber: string;
  shippingAddress?: object;
}

export interface OrderCreateSuccessResponseBody {
  meta?: object;
  order: Order;
}

export interface OrderFilter {
  _and?: unknown[];
  _not?: unknown;
  _or?: unknown[];
  status?: NullableStringFilter | string;
}

export interface OrderIndexSuccessResponseBody {
  meta?: object;
  orders: Order[];
  pagination: OffsetPagination;
}

export interface OrderPage {
  number?: number;
  size?: number;
}

export interface OrderShowSuccessResponseBody {
  meta?: object;
  order: Order;
}

export interface OrderSort {
  createdAt?: SortDirection;
  status?: SortDirection;
}

export interface OrderUpdatePayload {
  lineItems?: string[];
  orderNumber?: string;
  shippingAddress?: object;
}

export interface OrderUpdateSuccessResponseBody {
  meta?: object;
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
  filter?: OrderFilter | string[];
  page?: OrderPage;
  sort?: OrderSort | string[];
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

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}
