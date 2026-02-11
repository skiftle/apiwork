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

export interface ArticleCreateSuccessResponseBody {
  article: Article;
  meta?: Record<string, unknown>;
}

export interface ArticleFilter {
  AND?: Filter[];
  NOT?: Filter;
  OR?: Filter[];
  category?: unknown;
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

export interface ArticleUpdateSuccessResponseBody {
  article: Article;
  meta?: Record<string, unknown>;
}

export interface ArticlesCreateRequest {
  query: ArticlesCreateRequestQuery;
  body: ArticlesCreateRequestBody;
}

export interface ArticlesCreateRequestBody {
  article: unknown;
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
  article: unknown;
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

export interface Filter {
  AND?: Filter[];
  NOT?: Filter;
  OR?: Filter[];
  name?: StringFilter | string;
  slug?: StringFilter | string;
}

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