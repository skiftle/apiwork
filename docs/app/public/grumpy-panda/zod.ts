import { z } from 'zod';

export const ActivitySchema = z.object({
  action: z.string().optional(),
  created_at: z.iso.datetime().optional(),
  id: z.string().optional(),
  occurred_at: z.iso.datetime().optional()
});

export const ActivityCreatePayloadSchema = z.object({
  action: z.string(),
  occurred_at: z.iso.datetime().nullable().optional()
});

export const ActivityIncludeSchema = z.object({

});

export const ActivityPageSchema = z.object({
  after: z.string().optional(),
  before: z.string().optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ActivityUpdatePayloadSchema = z.object({
  action: z.string().optional(),
  occurred_at: z.iso.datetime().nullable().optional()
});

export const CursorPaginationSchema = z.object({
  next_cursor: z.string().nullable().optional(),
  prev_cursor: z.string().nullable().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const ActivitySchema = z.object({
  action: z.string(),
  created_at: z.iso.datetime(),
  id: z.string(),
  occurred_at: z.iso.datetime().nullable().optional()
});

export const ActivitiesIndexRequestQuerySchema = z.object({
  include: ActivityIncludeSchema.optional(),
  page: ActivityPageSchema.optional()
});

export const ActivitiesIndexRequestSchema = z.object({
  query: ActivitiesIndexRequestQuerySchema
});

export const ActivitiesIndexResponseBodySchema = z.union([z.object({ activities: z.array(ActivitySchema).optional(), meta: z.object({}).optional(), pagination: CursorPaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ActivitiesIndexResponseSchema = z.object({
  body: ActivitiesIndexResponseBodySchema
});

export const ActivitiesShowResponseBodySchema = z.union([z.object({ activity: ActivitySchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ActivitiesShowResponseSchema = z.object({
  body: ActivitiesShowResponseBodySchema
});

export const ActivitiesCreateRequestBodySchema = z.object({
  activity: ActivityCreatePayloadSchema
});

export const ActivitiesCreateRequestSchema = z.object({
  body: ActivitiesCreateRequestBodySchema
});

export const ActivitiesCreateResponseBodySchema = z.union([z.object({ activity: ActivitySchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ActivitiesCreateResponseSchema = z.object({
  body: ActivitiesCreateResponseBodySchema
});

export const ActivitiesUpdateRequestBodySchema = z.object({
  activity: ActivityUpdatePayloadSchema
});

export const ActivitiesUpdateRequestSchema = z.object({
  body: ActivitiesUpdateRequestBodySchema
});

export const ActivitiesUpdateResponseBodySchema = z.union([z.object({ activity: ActivitySchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ActivitiesUpdateResponseSchema = z.object({
  body: ActivitiesUpdateResponseBodySchema
});

export interface ActivitiesCreateRequest {
  body: ActivitiesCreateRequestBody;
}

export interface ActivitiesCreateRequestBody {
  activity: ActivityCreatePayload;
}

export interface ActivitiesCreateResponse {
  body: ActivitiesCreateResponseBody;
}

export type ActivitiesCreateResponseBody = { activity: Activity; meta?: object } | { issues?: Issue[] };

export interface ActivitiesIndexRequest {
  query: ActivitiesIndexRequestQuery;
}

export interface ActivitiesIndexRequestQuery {
  include?: ActivityInclude;
  page?: ActivityPage;
}

export interface ActivitiesIndexResponse {
  body: ActivitiesIndexResponseBody;
}

export type ActivitiesIndexResponseBody = { activities?: Activity[]; meta?: object; pagination?: CursorPagination } | { issues?: Issue[] };

export interface ActivitiesShowResponse {
  body: ActivitiesShowResponseBody;
}

export type ActivitiesShowResponseBody = { activity: Activity; meta?: object } | { issues?: Issue[] };

export interface ActivitiesUpdateRequest {
  body: ActivitiesUpdateRequestBody;
}

export interface ActivitiesUpdateRequestBody {
  activity: ActivityUpdatePayload;
}

export interface ActivitiesUpdateResponse {
  body: ActivitiesUpdateResponseBody;
}

export type ActivitiesUpdateResponseBody = { activity: Activity; meta?: object } | { issues?: Issue[] };

export interface Activity {
  action: string;
  created_at: string;
  id: string;
  occurred_at?: null | string;
}

export interface Activity {
  action?: string;
  created_at?: string;
  id?: string;
  occurred_at?: string;
}

export interface ActivityCreatePayload {
  action: string;
  occurred_at?: null | string;
}

export type ActivityInclude = object;

export interface ActivityPage {
  after?: string;
  before?: string;
  size?: number;
}

export interface ActivityUpdatePayload {
  action?: string;
  occurred_at?: null | string;
}

export interface CursorPagination {
  next_cursor?: null | string;
  prev_cursor?: null | string;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}
