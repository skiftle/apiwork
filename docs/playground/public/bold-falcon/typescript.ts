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

export interface ArticleCreateSuccessResponseBody {
  article: Article;
  meta?: object;
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

export interface ArticleIndexSuccessResponseBody {
  articles: Article[];
  meta?: object;
  pagination: OffsetPagination;
}

export interface ArticlePage {
  number?: number;
  size?: number;
}

export interface ArticleShowSuccessResponseBody {
  article: Article;
  meta?: object;
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
  meta?: object;
}

export interface ArticlesCreateRequest {
  body: ArticlesCreateRequestBody;
}

export interface ArticlesCreateRequestBody {
  article: ArticleCreatePayload;
}

export interface ArticlesCreateResponse {
  body: ArticlesCreateResponseBody;
}

export type ArticlesCreateResponseBody = ArticleCreateSuccessResponseBody | ErrorResponseBody;

export type ArticlesDestroyResponse = never;

export interface ArticlesIndexRequest {
  query: ArticlesIndexRequestQuery;
}

export interface ArticlesIndexRequestQuery {
  filter?: ArticleFilter | ArticleFilter[];
  page?: ArticlePage;
  sort?: ArticleSort | ArticleSort[];
}

export interface ArticlesIndexResponse {
  body: ArticlesIndexResponseBody;
}

export type ArticlesIndexResponseBody = ArticleIndexSuccessResponseBody | ErrorResponseBody;

export interface ArticlesShowResponse {
  body: ArticlesShowResponseBody;
}

export type ArticlesShowResponseBody = ArticleShowSuccessResponseBody | ErrorResponseBody;

export interface ArticlesUpdateRequest {
  body: ArticlesUpdateRequestBody;
}

export interface ArticlesUpdateRequestBody {
  article: ArticleUpdatePayload;
}

export interface ArticlesUpdateResponse {
  body: ArticlesUpdateResponseBody;
}

export type ArticlesUpdateResponseBody = ArticleUpdateSuccessResponseBody | ErrorResponseBody;

export interface DateFilterBetween {
  from?: string;
  to?: string;
}

export interface DecimalFilterBetween {
  from?: number;
  to?: number;
}

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface IntegerFilterBetween {
  from?: number;
  to?: number;
}

export interface Issue {
  code: string;
  detail: string;
  meta: object;
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