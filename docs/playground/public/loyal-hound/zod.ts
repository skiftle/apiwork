import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const BookFilterSchema: z.ZodType<BookFilter> = z.lazy(() => z.object({
  AND: z.array(BookFilterSchema).optional(),
  NOT: BookFilterSchema.optional(),
  OR: z.array(BookFilterSchema).optional(),
  title: z.union([z.string(), StringFilterSchema]).optional()
}));

export const AuthorSchema = z.object({
  id: z.string(),
  name: z.string()
});

export const BookCreatePayloadSchema = z.object({
  authorId: z.string(),
  publishedOn: z.iso.date().nullable().optional(),
  title: z.string()
});

export const BookIncludeSchema = z.object({
  author: z.boolean().optional(),
  reviews: z.boolean().optional()
});

export const BookPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const BookSortSchema = z.object({
  publishedOn: SortDirectionSchema.optional()
});

export const BookUpdatePayloadSchema = z.object({
  authorId: z.string().optional(),
  publishedOn: z.iso.date().nullable().optional(),
  title: z.string().optional()
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

export const ReviewSchema = z.object({
  body: z.string().nullable(),
  id: z.string(),
  rating: z.number().int()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const BookSchema = z.object({
  author: AuthorSchema.optional(),
  authorId: z.string(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  publishedOn: z.iso.date().nullable(),
  reviews: z.array(ReviewSchema).optional(),
  title: z.string(),
  updatedAt: z.iso.datetime()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const BookCreateSuccessResponseBodySchema = z.object({
  book: BookSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const BookIndexSuccessResponseBodySchema = z.object({
  books: z.array(BookSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const BookShowSuccessResponseBodySchema = z.object({
  book: BookSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const BookUpdateSuccessResponseBodySchema = z.object({
  book: BookSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ErrorResponseBodySchema = ErrorSchema;

export const BooksIndexRequestQuerySchema = z.object({
  filter: z.union([BookFilterSchema, z.array(BookFilterSchema)]).optional(),
  include: BookIncludeSchema.optional(),
  page: BookPageSchema.optional(),
  sort: z.union([BookSortSchema, z.array(BookSortSchema)]).optional()
});

export const BooksIndexRequestSchema = z.object({
  query: BooksIndexRequestQuerySchema
});

export const BooksIndexResponseBodySchema = z.union([BookIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const BooksIndexResponseSchema = z.object({
  body: BooksIndexResponseBodySchema
});

export const BooksShowRequestQuerySchema = z.object({
  include: BookIncludeSchema.optional()
});

export const BooksShowRequestSchema = z.object({
  query: BooksShowRequestQuerySchema
});

export const BooksShowResponseBodySchema = z.union([BookShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const BooksShowResponseSchema = z.object({
  body: BooksShowResponseBodySchema
});

export const BooksCreateRequestQuerySchema = z.object({
  include: BookIncludeSchema.optional()
});

export const BooksCreateRequestBodySchema = z.object({
  book: BookCreatePayloadSchema
});

export const BooksCreateRequestSchema = z.object({
  query: BooksCreateRequestQuerySchema,
  body: BooksCreateRequestBodySchema
});

export const BooksCreateResponseBodySchema = z.union([BookCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const BooksCreateResponseSchema = z.object({
  body: BooksCreateResponseBodySchema
});

export const BooksUpdateRequestQuerySchema = z.object({
  include: BookIncludeSchema.optional()
});

export const BooksUpdateRequestBodySchema = z.object({
  book: BookUpdatePayloadSchema
});

export const BooksUpdateRequestSchema = z.object({
  query: BooksUpdateRequestQuerySchema,
  body: BooksUpdateRequestBodySchema
});

export const BooksUpdateResponseBodySchema = z.union([BookUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const BooksUpdateResponseSchema = z.object({
  body: BooksUpdateResponseBodySchema
});

export const BooksDestroyRequestQuerySchema = z.object({
  include: BookIncludeSchema.optional()
});

export const BooksDestroyRequestSchema = z.object({
  query: BooksDestroyRequestQuerySchema
});

export const BooksDestroyResponseSchema = z.never();

export interface Author {
  id: string;
  name: string;
}

export interface Book {
  author?: Author;
  authorId: string;
  createdAt: string;
  id: string;
  publishedOn: null | string;
  reviews?: Review[];
  title: string;
  updatedAt: string;
}

export interface BookCreatePayload {
  authorId: string;
  publishedOn?: null | string;
  title: string;
}

export interface BookCreateSuccessResponseBody {
  book: Book;
  meta?: Record<string, unknown>;
}

export interface BookFilter {
  AND?: BookFilter[];
  NOT?: BookFilter;
  OR?: BookFilter[];
  title?: StringFilter | string;
}

export interface BookInclude {
  author?: boolean;
  reviews?: boolean;
}

export interface BookIndexSuccessResponseBody {
  books: Book[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface BookPage {
  number?: number;
  size?: number;
}

export interface BookShowSuccessResponseBody {
  book: Book;
  meta?: Record<string, unknown>;
}

export interface BookSort {
  publishedOn?: SortDirection;
}

export interface BookUpdatePayload {
  authorId?: string;
  publishedOn?: null | string;
  title?: string;
}

export interface BookUpdateSuccessResponseBody {
  book: Book;
  meta?: Record<string, unknown>;
}

export interface BooksCreateRequest {
  query: BooksCreateRequestQuery;
  body: BooksCreateRequestBody;
}

export interface BooksCreateRequestBody {
  book: BookCreatePayload;
}

export interface BooksCreateRequestQuery {
  include?: BookInclude;
}

export interface BooksCreateResponse {
  body: BooksCreateResponseBody;
}

export type BooksCreateResponseBody = BookCreateSuccessResponseBody | ErrorResponseBody;

export interface BooksDestroyRequest {
  query: BooksDestroyRequestQuery;
}

export interface BooksDestroyRequestQuery {
  include?: BookInclude;
}

export type BooksDestroyResponse = never;

export interface BooksIndexRequest {
  query: BooksIndexRequestQuery;
}

export interface BooksIndexRequestQuery {
  filter?: BookFilter | BookFilter[];
  include?: BookInclude;
  page?: BookPage;
  sort?: BookSort | BookSort[];
}

export interface BooksIndexResponse {
  body: BooksIndexResponseBody;
}

export type BooksIndexResponseBody = BookIndexSuccessResponseBody | ErrorResponseBody;

export interface BooksShowRequest {
  query: BooksShowRequestQuery;
}

export interface BooksShowRequestQuery {
  include?: BookInclude;
}

export interface BooksShowResponse {
  body: BooksShowResponseBody;
}

export type BooksShowResponseBody = BookShowSuccessResponseBody | ErrorResponseBody;

export interface BooksUpdateRequest {
  query: BooksUpdateRequestQuery;
  body: BooksUpdateRequestBody;
}

export interface BooksUpdateRequestBody {
  book: BookUpdatePayload;
}

export interface BooksUpdateRequestQuery {
  include?: BookInclude;
}

export interface BooksUpdateResponse {
  body: BooksUpdateResponseBody;
}

export type BooksUpdateResponseBody = BookUpdateSuccessResponseBody | ErrorResponseBody;

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

export interface Review {
  body: null | string;
  id: string;
  rating: number;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}
