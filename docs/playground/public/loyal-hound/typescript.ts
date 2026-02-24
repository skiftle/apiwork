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