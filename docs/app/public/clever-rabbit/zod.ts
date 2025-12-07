import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  starts_with: z.string().optional()
});

export const OrderSchema = z.object({
  created_at: z.iso.datetime().optional(),
  id: z.unknown().optional(),
  line_items: z.array(z.string()),
  order_number: z.string().optional(),
  shipping_address: z.object({}),
  status: z.string().optional(),
  total: z.number().optional(),
  updated_at: z.iso.datetime().optional()
});

export const OrderCreatePayloadSchema = z.object({
  line_items: z.array(z.string()).optional(),
  order_number: z.string(),
  shipping_address: z.object({}).optional()
});

export const OrderIncludeSchema = z.object({

});

export const OrderPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const OrderSortSchema = z.object({
  created_at: z.unknown().optional(),
  status: z.unknown().optional()
});

export const OrderUpdatePayloadSchema = z.object({
  line_items: z.array(z.string()).optional(),
  order_number: z.string().optional(),
  shipping_address: z.object({}).optional()
});

export const PagePaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  starts_with: z.string().optional()
});

export const OrderFilterSchema: z.ZodType<OrderFilter> = z.lazy(() => z.object({
  _and: z.array(OrderFilterSchema).optional(),
  _not: OrderFilterSchema.optional(),
  _or: z.array(OrderFilterSchema).optional(),
  status: z.union([z.string(), NullableStringFilterSchema]).optional()
}));

export const OrderSchema = z.object({
  created_at: z.iso.datetime(),
  id: z.never(),
  order_number: z.string(),
  status: z.string().nullable().optional(),
  total: z.number().nullable().optional(),
  updated_at: z.iso.datetime()
});

export const OrdersIndexRequestQuerySchema = z.object({
  filter: z.union([OrderFilterSchema, z.array(OrderFilterSchema)]).optional(),
  include: OrderIncludeSchema.optional(),
  page: OrderPageSchema.optional(),
  sort: z.union([OrderSortSchema, z.array(OrderSortSchema)]).optional()
});

export const OrdersIndexRequestSchema = z.object({
  query: OrdersIndexRequestQuerySchema
});

export const OrdersIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), orders: z.array(OrderSchema).optional(), pagination: PagePaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const OrdersIndexResponseSchema = z.object({
  body: OrdersIndexResponseBodySchema
});

export const OrdersShowRequestQuerySchema = z.object({
  include: OrderIncludeSchema.optional()
});

export const OrdersShowRequestSchema = z.object({
  query: OrdersShowRequestQuerySchema
});

export const OrdersShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), order: OrderSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const OrdersShowResponseSchema = z.object({
  body: OrdersShowResponseBodySchema
});

export const OrdersCreateRequestQuerySchema = z.object({
  include: OrderIncludeSchema.optional()
});

export const OrdersCreateRequestBodySchema = z.object({
  order: OrderCreatePayloadSchema
});

export const OrdersCreateRequestSchema = z.object({
  query: OrdersCreateRequestQuerySchema,
  body: OrdersCreateRequestBodySchema
});

export const OrdersCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), order: OrderSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const OrdersCreateResponseSchema = z.object({
  body: OrdersCreateResponseBodySchema
});

export const OrdersUpdateRequestQuerySchema = z.object({
  include: OrderIncludeSchema.optional()
});

export const OrdersUpdateRequestBodySchema = z.object({
  order: OrderUpdatePayloadSchema
});

export const OrdersUpdateRequestSchema = z.object({
  query: OrdersUpdateRequestQuerySchema,
  body: OrdersUpdateRequestBodySchema
});

export const OrdersUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), order: OrderSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const OrdersUpdateResponseSchema = z.object({
  body: OrdersUpdateResponseBodySchema
});

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface NullableStringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  starts_with?: string;
}

export interface Order {
  created_at: string;
  id: never;
  order_number: string;
  status?: null | string;
  total?: null | number;
  updated_at: string;
}

export interface Order {
  created_at?: string;
  id?: unknown;
  line_items: string[];
  order_number?: string;
  shipping_address: object;
  status?: string;
  total?: number;
  updated_at?: string;
}

export interface OrderCreatePayload {
  line_items?: string[];
  order_number: string;
  shipping_address?: object;
}

export interface OrderFilter {
  _and?: OrderFilter[];
  _not?: OrderFilter;
  _or?: OrderFilter[];
  status?: NullableStringFilter | string;
}

export type OrderInclude = object;

export interface OrderPage {
  number?: number;
  size?: number;
}

export interface OrderSort {
  created_at?: unknown;
  status?: unknown;
}

export interface OrderUpdatePayload {
  line_items?: string[];
  order_number?: string;
  shipping_address?: object;
}

export interface OrdersCreateRequest {
  query: OrdersCreateRequestQuery;
  body: OrdersCreateRequestBody;
}

export interface OrdersCreateRequestBody {
  order: OrderCreatePayload;
}

export interface OrdersCreateRequestQuery {
  include?: OrderInclude;
}

export interface OrdersCreateResponse {
  body: OrdersCreateResponseBody;
}

export type OrdersCreateResponseBody = { issues?: Issue[] } | { meta?: object; order: Order };

export interface OrdersIndexRequest {
  query: OrdersIndexRequestQuery;
}

export interface OrdersIndexRequestQuery {
  filter?: OrderFilter | OrderFilter[];
  include?: OrderInclude;
  page?: OrderPage;
  sort?: OrderSort | OrderSort[];
}

export interface OrdersIndexResponse {
  body: OrdersIndexResponseBody;
}

export type OrdersIndexResponseBody = { issues?: Issue[] } | { meta?: object; orders?: Order[]; pagination?: PagePagination };

export interface OrdersShowRequest {
  query: OrdersShowRequestQuery;
}

export interface OrdersShowRequestQuery {
  include?: OrderInclude;
}

export interface OrdersShowResponse {
  body: OrdersShowResponseBody;
}

export type OrdersShowResponseBody = { issues?: Issue[] } | { meta?: object; order: Order };

export interface OrdersUpdateRequest {
  query: OrdersUpdateRequestQuery;
  body: OrdersUpdateRequestBody;
}

export interface OrdersUpdateRequestBody {
  order: OrderUpdatePayload;
}

export interface OrdersUpdateRequestQuery {
  include?: OrderInclude;
}

export interface OrdersUpdateResponse {
  body: OrdersUpdateResponseBody;
}

export type OrdersUpdateResponseBody = { issues?: Issue[] } | { meta?: object; order: Order };

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}
