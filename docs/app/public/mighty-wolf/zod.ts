import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const IntegerFilterBetweenSchema = z.object({
  from: z.number().int().optional(),
  to: z.number().int().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
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
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const VehicleSchema = z.object({
  brand: z.string().optional(),
  color: z.string().optional(),
  id: z.unknown().optional(),
  model: z.string().optional(),
  type: z.string().optional(),
  year: z.number().int().optional()
});

export const VehicleCreatePayloadSchema = z.object({
  brand: z.string(),
  color: z.string().nullable().optional(),
  model: z.string(),
  year: z.number().int().nullable().optional()
});

export const VehicleIncludeSchema = z.object({

});

export const VehiclePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const VehicleSortSchema = z.object({
  year: z.unknown().optional()
});

export const VehicleUpdatePayloadSchema = z.object({
  brand: z.string().optional(),
  color: z.string().nullable().optional(),
  model: z.string().optional(),
  year: z.number().int().nullable().optional()
});

export const IntegerFilterSchema = z.object({
  between: IntegerFilterBetweenSchema.optional(),
  eq: z.number().int().optional(),
  gt: z.number().int().optional(),
  gte: z.number().int().optional(),
  in: z.array(z.number().int()).optional(),
  lt: z.number().int().optional(),
  lte: z.number().int().optional()
});

export const NullableIntegerFilterSchema = z.object({
  between: IntegerFilterBetweenSchema.optional(),
  eq: z.number().int().optional(),
  gt: z.number().int().optional(),
  gte: z.number().int().optional(),
  in: z.array(z.number().int()).optional(),
  lt: z.number().int().optional(),
  lte: z.number().int().optional(),
  null: z.boolean().optional()
});

export const VehicleFilterSchema: z.ZodType<VehicleFilter> = z.lazy(() => z.object({
  _and: z.array(VehicleFilterSchema).optional(),
  _not: VehicleFilterSchema.optional(),
  _or: z.array(VehicleFilterSchema).optional(),
  brand: z.union([z.string(), StringFilterSchema]).optional(),
  model: z.union([z.string(), StringFilterSchema]).optional(),
  year: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
}));

export const VehicleSchema = z.object({
  brand: z.string(),
  color: z.string().nullable().optional(),
  id: z.never(),
  model: z.string(),
  type: z.string(),
  year: z.number().int().nullable().optional()
});

export const VehiclesIndexRequestQuerySchema = z.object({
  filter: z.union([VehicleFilterSchema, z.array(VehicleFilterSchema)]).optional(),
  include: VehicleIncludeSchema.optional(),
  page: VehiclePageSchema.optional(),
  sort: z.union([VehicleSortSchema, z.array(VehicleSortSchema)]).optional()
});

export const VehiclesIndexRequestSchema = z.object({
  query: VehiclesIndexRequestQuerySchema
});

export const VehiclesIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: PagePaginationSchema.optional(), vehicles: z.array(VehicleSchema).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const VehiclesIndexResponseSchema = z.object({
  body: VehiclesIndexResponseBodySchema
});

export const VehiclesShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), vehicle: VehicleSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const VehiclesShowResponseSchema = z.object({
  body: VehiclesShowResponseBodySchema
});

export const VehiclesCreateRequestBodySchema = z.object({
  vehicle: VehicleCreatePayloadSchema
});

export const VehiclesCreateRequestSchema = z.object({
  body: VehiclesCreateRequestBodySchema
});

export const VehiclesCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), vehicle: VehicleSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const VehiclesCreateResponseSchema = z.object({
  body: VehiclesCreateResponseBodySchema
});

export const VehiclesUpdateRequestBodySchema = z.object({
  vehicle: VehicleUpdatePayloadSchema
});

export const VehiclesUpdateRequestSchema = z.object({
  body: VehiclesUpdateRequestBodySchema
});

export const VehiclesUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), vehicle: VehicleSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const VehiclesUpdateResponseSchema = z.object({
  body: VehiclesUpdateResponseBodySchema
});

export interface IntegerFilter {
  between?: IntegerFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
}

export interface IntegerFilterBetween {
  from?: number;
  to?: number;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface NullableIntegerFilter {
  between?: IntegerFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
  null?: boolean;
}

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
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface Vehicle {
  brand: string;
  color?: null | string;
  id: never;
  model: string;
  type: string;
  year?: null | number;
}

export interface Vehicle {
  brand?: string;
  color?: string;
  id?: unknown;
  model?: string;
  type?: string;
  year?: number;
}

export interface VehicleCreatePayload {
  brand: string;
  color?: null | string;
  model: string;
  year?: null | number;
}

export interface VehicleFilter {
  _and?: VehicleFilter[];
  _not?: VehicleFilter;
  _or?: VehicleFilter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  year?: NullableIntegerFilter | number;
}

export type VehicleInclude = object;

export interface VehiclePage {
  number?: number;
  size?: number;
}

export interface VehicleSort {
  year?: unknown;
}

export interface VehicleUpdatePayload {
  brand?: string;
  color?: null | string;
  model?: string;
  year?: null | number;
}

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: VehicleCreatePayload;
}

export interface VehiclesCreateResponse {
  body: VehiclesCreateResponseBody;
}

export type VehiclesCreateResponseBody = { issues?: Issue[] } | { meta?: object; vehicle: Vehicle };

export interface VehiclesIndexRequest {
  query: VehiclesIndexRequestQuery;
}

export interface VehiclesIndexRequestQuery {
  filter?: VehicleFilter | VehicleFilter[];
  include?: VehicleInclude;
  page?: VehiclePage;
  sort?: VehicleSort | VehicleSort[];
}

export interface VehiclesIndexResponse {
  body: VehiclesIndexResponseBody;
}

export type VehiclesIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: PagePagination; vehicles?: Vehicle[] };

export interface VehiclesShowResponse {
  body: VehiclesShowResponseBody;
}

export type VehiclesShowResponseBody = { issues?: Issue[] } | { meta?: object; vehicle: Vehicle };

export interface VehiclesUpdateRequest {
  body: VehiclesUpdateRequestBody;
}

export interface VehiclesUpdateRequestBody {
  vehicle: VehicleUpdatePayload;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = { issues?: Issue[] } | { meta?: object; vehicle: Vehicle };
