import { z } from 'zod';

export const CommentCommentableTypeSchema = z.enum(['post', 'video']);

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CommentSchema: z.ZodType<Comment> = z.lazy(() => z.object({
  authorName: z.string().nullable(),
  body: z.string(),
  commentable: CommentCommentableSchema.optional(),
  commentableId: z.string(),
  commentableType: z.string(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  updatedAt: z.iso.datetime()
}));

export const CommentFilterSchema: z.ZodType<CommentFilter> = z.lazy(() => z.object({
  AND: z.array(CommentFilterSchema).optional(),
  NOT: CommentFilterSchema.optional(),
  OR: z.array(CommentFilterSchema).optional(),
  commentableType: CommentCommentableTypeFilterSchema.optional()
}));

export const CommentCommentableTypeFilterSchema = z.union([
  CommentCommentableTypeSchema,
  z.object({ eq: CommentCommentableTypeSchema, in: z.array(CommentCommentableTypeSchema) }).partial()
]);

export const CommentCreatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string(),
  commentableId: z.string(),
  commentableType: z.enum(['post', 'video'])
});

export const CommentCreateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CommentIncludeSchema = z.object({
  commentable: z.boolean().optional()
});

export const CommentPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CommentShowSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CommentSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const CommentUpdatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string().optional(),
  commentableId: z.string().optional(),
  commentableType: z.enum(['post', 'video']).optional()
});

export const CommentUpdateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
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

export const PostSchema = z.object({
  body: z.string().nullable(),
  comments: z.array(CommentSchema).optional(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  title: z.string(),
  updatedAt: z.iso.datetime()
});

export const VideoSchema = z.object({
  comments: z.array(CommentSchema).optional(),
  createdAt: z.iso.datetime(),
  duration: z.number().int().nullable(),
  id: z.string(),
  title: z.string(),
  updatedAt: z.iso.datetime(),
  url: z.string()
});

export const CommentCommentableSchema = z.discriminatedUnion('commentableType', [
  PostSchema.extend({ commentableType: z.literal('post') }),
  VideoSchema.extend({ commentableType: z.literal('video') })
]);

export const CommentIndexSuccessResponseBodySchema = z.object({
  comments: z.array(CommentSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ErrorResponseBodySchema = ErrorSchema;

export const CommentsIndexRequestQuerySchema = z.object({
  filter: z.union([CommentFilterSchema, z.array(CommentFilterSchema)]).optional(),
  include: CommentIncludeSchema.optional(),
  page: CommentPageSchema.optional(),
  sort: z.union([CommentSortSchema, z.array(CommentSortSchema)]).optional()
});

export const CommentsIndexRequestSchema = z.object({
  query: CommentsIndexRequestQuerySchema
});

export const CommentsIndexResponseBodySchema = z.union([CommentIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsIndexResponseSchema = z.object({
  body: CommentsIndexResponseBodySchema
});

export const CommentsShowRequestQuerySchema = z.object({
  include: CommentIncludeSchema.optional()
});

export const CommentsShowRequestSchema = z.object({
  query: CommentsShowRequestQuerySchema
});

export const CommentsShowResponseBodySchema = z.union([CommentShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsShowResponseSchema = z.object({
  body: CommentsShowResponseBodySchema
});

export const CommentsCreateRequestQuerySchema = z.object({
  include: CommentIncludeSchema.optional()
});

export const CommentsCreateRequestBodySchema = z.object({
  comment: CommentCreatePayloadSchema
});

export const CommentsCreateRequestSchema = z.object({
  query: CommentsCreateRequestQuerySchema,
  body: CommentsCreateRequestBodySchema
});

export const CommentsCreateResponseBodySchema = z.union([CommentCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsCreateResponseSchema = z.object({
  body: CommentsCreateResponseBodySchema
});

export const CommentsUpdateRequestQuerySchema = z.object({
  include: CommentIncludeSchema.optional()
});

export const CommentsUpdateRequestBodySchema = z.object({
  comment: CommentUpdatePayloadSchema
});

export const CommentsUpdateRequestSchema = z.object({
  query: CommentsUpdateRequestQuerySchema,
  body: CommentsUpdateRequestBodySchema
});

export const CommentsUpdateResponseBodySchema = z.union([CommentUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsUpdateResponseSchema = z.object({
  body: CommentsUpdateResponseBodySchema
});

export const CommentsDestroyRequestQuerySchema = z.object({
  include: CommentIncludeSchema.optional()
});

export const CommentsDestroyRequestSchema = z.object({
  query: CommentsDestroyRequestQuerySchema
});

export const CommentsDestroyResponseSchema = z.never();

export interface Comment {
  authorName: null | string;
  body: string;
  commentable?: CommentCommentable;
  commentableId: string;
  commentableType: string;
  createdAt: string;
  id: string;
  updatedAt: string;
}

export type CommentCommentable = { commentableType: 'post' } & Post | { commentableType: 'video' } & Video;

export type CommentCommentableType = 'post' | 'video';

export type CommentCommentableTypeFilter = CommentCommentableType | { eq?: CommentCommentableType; in?: CommentCommentableType[] };

export interface CommentCreatePayload {
  authorName?: null | string;
  body: string;
  commentableId: string;
  commentableType: 'post' | 'video';
}

export interface CommentCreateSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentFilter {
  AND?: CommentFilter[];
  NOT?: CommentFilter;
  OR?: CommentFilter[];
  commentableType?: CommentCommentableTypeFilter;
}

export interface CommentInclude {
  commentable?: boolean;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentShowSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentSort {
  createdAt?: SortDirection;
  updatedAt?: SortDirection;
}

export interface CommentUpdatePayload {
  authorName?: null | string;
  body?: string;
  commentableId?: string;
  commentableType?: 'post' | 'video';
}

export interface CommentUpdateSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentsCreateRequest {
  query: CommentsCreateRequestQuery;
  body: CommentsCreateRequestBody;
}

export interface CommentsCreateRequestBody {
  comment: CommentCreatePayload;
}

export interface CommentsCreateRequestQuery {
  include?: CommentInclude;
}

export interface CommentsCreateResponse {
  body: CommentsCreateResponseBody;
}

export type CommentsCreateResponseBody = CommentCreateSuccessResponseBody | ErrorResponseBody;

export interface CommentsDestroyRequest {
  query: CommentsDestroyRequestQuery;
}

export interface CommentsDestroyRequestQuery {
  include?: CommentInclude;
}

export type CommentsDestroyResponse = never;

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

export type CommentsIndexResponseBody = CommentIndexSuccessResponseBody | ErrorResponseBody;

export interface CommentsShowRequest {
  query: CommentsShowRequestQuery;
}

export interface CommentsShowRequestQuery {
  include?: CommentInclude;
}

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = CommentShowSuccessResponseBody | ErrorResponseBody;

export interface CommentsUpdateRequest {
  query: CommentsUpdateRequestQuery;
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateRequestQuery {
  include?: CommentInclude;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = CommentUpdateSuccessResponseBody | ErrorResponseBody;

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

export interface Post {
  body: null | string;
  comments?: Comment[];
  createdAt: string;
  id: string;
  title: string;
  updatedAt: string;
}

export type SortDirection = 'asc' | 'desc';

export interface Video {
  comments?: Comment[];
  createdAt: string;
  duration: null | number;
  id: string;
  title: string;
  updatedAt: string;
  url: string;
}
