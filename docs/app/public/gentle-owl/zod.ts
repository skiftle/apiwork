import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CommentSchema = z.object({
  authorName: z.string().optional(),
  body: z.string().optional(),
  commentableId: z.unknown().optional(),
  commentableType: z.string().optional(),
  createdAt: z.iso.datetime().optional(),
  id: z.unknown().optional()
});

export const CommentCreatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string(),
  commentableId: z.unknown(),
  commentableType: z.string()
});

export const CommentIncludeSchema = z.object({

});

export const CommentPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CommentSortSchema = z.object({
  createdAt: z.unknown().optional()
});

export const CommentUpdatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string().optional(),
  commentableId: z.unknown().optional(),
  commentableType: z.string().optional()
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

export const CommentFilterSchema: z.ZodType<CommentFilter> = z.lazy(() => z.object({
  _and: z.array(CommentFilterSchema).optional(),
  _not: CommentFilterSchema.optional(),
  _or: z.array(CommentFilterSchema).optional(),
  commentableType: z.union([z.string(), StringFilterSchema]).optional()
}));

export const CommentSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string(),
  commentableId: z.never(),
  commentableType: z.string(),
  createdAt: z.iso.datetime(),
  id: z.never()
});

export const CommentsIndexRequestQuerySchema = z.object({
  filter: z.union([CommentFilterSchema, z.array(CommentFilterSchema)]).optional(),
  include: CommentIncludeSchema.optional(),
  page: CommentPageSchema.optional(),
  sort: z.union([CommentSortSchema, z.array(CommentSortSchema)]).optional()
});

export const CommentsIndexRequestSchema = z.object({
  query: CommentsIndexRequestQuerySchema
});

export const CommentsIndexResponseBodySchema = z.union([z.object({ comments: z.array(CommentSchema).optional(), meta: z.object({}).optional(), pagination: PagePaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsIndexResponseSchema = z.object({
  body: CommentsIndexResponseBodySchema
});

export const CommentsShowResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsShowResponseSchema = z.object({
  body: CommentsShowResponseBodySchema
});

export const CommentsCreateRequestBodySchema = z.object({
  comment: CommentCreatePayloadSchema
});

export const CommentsCreateRequestSchema = z.object({
  body: CommentsCreateRequestBodySchema
});

export const CommentsCreateResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsCreateResponseSchema = z.object({
  body: CommentsCreateResponseBodySchema
});

export const CommentsUpdateRequestBodySchema = z.object({
  comment: CommentUpdatePayloadSchema
});

export const CommentsUpdateRequestSchema = z.object({
  body: CommentsUpdateRequestBodySchema
});

export const CommentsUpdateResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsUpdateResponseSchema = z.object({
  body: CommentsUpdateResponseBodySchema
});

export interface Comment {
  authorName?: null | string;
  body: string;
  commentableId: never;
  commentableType: string;
  createdAt: string;
  id: never;
}

export interface Comment {
  authorName?: string;
  body?: string;
  commentableId?: unknown;
  commentableType?: string;
  createdAt?: string;
  id?: unknown;
}

export interface CommentCreatePayload {
  authorName?: null | string;
  body: string;
  commentableId: unknown;
  commentableType: string;
}

export interface CommentFilter {
  _and?: CommentFilter[];
  _not?: CommentFilter;
  _or?: CommentFilter[];
  commentableType?: StringFilter | string;
}

export type CommentInclude = object;

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentSort {
  createdAt?: unknown;
}

export interface CommentUpdatePayload {
  authorName?: null | string;
  body?: string;
  commentableId?: unknown;
  commentableType?: string;
}

export interface CommentsCreateRequest {
  body: CommentsCreateRequestBody;
}

export interface CommentsCreateRequestBody {
  comment: CommentCreatePayload;
}

export interface CommentsCreateResponse {
  body: CommentsCreateResponseBody;
}

export type CommentsCreateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface CommentsIndexRequest {
  query: CommentsIndexRequestQuery;
}

export interface CommentsIndexRequestQuery {
  filter?: CommentFilter | CommentFilter[];
  include?: CommentInclude;
  page?: CommentPage;
  sort?: CommentSort | CommentSort[];
}

export interface CommentsIndexResponse {
  body: CommentsIndexResponseBody;
}

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: PagePagination } | { issues?: Issue[] };

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface CommentsUpdateRequest {
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
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
