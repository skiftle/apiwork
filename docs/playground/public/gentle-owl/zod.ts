import { z } from 'zod';

export const CommentCommentableTypeSchema = z.enum(['image', 'post', 'video']);

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CommentCommentableTypeFilterSchema = z.union([
  CommentCommentableTypeSchema,
  z.object({ eq: CommentCommentableTypeSchema, in: z.array(CommentCommentableTypeSchema) }).partial()
]);

export const CommentCreatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string(),
  commentableId: z.string(),
  commentableType: z.enum(['post', 'video', 'image'])
});

export const CommentIncludeSchema = z.object({
  commentable: z.boolean().optional()
});

export const CommentPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CommentSortSchema = z.object({
  createdAt: SortDirectionSchema.optional()
});

export const CommentUpdatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string().optional(),
  commentableId: z.string().optional(),
  commentableType: z.enum(['post', 'video', 'image']).optional()
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

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const FilterSchema: z.ZodType<Filter> = z.lazy(() => z.object({
  AND: z.array(FilterSchema).optional(),
  NOT: FilterSchema.optional(),
  OR: z.array(FilterSchema).optional(),
  title: z.union([z.string(), StringFilterSchema]).optional()
}));

export const ErrorResponseBodySchema = ErrorSchema;

export const CommentFilterSchema = z.object({
  AND: z.array(FilterSchema).optional(),
  NOT: FilterSchema.optional(),
  OR: z.array(FilterSchema).optional(),
  commentableType: CommentCommentableTypeFilterSchema.optional()
});

export const CommentSchema = z.object({
  authorName: z.string().nullable(),
  body: z.string(),
  commentable: CommentCommentableSchema.optional(),
  commentableId: z.string(),
  commentableType: z.string(),
  createdAt: z.iso.datetime(),
  id: z.string()
});

export const CommentCommentableSchema = z.discriminatedUnion('commentableType', [
  PostSchema.extend({ commentableType: z.literal('post') }),
  VideoSchema.extend({ commentableType: z.literal('video') }),
  ImageSchema.extend({ commentableType: z.literal('image') })
]);

export const CommentCreateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CommentIndexSuccessResponseBodySchema = z.object({
  comments: z.array(CommentSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const CommentShowSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CommentUpdateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ImageSchema = z.object({
  comments: z.array(CommentSchema).optional(),
  createdAt: z.iso.datetime(),
  height: z.number().int().nullable(),
  id: z.string(),
  title: z.string(),
  url: z.string(),
  width: z.number().int().nullable()
});

export const PostSchema = z.object({
  body: z.string().nullable(),
  comments: z.array(CommentSchema).optional(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  title: z.string()
});

export const VideoSchema = z.object({
  comments: z.array(CommentSchema).optional(),
  createdAt: z.iso.datetime(),
  duration: z.number().int().nullable(),
  id: z.string(),
  title: z.string(),
  url: z.string()
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

export const CommentsDestroyResponse = z.never();

export interface Comment {
  authorName: null | string;
  body: string;
  commentable?: CommentCommentable;
  commentableId: string;
  commentableType: string;
  createdAt: string;
  id: string;
}

export type CommentCommentable = { commentableType: 'post' } & Post | { commentableType: 'video' } & Video | { commentableType: 'image' } & Image;

export type CommentCommentableType = 'image' | 'post' | 'video';

export type CommentCommentableTypeFilter = CommentCommentableType | { eq?: CommentCommentableType; in?: CommentCommentableType[] };

export interface CommentCreatePayload {
  authorName?: null | string;
  body: string;
  commentableId: string;
  commentableType: 'image' | 'post' | 'video';
}

export interface CommentCreateSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentFilter {
  AND?: Filter[];
  NOT?: Filter;
  OR?: Filter[];
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
}

export interface CommentUpdatePayload {
  authorName?: null | string;
  body?: string;
  commentableId?: string;
  commentableType?: 'image' | 'post' | 'video';
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

export interface Filter {
  AND?: Filter[];
  NOT?: Filter;
  OR?: Filter[];
  title?: StringFilter | string;
}

export interface Image {
  comments?: Comment[];
  createdAt: string;
  height: null | number;
  id: string;
  title: string;
  url: string;
  width: null | number;
}

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
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface Video {
  comments?: Comment[];
  createdAt: string;
  duration: null | number;
  id: string;
  title: string;
  url: string;
}
