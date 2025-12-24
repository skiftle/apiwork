import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const ActivitySchema = z.object({
  action: z.string(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  occurredAt: z.iso.datetime().nullable()
});

export const ActivityCreatePayloadSchema = z.object({
  action: z.string(),
  occurredAt: z.iso.datetime().nullable().optional()
});

export const ActivityPageSchema = z.object({
  after: z.string().optional(),
  before: z.string().optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ActivityUpdatePayloadSchema = z.object({
  action: z.string().optional(),
  occurredAt: z.iso.datetime().nullable().optional()
});

export const CursorPaginationSchema = z.object({
  next: z.string().nullable().optional(),
  prev: z.string().nullable().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ActivitiesIndexRequestQuerySchema = z.object({
  page: ActivityPageSchema.optional()
});

export const ActivitiesIndexRequestSchema = z.object({
  query: ActivitiesIndexRequestQuerySchema
});

export const ActivitiesIndexResponseBodySchema = z.union([z.object({ activities: z.array(ActivitySchema).optional(), meta: z.object({}).optional(), pagination: CursorPaginationSchema.optional() }), ErrorResponseBodySchema]);

export const ActivitiesIndexResponseSchema = z.object({
  body: ActivitiesIndexResponseBodySchema
});

export const ActivitiesShowResponseBodySchema = z.union([z.object({ activity: ActivitySchema, meta: z.object({}).optional() }), ErrorResponseBodySchema]);

export const ActivitiesShowResponseSchema = z.object({
  body: ActivitiesShowResponseBodySchema
});

export const ActivitiesCreateRequestBodySchema = z.object({
  activity: ActivityCreatePayloadSchema
});

export const ActivitiesCreateRequestSchema = z.object({
  body: ActivitiesCreateRequestBodySchema
});

export const ActivitiesCreateResponseBodySchema = z.union([z.object({ activity: ActivitySchema, meta: z.object({}).optional() }), ErrorResponseBodySchema]);

export const ActivitiesCreateResponseSchema = z.object({
  body: ActivitiesCreateResponseBodySchema
});

export const ActivitiesUpdateRequestBodySchema = z.object({
  activity: ActivityUpdatePayloadSchema
});

export const ActivitiesUpdateRequestSchema = z.object({
  body: ActivitiesUpdateRequestBodySchema
});

export const ActivitiesUpdateResponseBodySchema = z.union([z.object({ activity: ActivitySchema, meta: z.object({}).optional() }), ErrorResponseBodySchema]);

export const ActivitiesUpdateResponseSchema = z.object({
  body: ActivitiesUpdateResponseBodySchema
});

export const ActivitiesDestroyResponse = z.never();

export interface ActivitiesCreateRequest {
  body: ActivitiesCreateRequestBody;
}

export interface ActivitiesCreateRequestBody {
  activity: ActivityCreatePayload;
}

export interface ActivitiesCreateResponse {
  body: ActivitiesCreateResponseBody;
}

export type ActivitiesCreateResponseBody = ErrorResponseBody | { activity: Activity; meta?: object };

export type ActivitiesDestroyResponse = never;

export interface ActivitiesIndexRequest {
  query: ActivitiesIndexRequestQuery;
}

export interface ActivitiesIndexRequestQuery {
  page?: ActivityPage;
}

export interface ActivitiesIndexResponse {
  body: ActivitiesIndexResponseBody;
}

export type ActivitiesIndexResponseBody = ErrorResponseBody | { activities?: Activity[]; meta?: object; pagination?: CursorPagination };

export interface ActivitiesShowResponse {
  body: ActivitiesShowResponseBody;
}

export type ActivitiesShowResponseBody = ErrorResponseBody | { activity: Activity; meta?: object };

export interface ActivitiesUpdateRequest {
  body: ActivitiesUpdateRequestBody;
}

export interface ActivitiesUpdateRequestBody {
  activity: ActivityUpdatePayload;
}

export interface ActivitiesUpdateResponse {
  body: ActivitiesUpdateResponseBody;
}

export type ActivitiesUpdateResponseBody = ErrorResponseBody | { activity: Activity; meta?: object };

export interface Activity {
  action: string;
  createdAt: string;
  id: string;
  occurredAt: null | string;
}

export interface ActivityCreatePayload {
  action: string;
  occurredAt?: null | string;
}

export interface ActivityPage {
  after?: string;
  before?: string;
  size?: number;
}

export interface ActivityUpdatePayload {
  action?: string;
  occurredAt?: null | string;
}

export interface CursorPagination {
  next?: null | string;
  prev?: null | string;
}

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
