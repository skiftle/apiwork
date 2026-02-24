export interface Comment {
  author: string;
  body: string;
  id: string;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface CommentNestedCreatePayload {
  OP?: 'create';
  author: string;
  body: string;
}

export interface CommentNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type CommentNestedPayload = CommentNestedCreatePayload | CommentNestedUpdatePayload | CommentNestedDeletePayload;

export interface CommentNestedUpdatePayload {
  OP?: 'update';
  author?: string;
  body?: string;
  id?: string;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

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

export interface Post {
  comments: Comment[];
  id: string;
  title: string;
}

export interface PostIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  posts: Post[];
}

export interface PostNestedCreatePayload {
  OP?: 'create';
  comments?: CommentNestedPayload[];
  title: string;
}

export interface PostNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type PostNestedPayload = PostNestedCreatePayload | PostNestedUpdatePayload | PostNestedDeletePayload;

export interface PostNestedUpdatePayload {
  OP?: 'update';
  comments?: CommentNestedPayload[];
  id?: string;
  title?: string;
}

export interface PostPage {
  number?: number;
  size?: number;
}

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

export interface Profile {
  bio: null | string;
  createdAt: string;
  id: string;
  updatedAt: string;
  user?: User;
  website: null | string;
}

export interface ProfileInclude {
  user?: boolean;
}

export interface ProfileNestedCreatePayload {
  OP?: 'create';
  bio?: null | string;
  website?: null | string;
}

export interface ProfileNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type ProfileNestedPayload = ProfileNestedCreatePayload | ProfileNestedUpdatePayload | ProfileNestedDeletePayload;

export interface ProfileNestedUpdatePayload {
  OP?: 'update';
  bio?: null | string;
  id?: string;
  website?: null | string;
}

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
  meta?: Record<string, unknown>;
  user: User;
}

export interface UserFilter {
  AND?: UserFilter[];
  NOT?: UserFilter;
  OR?: UserFilter[];
  email?: StringFilter | string;
  username?: StringFilter | string;
}

export interface UserInclude {
  profile?: ProfileInclude;
}

export interface UserIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  users: User[];
}

export interface UserPage {
  number?: number;
  size?: number;
}

export interface UserShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  user: User;
}

export interface UserUpdatePayload {
  email?: string;
  posts?: PostNestedPayload[];
  profile?: ProfileNestedPayload;
  username?: string;
}

export interface UserUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  user: User;
}

export interface UsersCreateRequest {
  query: UsersCreateRequestQuery;
  body: UsersCreateRequestBody;
}

export interface UsersCreateRequestBody {
  user: UserCreatePayload;
}

export interface UsersCreateRequestQuery {
  include?: UserInclude;
}

export interface UsersCreateResponse {
  body: UsersCreateResponseBody;
}

export type UsersCreateResponseBody = ErrorResponseBody | UserCreateSuccessResponseBody;

export interface UsersDestroyRequest {
  query: UsersDestroyRequestQuery;
}

export interface UsersDestroyRequestQuery {
  include?: UserInclude;
}

export type UsersDestroyResponse = never;

export interface UsersIndexRequest {
  query: UsersIndexRequestQuery;
}

export interface UsersIndexRequestQuery {
  filter?: UserFilter | UserFilter[];
  include?: UserInclude;
  page?: UserPage;
}

export interface UsersIndexResponse {
  body: UsersIndexResponseBody;
}

export type UsersIndexResponseBody = ErrorResponseBody | UserIndexSuccessResponseBody;

export interface UsersShowRequest {
  query: UsersShowRequestQuery;
}

export interface UsersShowRequestQuery {
  include?: UserInclude;
}

export interface UsersShowResponse {
  body: UsersShowResponseBody;
}

export type UsersShowResponseBody = ErrorResponseBody | UserShowSuccessResponseBody;

export interface UsersUpdateRequest {
  query: UsersUpdateRequestQuery;
  body: UsersUpdateRequestBody;
}

export interface UsersUpdateRequestBody {
  user: UserUpdatePayload;
}

export interface UsersUpdateRequestQuery {
  include?: UserInclude;
}

export interface UsersUpdateResponse {
  body: UsersUpdateResponseBody;
}

export type UsersUpdateResponseBody = ErrorResponseBody | UserUpdateSuccessResponseBody;