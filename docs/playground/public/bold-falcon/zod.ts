import { z } from 'zod';

export const ArticleStatusSchema = z.enum(['archived', 'draft', 'published']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const ArticleSchema = z.object({
  body: z.string().nullable(),
  category: z.object({}).nullable().optional(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  publishedOn: z.iso.date().nullable(),
  rating: z.number().nullable(),
  status: ArticleStatusSchema.nullable(),
  title: z.string(),
  updatedAt: z.iso.datetime(),
  viewCount: z.number().int().nullable()
});

export const ArticleCreatePayloadSchema = z.object({
  body: z.string().nullable().optional(),
  publishedOn: z.iso.date().nullable().optional(),
  status: ArticleStatusSchema.nullable().optional(),
  title: z.string()
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

export const DateFilterBetweenSchema = z.object({
  from: z.iso.date().optional(),
  to: z.iso.date().optional()
});

export const DecimalFilterBetweenSchema = z.object({
  from: z.number().optional(),
  to: z.number().optional()
});

export const ErrorSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const IntegerFilterBetweenSchema = z.object({
  from: z.number().int().optional(),
  to: z.number().int().optional()
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  startsWith: z.string().optional()
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
  publishedOn: z.union([z.iso.date(), NullableDateFilterSchema]).optional(),
  rating: z.union([z.number(), NullableDecimalFilterSchema]).optional(),
  status: ArticleStatusFilterSchema.optional(),
  title: z.union([z.string(), StringFilterSchema]).optional(),
  viewCount: z.union([z.number().int(), NullableIntegerFilterSchema]).optional()
}));

export const ArticlesIndexRequestQuerySchema = z.object({
  filter: z.union([ArticleFilterSchema, z.array(ArticleFilterSchema)]).optional(),
  page: ArticlePageSchema.optional(),
  sort: z.union([ArticleSortSchema, z.array(ArticleSortSchema)]).optional()
});

export const ArticlesIndexRequestSchema = z.object({
  query: ArticlesIndexRequestQuerySchema
});

export const ArticlesIndexResponseBodySchema = z.union([z.object({ articles: z.array(ArticleSchema).optional(), meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ArticlesIndexResponseSchema = z.object({
  body: ArticlesIndexResponseBodySchema
});

export const ArticlesShowResponseBodySchema = z.union([z.object({ article: ArticleSchema, meta: z.object({}).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ArticlesShowResponseSchema = z.object({
  body: ArticlesShowResponseBodySchema
});

export const ArticlesCreateRequestBodySchema = z.object({
  article: ArticleCreatePayloadSchema
});

export const ArticlesCreateRequestSchema = z.object({
  body: ArticlesCreateRequestBodySchema
});

export const ArticlesCreateResponseBodySchema = z.union([z.object({ article: ArticleSchema, meta: z.object({}).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ArticlesCreateResponseSchema = z.object({
  body: ArticlesCreateResponseBodySchema
});

export const ArticlesUpdateRequestBodySchema = z.object({
  article: ArticleUpdatePayloadSchema
});

export const ArticlesUpdateRequestSchema = z.object({
  body: ArticlesUpdateRequestBodySchema
});

export const ArticlesUpdateResponseBodySchema = z.union([z.object({ article: ArticleSchema, meta: z.object({}).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ArticlesUpdateResponseSchema = z.object({
  body: ArticlesUpdateResponseBodySchema
});

export const ArticlesDestroyResponse = z.never();

export interface Article {
  body: null | string;
  category?: null | object;
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

export interface ArticleFilter {
  _and?: ArticleFilter[];
  _not?: ArticleFilter;
  _or?: ArticleFilter[];
  publishedOn?: NullableDateFilter | string;
  rating?: NullableDecimalFilter | number;
  status?: ArticleStatusFilter;
  title?: StringFilter | string;
  viewCount?: NullableIntegerFilter | number;
}

export interface ArticlePage {
  number?: number;
  size?: number;
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

export interface Error {
  code: string;
  detail: string;
  field: string;
  path: string[];
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
  endsWith?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  startsWith?: string;
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
