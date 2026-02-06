import { z } from 'zod';

export const ArticleStatusSchema = z.enum(['archived', 'draft', 'published']);

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const ArticleCreatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  publishedOn: z.iso.date().nullable().optional(),
  status: ArticleStatusSchema.nullable().optional(),
  title: z.string()
});

export const ArticleIncludeSchema = z.object({
  category: z.boolean().optional()
});

export const ArticlePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ArticleSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  publishedOn: SortDirectionSchema.optional(),
  rating: SortDirectionSchema.optional(),
  status: SortDirectionSchema.optional(),
  viewCount: SortDirectionSchema.optional()
});

export const ArticleStatusFilterSchema = z.union([
  ArticleStatusSchema,
  z.object({ eq: ArticleStatusSchema, in: z.array(ArticleStatusSchema) }).partial()
]);

export const ArticleUpdatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  publishedOn: z.iso.date().nullable().optional(),
  status: ArticleStatusSchema.nullable().optional(),
  title: z.string().optional()
});

export const CategorySchema = z.object({
  id: z.string(),
  name: z.string(),
  slug: z.string()
});

export const DateFilterBetweenSchema = z.object({
  from: z.iso.date().optional(),
  to: z.iso.date().optional()
});

export const DecimalFilterBetweenSchema = z.object({
  from: z.number().optional(),
  to: z.number().optional()
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

export const ArticleSchema = z.object({
  body: z.string().nullable(),
  category: CategorySchema.nullable().optional(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  publishedOn: z.iso.date().nullable(),
  rating: z.number().nullable(),
  status: ArticleStatusSchema.nullable(),
  title: z.string(),
  updatedAt: z.iso.datetime(),
  viewCount: z.number().int().nullable()
});

export const NullableDateFilterSchema = z.object({
  between: DateFilterBetweenSchema.optional(),
  eq: z.iso.date().optional(),
  gt: z.iso.date().optional(),
  gte: z.iso.date().optional(),
  in: z.array(z.iso.date()).optional(),
  lt: z.iso.date().optional(),
  lte: z.iso.date().optional(),
  null: z.boolean().optional()
});

export const NullableDecimalFilterSchema = z.object({
  between: DecimalFilterBetweenSchema.optional(),
  eq: z.number().optional(),
  gt: z.number().optional(),
  gte: z.number().optional(),
  in: z.array(z.number()).optional(),
  lt: z.number().optional(),
  lte: z.number().optional(),
  null: z.boolean().optional()
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

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const CategoryFilterSchema: z.ZodType<CategoryFilter> = z.lazy(() => z.object({
  AND: z.array(CategoryFilterSchema).optional(),
  NOT: CategoryFilterSchema.optional(),
  OR: z.array(CategoryFilterSchema).optional(),
  name: z.union([z.string(), StringFilterSchema]).optional(),
  slug: z.union([z.string(), StringFilterSchema]).optional()
}));

export const ArticleCreateSuccessResponseBodySchema = z.object({
  article: ArticleSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ArticleIndexSuccessResponseBodySchema = z.object({
  articles: z.array(ArticleSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const ArticleShowSuccessResponseBodySchema = z.object({
  article: ArticleSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ArticleUpdateSuccessResponseBodySchema = z.object({
  article: ArticleSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ErrorResponseBodySchema = ErrorSchema;

export const ArticleFilterSchema: z.ZodType<ArticleFilter> = z.lazy(() => z.object({
  AND: z.array(ArticleFilterSchema).optional(),
  NOT: ArticleFilterSchema.optional(),
  OR: z.array(ArticleFilterSchema).optional(),
  category: CategoryFilterSchema.optional(),
  publishedOn: z.union([z.iso.date(), NullableDateFilterSchema]).optional(),
  rating: z.union([z.number(), NullableDecimalFilterSchema]).optional(),
  status: ArticleStatusFilterSchema.optional(),
  title: z.union([z.string(), StringFilterSchema]).optional(),
  viewCount: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
}));

export const ArticlesIndexRequestQuerySchema = z.object({
  filter: z.union([ArticleFilterSchema, z.array(ArticleFilterSchema)]).optional(),
  include: ArticleIncludeSchema.optional(),
  page: ArticlePageSchema.optional(),
  sort: z.union([ArticleSortSchema, z.array(ArticleSortSchema)]).optional()
});

export const ArticlesIndexRequestSchema = z.object({
  query: ArticlesIndexRequestQuerySchema
});

export const ArticlesIndexResponseBodySchema = z.union([ArticleIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ArticlesIndexResponseSchema = z.object({
  body: ArticlesIndexResponseBodySchema
});

export const ArticlesShowRequestQuerySchema = z.object({
  include: ArticleIncludeSchema.optional()
});

export const ArticlesShowRequestSchema = z.object({
  query: ArticlesShowRequestQuerySchema
});

export const ArticlesShowResponseBodySchema = z.union([ArticleShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ArticlesShowResponseSchema = z.object({
  body: ArticlesShowResponseBodySchema
});

export const ArticlesCreateRequestQuerySchema = z.object({
  include: ArticleIncludeSchema.optional()
});

export const ArticlesCreateRequestBodySchema = z.object({
  article: ArticleCreatePayloadSchema
});

export const ArticlesCreateRequestSchema = z.object({
  query: ArticlesCreateRequestQuerySchema,
  body: ArticlesCreateRequestBodySchema
});

export const ArticlesCreateResponseBodySchema = z.union([ArticleCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ArticlesCreateResponseSchema = z.object({
  body: ArticlesCreateResponseBodySchema
});

export const ArticlesUpdateRequestQuerySchema = z.object({
  include: ArticleIncludeSchema.optional()
});

export const ArticlesUpdateRequestBodySchema = z.object({
  article: ArticleUpdatePayloadSchema
});

export const ArticlesUpdateRequestSchema = z.object({
  query: ArticlesUpdateRequestQuerySchema,
  body: ArticlesUpdateRequestBodySchema
});

export const ArticlesUpdateResponseBodySchema = z.union([ArticleUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ArticlesUpdateResponseSchema = z.object({
  body: ArticlesUpdateResponseBodySchema
});

export const ArticlesDestroyRequestQuerySchema = z.object({
  include: ArticleIncludeSchema.optional()
});

export const ArticlesDestroyRequestSchema = z.object({
  query: ArticlesDestroyRequestQuerySchema
});

export const ArticlesDestroyResponse = z.never();

export interface Article {
  body: null | string;
  category?: Category | null;
  createdAt: string;
  id: string;
  publishedOn: null | string;
  rating: null | number;
  status: ArticleStatus | null;
  title: string;
  updatedAt: string;
  viewCount: null | number;
}

export interface ArticleCreatePayload {
  body?: null | string;
  publishedOn?: null | string;
  status?: ArticleStatus | null;
  title: string;
}

export interface ArticleCreateSuccessResponseBody {
  article: Article;
  meta?: Record<string, unknown>;
}

export interface ArticleFilter {
  AND?: ArticleFilter[];
  NOT?: ArticleFilter;
  OR?: ArticleFilter[];
  category?: CategoryFilter;
  publishedOn?: NullableDateFilter | string;
  rating?: NullableDecimalFilter | number;
  status?: ArticleStatusFilter;
  title?: StringFilter | string;
  viewCount?: NullableIntegerFilter | number;
}

export interface ArticleInclude {
  category?: boolean;
}

export interface ArticleIndexSuccessResponseBody {
  articles: Article[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface ArticlePage {
  number?: number;
  size?: number;
}

export interface ArticleShowSuccessResponseBody {
  article: Article;
  meta?: Record<string, unknown>;
}

export interface ArticleSort {
  createdAt?: SortDirection;
  publishedOn?: SortDirection;
  rating?: SortDirection;
  status?: SortDirection;
  viewCount?: SortDirection;
}

export type ArticleStatus = 'archived' | 'draft' | 'published';

export type ArticleStatusFilter = ArticleStatus | { eq?: ArticleStatus; in?: ArticleStatus[] };

export interface ArticleUpdatePayload {
  body?: null | string;
  publishedOn?: null | string;
  status?: ArticleStatus | null;
  title?: string;
}

export interface ArticleUpdateSuccessResponseBody {
  article: Article;
  meta?: Record<string, unknown>;
}

export interface ArticlesCreateRequest {
  query: ArticlesCreateRequestQuery;
  body: ArticlesCreateRequestBody;
}

export interface ArticlesCreateRequestBody {
  article: ArticleCreatePayload;
}

export interface ArticlesCreateRequestQuery {
  include?: ArticleInclude;
}

export interface ArticlesCreateResponse {
  body: ArticlesCreateResponseBody;
}

export type ArticlesCreateResponseBody = ArticleCreateSuccessResponseBody | ErrorResponseBody;

export interface ArticlesDestroyRequest {
  query: ArticlesDestroyRequestQuery;
}

export interface ArticlesDestroyRequestQuery {
  include?: ArticleInclude;
}

export type ArticlesDestroyResponse = never;

export interface ArticlesIndexRequest {
  query: ArticlesIndexRequestQuery;
}

export interface ArticlesIndexRequestQuery {
  filter?: ArticleFilter | ArticleFilter[];
  include?: ArticleInclude;
  page?: ArticlePage;
  sort?: ArticleSort | ArticleSort[];
}

export interface ArticlesIndexResponse {
  body: ArticlesIndexResponseBody;
}

export type ArticlesIndexResponseBody = ArticleIndexSuccessResponseBody | ErrorResponseBody;

export interface ArticlesShowRequest {
  query: ArticlesShowRequestQuery;
}

export interface ArticlesShowRequestQuery {
  include?: ArticleInclude;
}

export interface ArticlesShowResponse {
  body: ArticlesShowResponseBody;
}

export type ArticlesShowResponseBody = ArticleShowSuccessResponseBody | ErrorResponseBody;

export interface ArticlesUpdateRequest {
  query: ArticlesUpdateRequestQuery;
  body: ArticlesUpdateRequestBody;
}

export interface ArticlesUpdateRequestBody {
  article: ArticleUpdatePayload;
}

export interface ArticlesUpdateRequestQuery {
  include?: ArticleInclude;
}

export interface ArticlesUpdateResponse {
  body: ArticlesUpdateResponseBody;
}

export type ArticlesUpdateResponseBody = ArticleUpdateSuccessResponseBody | ErrorResponseBody;

export interface Category {
  id: string;
  name: string;
  slug: string;
}

export interface CategoryFilter {
  AND?: CategoryFilter[];
  NOT?: CategoryFilter;
  OR?: CategoryFilter[];
  name?: StringFilter | string;
  slug?: StringFilter | string;
}

export interface DateFilterBetween {
  from?: string;
  to?: string;
}

export interface DecimalFilterBetween {
  from?: number;
  to?: number;
}

export interface Error {
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

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

export interface NullableDateFilter {
  between?: DateFilterBetween;
  eq?: string;
  gt?: string;
  gte?: string;
  in?: string[];
  lt?: string;
  lte?: string;
  null?: boolean;
}

export interface NullableDecimalFilter {
  between?: DecimalFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
  null?: boolean;
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
