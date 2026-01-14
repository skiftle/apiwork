export interface Comment {
  author_name: null | string;
  body: string;
  commentable?: CommentCommentable;
  created_at: string;
  id: string;
}

export type CommentCommentable = { commentable_type: 'post' } & Post | { commentable_type: 'video' } & Video | { commentable_type: 'image' } & Image;

export interface CommentCreatePayload {
  author_name?: null | string;
  body: string;
}

export interface CommentCreateSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentInclude {
  commentable?: boolean;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentShowSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentSort {
  created_at?: SortDirection;
}

export interface CommentUpdatePayload {
  author_name?: null | string;
  body?: string;
}

export interface CommentUpdateSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentsCreateRequest {
  query: CommentsCreateRequestQuery;
  body: CommentsCreateRequestBody;
}

export interface CommentsCreateRequestBody {
  comment: CommentCreatePayload;
}

export interface CommentsCreateRequestQuery {
  include?: CommentInclude;
}

export interface CommentsCreateResponse {
  body: CommentsCreateResponseBody;
}

export type CommentsCreateResponseBody = CommentCreateSuccessResponseBody | ErrorResponseBody;

export interface CommentsDestroyRequest {
  query: CommentsDestroyRequestQuery;
}

export interface CommentsDestroyRequestQuery {
  include?: CommentInclude;
}

export type CommentsDestroyResponse = never;

export interface CommentsIndexRequest {
  query: CommentsIndexRequestQuery;
}

export interface CommentsIndexRequestQuery {
  include?: CommentInclude;
  page?: CommentPage;
  sort?: CommentSort | CommentSort[];
}

export interface CommentsIndexResponse {
  body: CommentsIndexResponseBody;
}

export type CommentsIndexResponseBody = CommentIndexSuccessResponseBody | ErrorResponseBody;

export interface CommentsShowRequest {
  query: CommentsShowRequestQuery;
}

export interface CommentsShowRequestQuery {
  include?: CommentInclude;
}

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = CommentShowSuccessResponseBody | ErrorResponseBody;

export interface CommentsUpdateRequest {
  query: CommentsUpdateRequestQuery;
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateRequestQuery {
  include?: CommentInclude;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = CommentUpdateSuccessResponseBody | ErrorResponseBody;

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Image {
  comments?: Record<string, unknown>[];
  created_at: string;
  height: null | number;
  id: string;
  title: string;
  url: string;
  width: null | number;
}

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

export interface Post {
  body: null | string;
  comments?: Record<string, unknown>[];
  created_at: string;
  id: string;
  title: string;
}

export type SortDirection = 'asc' | 'desc';

export interface Video {
  comments?: Record<string, unknown>[];
  created_at: string;
  duration: null | number;
  id: string;
  title: string;
  url: string;
}