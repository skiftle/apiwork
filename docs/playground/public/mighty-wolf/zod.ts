import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const VehicleTypeSchema = z.enum(['car', 'motorcycle', 'truck']);

export const CarSchema = z.object({
  brand: z.string(),
  color: z.string().nullable(),
  doors: z.number().int().nullable(),
  id: z.string(),
  model: z.string(),
  type: z.string(),
  year: z.number().int().nullable()
});

export const IntegerFilterBetweenSchema = z.object({
  from: z.number().int().optional(),
  to: z.number().int().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
});

export const MotorcycleSchema = z.object({
  brand: z.string(),
  color: z.string().nullable(),
  engineCc: z.number().int().nullable(),
  id: z.string(),
  model: z.string(),
  type: z.string(),
  year: z.number().int().nullable()
});

export const OffsetPaginationSchema = z.object({
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

export const TruckSchema = z.object({
  brand: z.string(),
  color: z.string().nullable(),
  id: z.string(),
  model: z.string(),
  payloadCapacity: z.number().nullable(),
  type: z.string(),
  year: z.number().int().nullable()
});

export const VehiclePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const VehicleSortSchema = z.object({
  year: SortDirectionSchema.optional()
});

export const VehicleTypeFilterSchema = z.union([
  VehicleTypeSchema,
  z.object({ eq: VehicleTypeSchema, in: z.array(VehicleTypeSchema) }).partial()
]);

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

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const VehicleSchema = z.discriminatedUnion('type', [
  CarSchema,
  MotorcycleSchema,
  TruckSchema
]);

export const FilterSchema: z.ZodType<Filter> = z.lazy(() => z.object({
  AND: z.array(FilterSchema).optional(),
  NOT: FilterSchema.optional(),
  OR: z.array(FilterSchema).optional(),
  brand: z.union([z.string(), StringFilterSchema]).optional(),
  model: z.union([z.string(), StringFilterSchema]).optional(),
  type: z.unknown().optional(),
  year: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
}));

export const ErrorResponseBodySchema = ErrorSchema;

export const VehicleCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  vehicle: VehicleSchema
});

export const VehicleIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema,
  vehicles: z.array(VehicleSchema)
});

export const VehicleShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  vehicle: VehicleSchema
});

export const VehicleUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  vehicle: VehicleSchema
});

export const VehicleFilterSchema = z.object({
  AND: z.array(FilterSchema).optional(),
  NOT: FilterSchema.optional(),
  OR: z.array(FilterSchema).optional(),
  brand: z.union([z.string(), StringFilterSchema]).optional(),
  model: z.union([z.string(), StringFilterSchema]).optional(),
  type: VehicleTypeFilterSchema.optional(),
  year: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
});

export const VehiclesIndexRequestQuerySchema = z.object({
  filter: z.union([VehicleFilterSchema, z.array(VehicleFilterSchema)]).optional(),
  page: VehiclePageSchema.optional(),
  sort: z.union([VehicleSortSchema, z.array(VehicleSortSchema)]).optional()
});

export const VehiclesIndexRequestSchema = z.object({
  query: VehiclesIndexRequestQuerySchema
});

export const VehiclesIndexResponseBodySchema = z.union([VehicleIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const VehiclesIndexResponseSchema = z.object({
  body: VehiclesIndexResponseBodySchema
});

export const VehiclesShowResponseBodySchema = z.union([VehicleShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const VehiclesShowResponseSchema = z.object({
  body: VehiclesShowResponseBodySchema
});

export const VehiclesCreateRequestBodySchema = z.object({
  vehicle: z.discriminatedUnion('type', [z.unknown(), z.unknown(), z.unknown()])
});

export const VehiclesCreateRequestSchema = z.object({
  body: VehiclesCreateRequestBodySchema
});

export const VehiclesCreateResponseBodySchema = z.union([VehicleCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const VehiclesCreateResponseSchema = z.object({
  body: VehiclesCreateResponseBodySchema
});

export const VehiclesUpdateRequestBodySchema = z.object({
  vehicle: z.discriminatedUnion('type', [z.unknown(), z.unknown(), z.unknown()])
});

export const VehiclesUpdateRequestSchema = z.object({
  body: VehiclesUpdateRequestBodySchema
});

export const VehiclesUpdateResponseBodySchema = z.union([VehicleUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const VehiclesUpdateResponseSchema = z.object({
  body: VehiclesUpdateResponseBodySchema
});

export const VehiclesDestroyResponse = z.never();

export interface Car {
  brand: string;
  color: null | string;
  doors: null | number;
  id: string;
  model: string;
  type: string;
  year: null | number;
}

export interface Error {
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

export interface Filter {
  AND?: Filter[];
  NOT?: Filter;
  OR?: Filter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  type?: unknown;
  year?: NullableIntegerFilter | number;
}

export interface IntegerFilterBetween {
  from?: number;
  to?: number;
}

export interface Issue {
  code: string;
  detail: string;
  meta: Record<string, unknown>;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface Motorcycle {
  brand: string;
  color: null | string;
  engineCc: null | number;
  id: string;
  model: string;
  type: string;
  year: null | number;
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

export interface OffsetPagination {
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

export interface Truck {
  brand: string;
  color: null | string;
  id: string;
  model: string;
  payloadCapacity: null | number;
  type: string;
  year: null | number;
}

export type Vehicle = Car | Motorcycle | Truck;

export interface VehicleCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehicleFilter {
  AND?: Filter[];
  NOT?: Filter;
  OR?: Filter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  type?: VehicleTypeFilter;
  year?: NullableIntegerFilter | number;
}

export interface VehicleIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  vehicles: Vehicle[];
}

export interface VehiclePage {
  number?: number;
  size?: number;
}

export interface VehicleShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehicleSort {
  year?: SortDirection;
}

export type VehicleType = 'car' | 'motorcycle' | 'truck';

export type VehicleTypeFilter = VehicleType | { eq?: VehicleType; in?: VehicleType[] };

export interface VehicleUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: unknown | unknown | unknown;
}

export interface VehiclesCreateResponse {
  body: VehiclesCreateResponseBody;
}

export type VehiclesCreateResponseBody = ErrorResponseBody | VehicleCreateSuccessResponseBody;

export type VehiclesDestroyResponse = never;

export interface VehiclesIndexRequest {
  query: VehiclesIndexRequestQuery;
}

export interface VehiclesIndexRequestQuery {
  filter?: VehicleFilter | VehicleFilter[];
  page?: VehiclePage;
  sort?: VehicleSort | VehicleSort[];
}

export interface VehiclesIndexResponse {
  body: VehiclesIndexResponseBody;
}

export type VehiclesIndexResponseBody = ErrorResponseBody | VehicleIndexSuccessResponseBody;

export interface VehiclesShowResponse {
  body: VehiclesShowResponseBody;
}

export type VehiclesShowResponseBody = ErrorResponseBody | VehicleShowSuccessResponseBody;

export interface VehiclesUpdateRequest {
  body: VehiclesUpdateRequestBody;
}

export interface VehiclesUpdateRequestBody {
  vehicle: unknown | unknown | unknown;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = ErrorResponseBody | VehicleUpdateSuccessResponseBody;
