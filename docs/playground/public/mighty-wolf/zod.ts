import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CarSchema = z.object({
  brand: z.string(),
  color: z.string().nullable(),
  doors: z.number().int().nullable(),
  id: z.string(),
  kind: z.literal('car'),
  model: z.string(),
  year: z.number().int().nullable()
});

export const CarCreatePayloadSchema = z.object({
  brand: z.string(),
  color: z.string().nullable().optional(),
  doors: z.number().int().nullable().optional(),
  kind: z.literal('car'),
  model: z.string(),
  year: z.number().int().nullable().optional()
});

export const CarUpdatePayloadSchema = z.object({
  brand: z.string().optional(),
  color: z.string().nullable().optional(),
  doors: z.number().int().nullable().optional(),
  kind: z.literal('car').optional(),
  model: z.string().optional(),
  year: z.number().int().nullable().optional()
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
  kind: z.literal('motorcycle'),
  model: z.string(),
  year: z.number().int().nullable()
});

export const MotorcycleCreatePayloadSchema = z.object({
  brand: z.string(),
  color: z.string().nullable().optional(),
  engineCc: z.number().int().nullable().optional(),
  kind: z.literal('motorcycle'),
  model: z.string(),
  year: z.number().int().nullable().optional()
});

export const MotorcycleUpdatePayloadSchema = z.object({
  brand: z.string().optional(),
  color: z.string().nullable().optional(),
  engineCc: z.number().int().nullable().optional(),
  kind: z.literal('motorcycle').optional(),
  model: z.string().optional(),
  year: z.number().int().nullable().optional()
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
  kind: z.literal('truck'),
  model: z.string(),
  payloadCapacity: z.number().nullable(),
  year: z.number().int().nullable()
});

export const TruckCreatePayloadSchema = z.object({
  brand: z.string(),
  color: z.string().nullable().optional(),
  kind: z.literal('truck'),
  model: z.string(),
  payloadCapacity: z.number().nullable().optional(),
  year: z.number().int().nullable().optional()
});

export const TruckUpdatePayloadSchema = z.object({
  brand: z.string().optional(),
  color: z.string().nullable().optional(),
  kind: z.literal('truck').optional(),
  model: z.string().optional(),
  payloadCapacity: z.number().nullable().optional(),
  year: z.number().int().nullable().optional()
});

export const VehiclePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const VehicleSortSchema = z.object({
  year: SortDirectionSchema.optional()
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

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const VehicleSchema = z.discriminatedUnion('kind', [
  CarSchema,
  MotorcycleSchema,
  TruckSchema
]);

export const VehicleFilterSchema: z.ZodType<VehicleFilter> = z.lazy(() => z.object({
  _and: z.array(VehicleFilterSchema).optional(),
  _not: VehicleFilterSchema.optional(),
  _or: z.array(VehicleFilterSchema).optional(),
  brand: z.union([z.string(), StringFilterSchema]).optional(),
  model: z.union([z.string(), StringFilterSchema]).optional(),
  year: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
}));

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
  vehicle: z.discriminatedUnion('kind', [CarCreatePayloadSchema, MotorcycleCreatePayloadSchema, TruckCreatePayloadSchema])
});

export const VehiclesCreateRequestSchema = z.object({
  body: VehiclesCreateRequestBodySchema
});

export const VehiclesCreateResponseBodySchema = z.union([VehicleCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const VehiclesCreateResponseSchema = z.object({
  body: VehiclesCreateResponseBodySchema
});

export const VehiclesUpdateRequestBodySchema = z.object({
  vehicle: z.discriminatedUnion('kind', [CarUpdatePayloadSchema, MotorcycleUpdatePayloadSchema, TruckUpdatePayloadSchema])
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
  kind: 'car';
  model: string;
  year: null | number;
}

export interface CarCreatePayload {
  brand: string;
  color?: null | string;
  doors?: null | number;
  kind: 'car';
  model: string;
  year?: null | number;
}

export interface CarUpdatePayload {
  brand?: string;
  color?: null | string;
  doors?: null | number;
  kind?: 'car';
  model?: string;
  year?: null | number;
}

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
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
  kind: 'motorcycle';
  model: string;
  year: null | number;
}

export interface MotorcycleCreatePayload {
  brand: string;
  color?: null | string;
  engineCc?: null | number;
  kind: 'motorcycle';
  model: string;
  year?: null | number;
}

export interface MotorcycleUpdatePayload {
  brand?: string;
  color?: null | string;
  engineCc?: null | number;
  kind?: 'motorcycle';
  model?: string;
  year?: null | number;
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
  kind: 'truck';
  model: string;
  payloadCapacity: null | number;
  year: null | number;
}

export interface TruckCreatePayload {
  brand: string;
  color?: null | string;
  kind: 'truck';
  model: string;
  payloadCapacity?: null | number;
  year?: null | number;
}

export interface TruckUpdatePayload {
  brand?: string;
  color?: null | string;
  kind?: 'truck';
  model?: string;
  payloadCapacity?: null | number;
  year?: null | number;
}

export type Vehicle = Car | Motorcycle | Truck;

export interface VehicleCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehicleFilter {
  _and?: VehicleFilter[];
  _not?: VehicleFilter;
  _or?: VehicleFilter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
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

export interface VehicleUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: CarCreatePayload | MotorcycleCreatePayload | TruckCreatePayload;
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
  vehicle: CarUpdatePayload | MotorcycleUpdatePayload | TruckUpdatePayload;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = ErrorResponseBody | VehicleUpdateSuccessResponseBody;
