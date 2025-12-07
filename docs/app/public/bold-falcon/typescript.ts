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