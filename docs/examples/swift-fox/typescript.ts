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