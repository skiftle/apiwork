export interface Comment {
  authorName?: string;
  body?: string;
  commentable?: CommentCommentable;
  createdAt?: string;
  id?: unknown;
}

export type CommentCommentable = { commentableType: 'post' } & Post | { commentableType: 'video' } & Video | { commentableType: 'image' } & Image;

export interface CommentCreatePayload {
  authorName?: null | string;
  body: string;
}

export interface CommentInclude {
  commentable?: boolean;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentSort {
  createdAt?: SortDirection;
}

export interface CommentUpdatePayload {
  authorName?: null | string;
  body?: string;
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

export type CommentsCreateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

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

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: OffsetPagination } | { issues?: Issue[] };

export interface CommentsShowRequest {
  query: CommentsShowRequestQuery;
}

export interface CommentsShowRequestQuery {
  include?: CommentInclude;
}

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

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

export type CommentsUpdateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export interface Image {
  comments?: unknown[];
  createdAt?: string;
  height?: number;
  id?: unknown;
  title?: string;
  url?: string;
  width?: number;
}

export interface ImageFilter {
  _and?: ImageFilter[];
  _not?: ImageFilter;
  _or?: ImageFilter[];
  title?: string | unknown;
}

export type ImageInclude = object;

export interface ImageNestedCreatePayload {
  _type: 'create';
  height?: null | number;
  title: string;
  url: string;
  width?: null | number;
}

export type ImageNestedPayload = { _type: 'create' } & ImageNestedCreatePayload | { _type: 'update' } & ImageNestedUpdatePayload;

export interface ImageNestedUpdatePayload {
  _type?: 'update';
  height?: null | number;
  title?: string;
  url?: string;
  width?: null | number;
}

export interface ImageSort {
  createdAt?: SortDirection;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Post {
  body?: string;
  comments?: unknown[];
  createdAt?: string;
  id?: unknown;
  title?: string;
}

export interface PostFilter {
  _and?: PostFilter[];
  _not?: PostFilter;
  _or?: PostFilter[];
  title?: string | unknown;
}

export type PostInclude = object;

export interface PostNestedCreatePayload {
  _type: 'create';
  body?: null | string;
  title: string;
}

export type PostNestedPayload = { _type: 'create' } & PostNestedCreatePayload | { _type: 'update' } & PostNestedUpdatePayload;

export interface PostNestedUpdatePayload {
  _type?: 'update';
  body?: null | string;
  title?: string;
}

export interface PostSort {
  createdAt?: SortDirection;
}

export type SortDirection = 'asc' | 'desc';

export interface Video {
  comments?: unknown[];
  createdAt?: string;
  duration?: number;
  id?: unknown;
  title?: string;
  url?: string;
}

export interface VideoFilter {
  _and?: VideoFilter[];
  _not?: VideoFilter;
  _or?: VideoFilter[];
  title?: string | unknown;
}

export type VideoInclude = object;

export interface VideoNestedCreatePayload {
  _type: 'create';
  duration?: null | number;
  title: string;
  url: string;
}

export type VideoNestedPayload = { _type: 'create' } & VideoNestedCreatePayload | { _type: 'update' } & VideoNestedUpdatePayload;

export interface VideoNestedUpdatePayload {
  _type?: 'update';
  duration?: null | number;
  title?: string;
  url?: string;
}

export interface VideoSort {
  createdAt?: SortDirection;
}