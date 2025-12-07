import { z } from 'zod';

export const ArticleStatusSchema = z.enum(['archived', 'draft', 'published']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const ArticleSchema = z.object({
  body: z.string().optional(),
  category: z.object({}).nullable().optional(),
  created_at: z.iso.datetime().optional(),
  id: z.unknown().optional(),
  published_on: z.iso.date().optional(),
  rating: z.number().optional(),
  status: ArticleStatusSchema.optional(),
  title: z.string().optional(),
  updated_at: z.iso.datetime().optional(),
  view_count: z.number().int().optional()
});

export const ArticleCreatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  published_on: z.iso.date().nullable().optional(),
  status: ArticleStatusSchema.nullable().optional(),
  title: z.string()
});

export const ArticleIncludeSchema = z.object({

});

export const ArticlePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ArticleSortSchema = z.object({
  created_at: z.unknown().optional(),
  published_on: z.unknown().optional(),
  rating: z.unknown().optional(),
  status: z.unknown().optional(),
  view_count: z.unknown().optional()
});

export const ArticleStatusFilterSchema = z.union([
  ArticleStatusSchema,
  z.object({ eq: ArticleStatusSchema, in: z.array(ArticleStatusSchema) }).partial()
]);

export const ArticleUpdatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  published_on: z.iso.date().nullable().optional(),
  status: ArticleStatusSchema.nullable().optional(),
  title: z.string().optional()
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
  field: z.string(),
  path: z.array(z.string())
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  starts_with: z.string().optional()
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
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  starts_with: z.string().optional()
});

