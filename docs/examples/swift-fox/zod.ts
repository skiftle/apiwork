import { z } from 'zod';

export const PostStatusSchema = z.enum(['archived', 'draft', 'published']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  startsWith: z.string().optional()
});

export const PagePaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const PostSchema = z.object({
  body: z.string().optional(),
  createdAt: z.iso.datetime().optional(),
  id: z.number().int().optional(),
  status: PostStatusSchema.optional(),
  title: z.string().optional(),
  updatedAt: z.iso.datetime().optional()
});

export const PostCreatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  status: PostStatusSchema.nullable().optional(),
  title: z.string()
});

export const PostIncludeSchema = z.object({

});

export const PostPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const PostSortSchema = z.object({
  createdAt: z.unknown().optional(),
  status: z.unknown().optional()
});

export const PostStatusFilterSchema = z.union([
  PostStatusSchema,
  z.object({ eq: PostStatusSchema, in: z.array(PostStatusSchema) }).partial()
]);

export const PostUpdatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  status: PostStatusSchema.nullable().optional(),
  title: z.string().optional()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const PostFilterSchema: z.ZodType<PostFilter> = z.lazy(() => z.object({
  _and: z.array(PostFilterSchema).optional(),
  _not: PostFilterSchema.optional(),
  _or: z.array(PostFilterSchema).optional(),
  status: PostStatusFilterSchema.optional(),
  title: z.union([z.string(), StringFilterSchema]).optional()
}));

export const PostSchema = z.object({
  body: z.string().nullable().optional(),
  createdAt: z.iso.datetime(),
  id: z.number().int(),
  status: z.string().nullable().optional(),
  title: z.string(),
  updatedAt: z.iso.datetime()
});

export const PostsIndexRequestQuerySchema = z.object({
  filter: z.union([PostFilterSchema, z.array(PostFilterSchema)]).optional(),
  include: PostIncludeSchema.optional(),
  page: PostPageSchema.optional(),
  sort: z.union([PostSortSchema, z.array(PostSortSchema)]).optional()
});

export const PostsIndexRequestSchema = z.object({
  query: PostsIndexRequestQuerySchema
});

export const PostsIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: PagePaginationSchema.optional(), posts: z.array(PostSchema).optional() }), z.object({ issues: z.array(IssueSchema) })]);

export const PostsIndexResponseSchema = z.object({
  body: PostsIndexResponseBodySchema
});

export const PostsShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(IssueSchema) })]);

export const PostsShowResponseSchema = z.object({
  body: PostsShowResponseBodySchema
});

export const PostsCreateRequestBodySchema = z.object({
  post: PostCreatePayloadSchema
});

export const PostsCreateRequestSchema = z.object({
  body: PostsCreateRequestBodySchema
});

export const PostsCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(IssueSchema) })]);

export const PostsCreateResponseSchema = z.object({
  body: PostsCreateResponseBodySchema
});

export const PostsUpdateRequestBodySchema = z.object({
  post: PostUpdatePayloadSchema
});

export const PostsUpdateRequestSchema = z.object({
  body: PostsUpdateRequestBodySchema
});

export const PostsUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(IssueSchema) })]);

export const PostsUpdateResponseSchema = z.object({
  body: PostsUpdateResponseBodySchema
});

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface NullableStringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  startsWith?: string;
}

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Post {
  body?: null | string;
  createdAt: string;
  id: number;
  status?: null | string;
  title: string;
  updatedAt: string;
}

export interface Post {
  body?: string;
  createdAt?: string;
  id?: number;
  status?: PostStatus;
  title?: string;
  updatedAt?: string;
}

export interface PostCreatePayload {
  body?: null | string;
  status?: PostStatus | null;
  title: string;
}

export interface PostFilter {
  _and?: PostFilter[];
  _not?: PostFilter;
  _or?: PostFilter[];
  status?: PostStatusFilter;
  title?: StringFilter | string;
}

export type PostInclude = object;

export interface PostPage {
  number?: number;
  size?: number;
}

export interface PostSort {
  createdAt?: unknown;
  status?: unknown;
}

export type PostStatus = 'archived' | 'draft' | 'published';

export type PostStatusFilter = PostStatus | { eq?: PostStatus; in?: PostStatus[] };

export interface PostUpdatePayload {
  body?: null | string;
  status?: PostStatus | null;
  title?: string;
}

export interface PostsCreateRequest {
  body: PostsCreateRequestBody;
}

export interface PostsCreateRequestBody {
  post: PostCreatePayload;
}

export interface PostsCreateResponse {
  body: PostsCreateResponseBody;
}

export type PostsCreateResponseBody = { issues: Issue[] } | { meta?: object; post: Post };

export interface PostsIndexRequest {
  query: PostsIndexRequestQuery;
}

export interface PostsIndexRequestQuery {
  filter?: PostFilter | PostFilter[];
  include?: PostInclude;
  page?: PostPage;
  sort?: PostSort | PostSort[];
}

export interface PostsIndexResponse {
  body: PostsIndexResponseBody;
}

export type PostsIndexResponseBody = { issues: Issue[] } | { meta?: object; pagination?: PagePagination; posts?: Post[] };

export interface PostsShowResponse {
  body: PostsShowResponseBody;
}

export type PostsShowResponseBody = { issues: Issue[] } | { meta?: object; post: Post };

export interface PostsUpdateRequest {
  body: PostsUpdateRequestBody;
}

export interface PostsUpdateRequestBody {
  post: PostUpdatePayload;
}

export interface PostsUpdateResponse {
  body: PostsUpdateResponseBody;
}

export type PostsUpdateResponseBody = { issues: Issue[] } | { meta?: object; post: Post };

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}
