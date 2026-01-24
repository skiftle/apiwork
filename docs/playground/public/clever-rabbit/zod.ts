import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

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
  _op: z.literal('create').optional(),
  id: z.string().optional(),
  productName: z.string(),
  quantity: z.number().int().nullable().optional(),
  unitPrice: z.number().nullable().optional()
});

export const LineItemNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const LineItemNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  id: z.string().optional(),
  productName: z.string().optional(),
  quantity: z.number().int().nullable().optional(),
  unitPrice: z.number().nullable().optional()
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

export const OrderPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const OrderSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  status: SortDirectionSchema.optional()
});

export const ShippingAddressSchema = z.object({
  city: z.string(),
  country: z.string(),
  id: z.string(),
  postalCode: z.string(),
  street: z.string()
});

export const ShippingAddressNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  city: z.string(),
  country: z.string(),
  id: z.string().optional(),
  postalCode: z.string(),
  street: z.string()
});

export const ShippingAddressNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const ShippingAddressNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  city: z.string().optional(),
  country: z.string().optional(),
  id: z.string().optional(),
  postalCode: z.string().optional(),
  street: z.string().optional()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const LineItemNestedPayloadSchema = z.discriminatedUnion('_op', [
  LineItemNestedCreatePayloadSchema,
  LineItemNestedUpdatePayloadSchema,
  LineItemNestedDeletePayloadSchema
]);

export const OrderFilterSchema: z.ZodType<OrderFilter> = z.lazy(() => z.object({
  _and: z.array(OrderFilterSchema).optional(),
  _not: OrderFilterSchema.optional(),
  _or: z.array(OrderFilterSchema).optional(),
  status: z.union([z.string(), NullableStringFilterSchema]).optional()
}));

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

export const ShippingAddressNestedPayloadSchema = z.discriminatedUnion('_op', [
  ShippingAddressNestedCreatePayloadSchema,
  ShippingAddressNestedUpdatePayloadSchema,
  ShippingAddressNestedDeletePayloadSchema
]);

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

export const OrderUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  order: OrderSchema
});

export const OrderCreatePayloadSchema = z.object({
  lineItems: z.array(LineItemNestedPayloadSchema).optional(),
  orderNumber: z.string(),
  shippingAddress: ShippingAddressNestedPayloadSchema.optional()
});

export const OrderUpdatePayloadSchema = z.object({
  lineItems: z.array(LineItemNestedPayloadSchema).optional(),
  orderNumber: z.string().optional(),
  shippingAddress: ShippingAddressNestedPayloadSchema.optional()
});

export const OrdersIndexRequestQuerySchema = z.object({
  filter: z.union([OrderFilterSchema, z.array(OrderFilterSchema)]).optional(),
  page: OrderPageSchema.optional(),
  sort: z.union([OrderSortSchema, z.array(OrderSortSchema)]).optional()
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
  _op?: 'create';
  id?: string;
  productName: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

export interface LineItemNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type LineItemNestedPayload = LineItemNestedCreatePayload | LineItemNestedUpdatePayload | LineItemNestedDeletePayload;

export interface LineItemNestedUpdatePayload {
  _op?: 'update';
  id?: string;
  productName?: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

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

export interface OrderFilter {
  _and?: OrderFilter[];
  _not?: OrderFilter;
  _or?: OrderFilter[];
  status?: NullableStringFilter | string;
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

export interface OrderSort {
  createdAt?: SortDirection;
  status?: SortDirection;
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
  filter?: OrderFilter | OrderFilter[];
  page?: OrderPage;
  sort?: OrderSort | OrderSort[];
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
  _op?: 'create';
  city: string;
  country: string;
  id?: string;
  postalCode: string;
  street: string;
}

export interface ShippingAddressNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type ShippingAddressNestedPayload = ShippingAddressNestedCreatePayload | ShippingAddressNestedUpdatePayload | ShippingAddressNestedDeletePayload;

export interface ShippingAddressNestedUpdatePayload {
  _op?: 'update';
  city?: string;
  country?: string;
  id?: string;
  postalCode?: string;
  street?: string;
}

export type SortDirection = 'asc' | 'desc';
