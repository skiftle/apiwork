export interface Comment {
  authorName?: string;
  body?: string;
  commentableId?: unknown;
  commentableType?: string;
  createdAt?: string;
  id?: unknown;
}

export interface CommentCreatePayload {
  authorName?: null | string;
  body: string;
  commentableId: unknown;
  commentableType: string;
}

export interface CommentFilter {
  _and?: CommentFilter[];
  _not?: CommentFilter;
  _or?: CommentFilter[];
  commentableType?: StringFilter | string;
}

export type CommentInclude = object;

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentSort {
  createdAt?: unknown;
}

export interface CommentUpdatePayload {
  authorName?: null | string;
  body?: string;
  commentableId?: unknown;
  commentableType?: string;
}

export interface CommentsCreateRequest {
  body: CommentsCreateRequestBody;
}

export interface CommentsCreateRequestBody {
  comment: CommentCreatePayload;
}

export interface CommentsCreateResponse {
  body: CommentsCreateResponseBody;
}

export type CommentsCreateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface CommentsIndexRequest {
  query: CommentsIndexRequestQuery;
}

export interface CommentsIndexRequestQuery {
  filter?: CommentFilter | CommentFilter[];
  include?: CommentInclude;
  page?: CommentPage;
  sort?: CommentSort | CommentSort[];
}

export interface CommentsIndexResponse {
  body: CommentsIndexResponseBody;
}

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: PagePagination } | { issues?: Issue[] };

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface CommentsUpdateRequest {
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
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
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}