export const DateFilterSchema = z.object({
  between: DateFilterBetweenSchema.optional(),
  eq: z.iso.date().optional(),
  gt: z.iso.date().optional(),
  gte: z.iso.date().optional(),
  in: z.array(z.iso.date()).optional(),
  lt: z.iso.date().optional(),
  lte: z.iso.date().optional()
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

export const DecimalFilterSchema = z.object({
  between: DecimalFilterBetweenSchema.optional(),
  eq: z.number().optional(),
  gt: z.number().optional(),
  gte: z.number().optional(),
  in: z.array(z.number()).optional(),
  lt: z.number().optional(),
  lte: z.number().optional()
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

export const IntegerFilterSchema = z.object({
  between: IntegerFilterBetweenSchema.optional(),
  eq: z.number().int().optional(),
  gt: z.number().int().optional(),
  gte: z.number().int().optional(),
  in: z.array(z.number().int()).optional(),
  lt: z.number().int().optional(),
  lte: z.number().int().optional()
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

export const ArticleFilterSchema: z.ZodType<ArticleFilter> = z.lazy(() => z.object({
  _and: z.array(ArticleFilterSchema).optional(),
  _not: ArticleFilterSchema.optional(),
  _or: z.array(ArticleFilterSchema).optional(),
  published_on: z.union([z.iso.date(), NullableDateFilterSchema]).optional(),
  rating: z.union([z.number(), NullableDecimalFilterSchema]).optional(),
  status: ArticleStatusFilterSchema.optional(),
  title: z.union([z.string(), StringFilterSchema]).optional(),
  view_count: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
}));

export const ArticleSchema = z.object({
  body: z.string().nullable().optional(),
  created_at: z.iso.datetime(),
  id: z.never(),
  published_on: z.iso.date().nullable().optional(),
  rating: z.number().nullable().optional(),
  status: z.string().nullable().optional(),
  title: z.string(),
  updated_at: z.iso.datetime(),
  view_count: z.number().int().nullable().optional()
});

export const ArticlesIndexRequestQuerySchema = z.object({
  filter: z.union([ArticleFilterSchema, z.array(ArticleFilterSchema)]).optional(),
  include: ArticleIncludeSchema.optional(),
  page: ArticlePageSchema.optional(),
  sort: z.union([ArticleSortSchema, z.array(ArticleSortSchema)]).optional()
});

export const ArticlesIndexRequestSchema = z.object({
  query: ArticlesIndexRequestQuerySchema
});

export const ArticlesIndexResponseBodySchema = z.union([z.object({ articles: z.array(ArticleSchema).optional(), meta: z.object({}).optional(), pagination: PagePaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ArticlesIndexResponseSchema = z.object({
  body: ArticlesIndexResponseBodySchema
});

export const ArticlesShowRequestQuerySchema = z.object({
  include: ArticleIncludeSchema.optional()
});

export const ArticlesShowRequestSchema = z.object({
  query: ArticlesShowRequestQuerySchema
});

export const ArticlesShowResponseBodySchema = z.union([z.object({ article: ArticleSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

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

export const ArticlesCreateResponseBodySchema = z.union([z.object({ article: ArticleSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

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

export const ArticlesUpdateResponseBodySchema = z.union([z.object({ article: ArticleSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const ArticlesUpdateResponseSchema = z.object({
  body: ArticlesUpdateResponseBodySchema
});

export interface Article {
  body?: null | string;
  created_at: string;
  id: never;
  published_on?: null | string;
  rating?: null | number;
  status?: null | string;
  title: string;
  updated_at: string;
  view_count?: null | number;
}

export interface Article {
  body?: string;
  category?: null | object;
  created_at?: string;
  id?: unknown;
  published_on?: string;
  rating?: number;
  status?: ArticleStatus;
  title?: string;
  updated_at?: string;
  view_count?: number;
}

export interface ArticleCreatePayload {
  body?: null | string;
  published_on?: null | string;
  status?: ArticleStatus | null;
  title: string;
}

export interface ArticleFilter {
  _and?: ArticleFilter[];
  _not?: ArticleFilter;
  _or?: ArticleFilter[];
  published_on?: NullableDateFilter | string;
  rating?: NullableDecimalFilter | number;
  status?: ArticleStatusFilter;
  title?: StringFilter | string;
  view_count?: NullableIntegerFilter | number;
}

export type ArticleInclude = object;

export interface ArticlePage {
  number?: number;
  size?: number;
}

export interface ArticleSort {
  created_at?: unknown;
  published_on?: unknown;
  rating?: unknown;
  status?: unknown;
  view_count?: unknown;
}

export type ArticleStatus = 'archived' | 'draft' | 'published';

export type ArticleStatusFilter = ArticleStatus | { eq?: ArticleStatus; in?: ArticleStatus[] };

export interface ArticleUpdatePayload {
  body?: null | string;
  published_on?: null | string;
  status?: ArticleStatus | null;
  title?: string;
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

export type ArticlesCreateResponseBody = { article: Article; meta?: object } | { issues?: Issue[] };

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

export type ArticlesIndexResponseBody = { articles?: Article[]; meta?: object; pagination?: PagePagination } | { issues?: Issue[] };

export interface ArticlesShowRequest {
  query: ArticlesShowRequestQuery;
}

export interface ArticlesShowRequestQuery {
  include?: ArticleInclude;
}

export interface ArticlesShowResponse {
  body: ArticlesShowResponseBody;
}

export type ArticlesShowResponseBody = { article: Article; meta?: object } | { issues?: Issue[] };

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

export type ArticlesUpdateResponseBody = { article: Article; meta?: object } | { issues?: Issue[] };

export interface DateFilter {
  between?: DateFilterBetween;
  eq?: string;
  gt?: string;
  gte?: string;
  in?: string[];
  lt?: string;
  lte?: string;
}

export interface DateFilterBetween {
  from?: string;
  to?: string;
}

export interface DecimalFilter {
  between?: DecimalFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
}

export interface DecimalFilterBetween {
  from?: number;
  to?: number;
}

export interface IntegerFilter {
  between?: IntegerFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
}

export interface IntegerFilterBetween {
  from?: number;
  to?: number;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

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

export interface NullableStringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  starts_with?: string;
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
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}
