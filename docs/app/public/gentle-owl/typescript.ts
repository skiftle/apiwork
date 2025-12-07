export interface Comment {
  author_name?: string;
  body?: string;
  commentable_id?: unknown;
  commentable_type?: string;
  created_at?: string;
  id?: unknown;
}

export interface CommentCreatePayload {
  author_name?: null | string;
  body: string;
}

export interface CommentFilter {
  _and?: CommentFilter[];
  _not?: CommentFilter;
  _or?: CommentFilter[];
  commentable_type?: StringFilter | string;
}

export type CommentInclude = object;

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentSort {
  created_at?: unknown;
}

export interface CommentUpdatePayload {
  author_name?: null | string;
  body?: string;
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
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}