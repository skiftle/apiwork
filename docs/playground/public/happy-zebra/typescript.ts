export interface Comment {
  author: string;
  body: string;
  id: string;
}

export interface CommentCreatePayload {
  author: string;
  body: string;
}

export interface CommentCreateSuccessResponseBody {
  comment: Comment;
  meta?: object;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: object;
  pagination: OffsetPagination;
}

export interface CommentNestedCreatePayload {
  _type: 'create';
  author: string;
  body: string;
}

export type CommentNestedPayload = { _type: 'create' } & CommentNestedCreatePayload | { _type: 'update' } & CommentNestedUpdatePayload;

export interface CommentNestedUpdatePayload {
  _type: 'update';
  author?: string;
  body?: string;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentShowSuccessResponseBody {
  comment: Comment;
  meta?: object;
}

export interface CommentUpdatePayload {
  author?: string;
  body?: string;
}

export interface CommentUpdateSuccessResponseBody {
  comment: Comment;
  meta?: object;
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

export type CommentsCreateResponseBody = CommentCreateSuccessResponseBody | ErrorResponseBody;

export type CommentsDestroyResponse = never;

export interface CommentsIndexRequest {
  query: CommentsIndexRequestQuery;
}

export interface CommentsIndexRequestQuery {
  page?: CommentPage;
}

export interface CommentsIndexResponse {
  body: CommentsIndexResponseBody;
}

export type CommentsIndexResponseBody = CommentIndexSuccessResponseBody | ErrorResponseBody;

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = CommentShowSuccessResponseBody | ErrorResponseBody;

export interface CommentsUpdateRequest {
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = CommentUpdateSuccessResponseBody | ErrorResponseBody;

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Issue {
  code: string;
  detail: string;
  meta: object;
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
  comments: Comment[];
  id: string;
  title: string;
}

export interface PostCreatePayload {
  comments?: CommentNestedPayload[];
  title: string;
}

export interface PostCreateSuccessResponseBody {
  meta?: object;
  post: Post;
}

export interface PostIndexSuccessResponseBody {
  meta?: object;
  pagination: OffsetPagination;
  posts: Post[];
}

export interface PostNestedCreatePayload {
  _type: 'create';
  comments?: CommentNestedPayload[];
  title: string;
}

export type PostNestedPayload = { _type: 'create' } & PostNestedCreatePayload | { _type: 'update' } & PostNestedUpdatePayload;

export interface PostNestedUpdatePayload {
  _type: 'update';
  comments?: CommentNestedPayload[];
  title?: string;
}

export interface PostPage {
  number?: number;
  size?: number;
}

export interface PostShowSuccessResponseBody {
  meta?: object;
  post: Post;
}

export interface PostUpdatePayload {
  comments?: CommentNestedPayload[];
  title?: string;
}

export interface PostUpdateSuccessResponseBody {
  meta?: object;
  post: Post;
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

export type PostsCreateResponseBody = ErrorResponseBody | PostCreateSuccessResponseBody;

export type PostsDestroyResponse = never;

export interface PostsIndexRequest {
  query: PostsIndexRequestQuery;
}

export interface PostsIndexRequestQuery {
  page?: PostPage;
}

export interface PostsIndexResponse {
  body: PostsIndexResponseBody;
}

export type PostsIndexResponseBody = ErrorResponseBody | PostIndexSuccessResponseBody;

export interface PostsShowResponse {
  body: PostsShowResponseBody;
}

export type PostsShowResponseBody = ErrorResponseBody | PostShowSuccessResponseBody;

export interface PostsUpdateRequest {
  body: PostsUpdateRequestBody;
}

export interface PostsUpdateRequestBody {
  post: PostUpdatePayload;
}

export interface PostsUpdateResponse {
  body: PostsUpdateResponseBody;
}

export type PostsUpdateResponseBody = ErrorResponseBody | PostUpdateSuccessResponseBody;

export interface Profile {
  bio: null | string;
  createdAt: string;
  id: string;
  updatedAt: string;
  user?: object;
  website: null | string;
}

export interface ProfileNestedCreatePayload {
  _type: 'create';
  bio?: null | string;
  website?: null | string;
}

export type ProfileNestedPayload = { _type: 'create' } & ProfileNestedCreatePayload | { _type: 'update' } & ProfileNestedUpdatePayload;

export interface ProfileNestedUpdatePayload {
  _type: 'update';
  bio?: null | string;
  website?: null | string;
}

export interface ProfileSort {
  createdAt?: SortDirection;
  updatedAt?: SortDirection;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface User {
  createdAt: string;
  email: string;
  id: string;
  posts: Post[];
  profile: Profile;
  updatedAt: string;
  username: string;
}

export interface UserCreatePayload {
  email: string;
  posts?: PostNestedPayload[];
  profile?: ProfileNestedPayload;
  username: string;
}

export interface UserCreateSuccessResponseBody {
  meta?: object;
  user: User;
}

export interface UserFilter {
  _and?: UserFilter[];
  _not?: UserFilter;
  _or?: UserFilter[];
  email?: StringFilter | string;
  username?: StringFilter | string;
}

export interface UserIndexSuccessResponseBody {
  meta?: object;
  pagination: OffsetPagination;
  users: User[];
}

export interface UserPage {
  number?: number;
  size?: number;
}

export interface UserShowSuccessResponseBody {
  meta?: object;
  user: User;
}

export interface UserSort {
  createdAt?: SortDirection;
  updatedAt?: SortDirection;
}

export interface UserUpdatePayload {
  email?: string;
  posts?: PostNestedPayload[];
  profile?: ProfileNestedPayload;
  username?: string;
}

export interface UserUpdateSuccessResponseBody {
  meta?: object;
  user: User;
}

export interface UsersCreateRequest {
  body: UsersCreateRequestBody;
}

export interface UsersCreateRequestBody {
  user: UserCreatePayload;
}

export interface UsersCreateResponse {
  body: UsersCreateResponseBody;
}

export type UsersCreateResponseBody = ErrorResponseBody | UserCreateSuccessResponseBody;

export type UsersDestroyResponse = never;

export interface UsersIndexRequest {
  query: UsersIndexRequestQuery;
}

export interface UsersIndexRequestQuery {
  filter?: UserFilter | UserFilter[];
  page?: UserPage;
  sort?: UserSort | UserSort[];
}

export interface UsersIndexResponse {
  body: UsersIndexResponseBody;
}

export type UsersIndexResponseBody = ErrorResponseBody | UserIndexSuccessResponseBody;

export interface UsersShowResponse {
  body: UsersShowResponseBody;
}

export type UsersShowResponseBody = ErrorResponseBody | UserShowSuccessResponseBody;

export interface UsersUpdateRequest {
  body: UsersUpdateRequestBody;
}

export interface UsersUpdateRequestBody {
  user: UserUpdatePayload;
}

export interface UsersUpdateResponse {
  body: UsersUpdateResponseBody;
}

export type UsersUpdateResponseBody = ErrorResponseBody | UserUpdateSuccessResponseBody;