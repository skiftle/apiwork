import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const CustomerFilterSchema: z.ZodType<CustomerFilter> = z.lazy(() => z.object({
  AND: z.array(CustomerFilterSchema).optional(),
  NOT: CustomerFilterSchema.optional(),
  OR: z.array(CustomerFilterSchema).optional(),
  name: z.union([z.string(), StringFilterSchema]).optional()
}));

export const OrderFilterSchema: z.ZodType<OrderFilter> = z.lazy(() => z.object({
  AND: z.array(OrderFilterSchema).optional(),
  NOT: OrderFilterSchema.optional(),
  OR: z.array(OrderFilterSchema).optional(),
  orderNumber: z.union([z.string(), StringFilterSchema]).optional()
}));

export const CustomerSchema = z.object({
  billingCity: z.string().nullable(),
  billingCountry: z.string().nullable(),
  billingStreet: z.string().nullable(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  name: z.string(),
  updatedAt: z.iso.datetime()
});

export const CustomerCreatePayloadSchema = z.object({
  billingCity: z.string().nullable().optional(),
  billingCountry: z.string().nullable().optional(),
  billingStreet: z.string().nullable().optional(),
  name: z.string()
});

export const CustomerPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CustomerUpdatePayloadSchema = z.object({
  billingCity: z.string().nullable().optional(),
  billingCountry: z.string().nullable().optional(),
  billingStreet: z.string().nullable().optional(),
  name: z.string().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
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
  customerId: z.string(),
  id: z.string(),
  orderNumber: z.string(),
  shippingCity: z.string().nullable(),
  shippingCountry: z.string().nullable(),
  shippingStreet: z.string().nullable(),
  updatedAt: z.iso.datetime()
});

export const OrderCreatePayloadSchema = z.object({
  customerId: z.string(),
  orderNumber: z.string(),
  shippingCity: z.string().nullable().optional(),
  shippingCountry: z.string().nullable().optional(),
  shippingStreet: z.string().nullable().optional()
});

export const OrderPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const OrderUpdatePayloadSchema = z.object({
  customerId: z.string().optional(),
  orderNumber: z.string().optional(),
  shippingCity: z.string().nullable().optional(),
  shippingCountry: z.string().nullable().optional(),
  shippingStreet: z.string().nullable().optional()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const CustomerCreateSuccessResponseBodySchema = z.object({
  customer: CustomerSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CustomerIndexSuccessResponseBodySchema = z.object({
  customers: z.array(CustomerSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const CustomerShowSuccessResponseBodySchema = z.object({
  customer: CustomerSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CustomerUpdateSuccessResponseBodySchema = z.object({
  customer: CustomerSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
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

export const OrderUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  order: OrderSchema
});

export const ErrorResponseBodySchema = ErrorSchema;

export const CustomersIndexRequestQuerySchema = z.object({
  filter: z.union([CustomerFilterSchema, z.array(CustomerFilterSchema)]).optional(),
  page: CustomerPageSchema.optional()
});

export const CustomersIndexRequestSchema = z.object({
  query: CustomersIndexRequestQuerySchema
});

export const CustomersIndexResponseBodySchema = z.union([CustomerIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CustomersIndexResponseSchema = z.object({
  body: CustomersIndexResponseBodySchema
});

export const CustomersShowResponseBodySchema = z.union([CustomerShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CustomersShowResponseSchema = z.object({
  body: CustomersShowResponseBodySchema
});

export const CustomersCreateRequestBodySchema = z.object({
  customer: CustomerCreatePayloadSchema
});

export const CustomersCreateRequestSchema = z.object({
  body: CustomersCreateRequestBodySchema
});

export const CustomersCreateResponseBodySchema = z.union([CustomerCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CustomersCreateResponseSchema = z.object({
  body: CustomersCreateResponseBodySchema
});

export const CustomersUpdateRequestBodySchema = z.object({
  customer: CustomerUpdatePayloadSchema
});

export const CustomersUpdateRequestSchema = z.object({
  body: CustomersUpdateRequestBodySchema
});

export const CustomersUpdateResponseBodySchema = z.union([CustomerUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CustomersUpdateResponseSchema = z.object({
  body: CustomersUpdateResponseBodySchema
});

export const CustomersDestroyResponseSchema = z.never();

export const OrdersIndexRequestQuerySchema = z.object({
  filter: z.union([OrderFilterSchema, z.array(OrderFilterSchema)]).optional(),
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

export interface Customer {
  billingCity: null | string;
  billingCountry: null | string;
  billingStreet: null | string;
  createdAt: string;
  id: string;
  name: string;
  updatedAt: string;
}

export interface CustomerCreatePayload {
  billingCity?: null | string;
  billingCountry?: null | string;
  billingStreet?: null | string;
  name: string;
}

export interface CustomerCreateSuccessResponseBody {
  customer: Customer;
  meta?: Record<string, unknown>;
}

export interface CustomerFilter {
  AND?: CustomerFilter[];
  NOT?: CustomerFilter;
  OR?: CustomerFilter[];
  name?: StringFilter | string;
}

export interface CustomerIndexSuccessResponseBody {
  customers: Customer[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface CustomerPage {
  number?: number;
  size?: number;
}

export interface CustomerShowSuccessResponseBody {
  customer: Customer;
  meta?: Record<string, unknown>;
}

export interface CustomerUpdatePayload {
  billingCity?: null | string;
  billingCountry?: null | string;
  billingStreet?: null | string;
  name?: string;
}

export interface CustomerUpdateSuccessResponseBody {
  customer: Customer;
  meta?: Record<string, unknown>;
}

export interface CustomersCreateRequest {
  body: CustomersCreateRequestBody;
}

export interface CustomersCreateRequestBody {
  customer: CustomerCreatePayload;
}

export interface CustomersCreateResponse {
  body: CustomersCreateResponseBody;
}

export type CustomersCreateResponseBody = CustomerCreateSuccessResponseBody | ErrorResponseBody;

export type CustomersDestroyResponse = never;

export interface CustomersIndexRequest {
  query: CustomersIndexRequestQuery;
}

export interface CustomersIndexRequestQuery {
  filter?: CustomerFilter | CustomerFilter[];
  page?: CustomerPage;
}

export interface CustomersIndexResponse {
  body: CustomersIndexResponseBody;
}

export type CustomersIndexResponseBody = CustomerIndexSuccessResponseBody | ErrorResponseBody;

export interface CustomersShowResponse {
  body: CustomersShowResponseBody;
}

export type CustomersShowResponseBody = CustomerShowSuccessResponseBody | ErrorResponseBody;

export interface CustomersUpdateRequest {
  body: CustomersUpdateRequestBody;
}

export interface CustomersUpdateRequestBody {
  customer: CustomerUpdatePayload;
}

export interface CustomersUpdateResponse {
  body: CustomersUpdateResponseBody;
}

export type CustomersUpdateResponseBody = CustomerUpdateSuccessResponseBody | ErrorResponseBody;

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

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Order {
  createdAt: string;
  customerId: string;
  id: string;
  orderNumber: string;
  shippingCity: null | string;
  shippingCountry: null | string;
  shippingStreet: null | string;
  updatedAt: string;
}

export interface OrderCreatePayload {
  customerId: string;
  orderNumber: string;
  shippingCity?: null | string;
  shippingCountry?: null | string;
  shippingStreet?: null | string;
}

export interface OrderCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderFilter {
  AND?: OrderFilter[];
  NOT?: OrderFilter;
  OR?: OrderFilter[];
  orderNumber?: StringFilter | string;
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
  customerId?: string;
  orderNumber?: string;
  shippingCity?: null | string;
  shippingCountry?: null | string;
  shippingStreet?: null | string;
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

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}
