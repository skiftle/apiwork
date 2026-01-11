import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CommentSchema = z.object({
  authorName: z.string().nullable(),
  body: z.string(),
  commentable: CommentCommentableSchema.optional(),
  createdAt: z.iso.datetime(),
  id: z.string()
});

export const CommentCommentableSchema = z.discriminatedUnion('commentableType', [
  PostSchema.extend({ commentableType: z.literal('post') }),
  VideoSchema.extend({ commentableType: z.literal('video') }),
  ImageSchema.extend({ commentableType: z.literal('image') })
]);

export const CommentCreatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string()
});

export const CommentCreateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.object({}).optional()
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
  meta: z.object({}).optional()
});

export const CommentSortSchema = z.object({
  createdAt: SortDirectionSchema.optional()
});

export const CommentUpdatePayloadSchema = z.object({
  authorName: z.string().nullable().optional(),
  body: z.string().optional()
});

export const CommentUpdateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.object({}).optional()
});

export const ImageSchema = z.object({
  comments: z.array(z.object({})).optional(),
  createdAt: z.iso.datetime(),
  height: z.number().int().nullable(),
  id: z.string(),
  title: z.string(),
  url: z.string(),
  width: z.number().int().nullable()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
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
  comments: z.array(z.object({})).optional(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  title: z.string()
});

export const VideoSchema = z.object({
  comments: z.array(z.object({})).optional(),
  createdAt: z.iso.datetime(),
  duration: z.number().int().nullable(),
  id: z.string(),
  title: z.string(),
  url: z.string()
});

export const CommentIndexSuccessResponseBodySchema = z.object({
  comments: z.array(CommentSchema),
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const CommentsIndexRequestQuerySchema = z.object({
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
  createdAt: string;
  id: string;
}

export type CommentCommentable = { commentableType: 'post' } & Post | { commentableType: 'video' } & Video | { commentableType: 'image' } & Image;

export interface CommentCreatePayload {
  authorName?: null | string;
  body: string;
}

export interface CommentCreateSuccessResponseBody {
  comment: Comment;
  meta?: object;
}

export interface CommentInclude {
  commentable?: boolean;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: object;
  pagination: OffsetPagination;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentShowSuccessResponseBody {
  comment: Comment;
  meta?: object;
}

export interface CommentSort {
  createdAt?: SortDirection;
}

export interface CommentUpdatePayload {
  authorName?: null | string;
  body?: string;
}

export interface CommentUpdateSuccessResponseBody {
  comment: Comment;
  meta?: object;
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

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Image {
  comments?: object[];
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
  meta: object;
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
  comments?: object[];
  createdAt: string;
  id: string;
  title: string;
}

export type SortDirection = 'asc' | 'desc';

export interface Video {
  comments?: object[];
  createdAt: string;
  duration: null | number;
  id: string;
  title: string;
  url: string;
}
