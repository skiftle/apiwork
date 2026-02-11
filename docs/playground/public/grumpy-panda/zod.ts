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

export const ActivityCreateSuccessResponseBodySchema = z.object({
  activity: ActivitySchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ActivityPageSchema = z.object({
  after: z.string().optional(),
  before: z.string().optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ActivityShowSuccessResponseBodySchema = z.object({
  activity: ActivitySchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ActivityUpdatePayloadSchema = z.object({
  action: z.string().optional(),
  occurredAt: z.iso.datetime().nullable().optional()
});

export const ActivityUpdateSuccessResponseBodySchema = z.object({
  activity: ActivitySchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CursorPaginationSchema = z.object({
  next: z.string().nullable().optional(),
  prev: z.string().nullable().optional()
});

export const ActivityIndexSuccessResponseBodySchema = z.object({
  activities: z.array(ActivitySchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: CursorPaginationSchema
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ErrorResponseBodySchema = ErrorSchema;

export const ActivitiesIndexRequestQuerySchema = z.object({
  page: ActivityPageSchema.optional()
});

export const ActivitiesIndexRequestSchema = z.object({
  query: ActivitiesIndexRequestQuerySchema
});

export const ActivitiesIndexResponseBodySchema = z.union([ActivityIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ActivitiesIndexResponseSchema = z.object({
  body: ActivitiesIndexResponseBodySchema
});

export const ActivitiesShowResponseBodySchema = z.union([ActivityShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ActivitiesShowResponseSchema = z.object({
  body: ActivitiesShowResponseBodySchema
});

export const ActivitiesCreateRequestBodySchema = z.object({
  activity: ActivityCreatePayloadSchema
});

export const ActivitiesCreateRequestSchema = z.object({
  body: ActivitiesCreateRequestBodySchema
});

export const ActivitiesCreateResponseBodySchema = z.union([ActivityCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ActivitiesCreateResponseSchema = z.object({
  body: ActivitiesCreateResponseBodySchema
});

export const ActivitiesUpdateRequestBodySchema = z.object({
  activity: ActivityUpdatePayloadSchema
});

export const ActivitiesUpdateRequestSchema = z.object({
  body: ActivitiesUpdateRequestBodySchema
});

export const ActivitiesUpdateResponseBodySchema = z.union([ActivityUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

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

export type ActivitiesCreateResponseBody = ActivityCreateSuccessResponseBody | ErrorResponseBody;

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

export type ActivitiesIndexResponseBody = ActivityIndexSuccessResponseBody | ErrorResponseBody;

export interface ActivitiesShowResponse {
  body: ActivitiesShowResponseBody;
}

export type ActivitiesShowResponseBody = ActivityShowSuccessResponseBody | ErrorResponseBody;

export interface ActivitiesUpdateRequest {
  body: ActivitiesUpdateRequestBody;
}

export interface ActivitiesUpdateRequestBody {
  activity: ActivityUpdatePayload;
}

export interface ActivitiesUpdateResponse {
  body: ActivitiesUpdateResponseBody;
}

export type ActivitiesUpdateResponseBody = ActivityUpdateSuccessResponseBody | ErrorResponseBody;

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

export interface ActivityCreateSuccessResponseBody {
  activity: Activity;
  meta?: Record<string, unknown>;
}

export interface ActivityIndexSuccessResponseBody {
  activities: Activity[];
  meta?: Record<string, unknown>;
  pagination: CursorPagination;
}

export interface ActivityPage {
  after?: string;
  before?: string;
  size?: number;
}

export interface ActivityShowSuccessResponseBody {
  activity: Activity;
  meta?: Record<string, unknown>;
}

export interface ActivityUpdatePayload {
  action?: string;
  occurredAt?: null | string;
}

export interface ActivityUpdateSuccessResponseBody {
  activity: Activity;
  meta?: Record<string, unknown>;
}

export interface CursorPagination {
  next?: null | string;
  prev?: null | string;
}

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
