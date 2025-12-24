export interface Comment {
  author: string;
  body: string;
  id: string;
}

export interface CommentCreatePayload {
  author: string;
  body: string;
}

export interface CommentNestedCreatePayload {
  _type: 'create';
  author: string;
  body: string;
}

export type CommentNestedPayload = { _type: 'create' } & CommentNestedCreatePayload | { _type: 'update' } & CommentNestedUpdatePayload;

export interface CommentNestedUpdatePayload {
  _type?: 'update';
  author?: string;
  body?: string;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentUpdatePayload {
  author?: string;
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

export type CommentsCreateResponseBody = { comment: Comment; meta?: object } | { errors?: Error[] };

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

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: OffsetPagination } | { errors?: Error[] };

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = { comment: Comment; meta?: object } | { errors?: Error[] };

export interface CommentsUpdateRequest {
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = { comment: Comment; meta?: object } | { errors?: Error[] };

export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  errors: Error[];
  layer: Layer;
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

export interface PostNestedCreatePayload {
  _type: 'create';
  comments?: CommentNestedPayload[];
  title: string;
}

export type PostNestedPayload = { _type: 'create' } & PostNestedCreatePayload | { _type: 'update' } & PostNestedUpdatePayload;

export interface PostNestedUpdatePayload {
  _type?: 'update';
  comments?: CommentNestedPayload[];
  title?: string;
}

export interface PostPage {
  number?: number;
  size?: number;
}

export interface PostUpdatePayload {
  comments?: CommentNestedPayload[];
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

export type PostsCreateResponseBody = { errors?: Error[] } | { meta?: object; post: Post };

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

export type PostsIndexResponseBody = { errors?: Error[] } | { meta?: object; pagination?: OffsetPagination; posts?: Post[] };

export interface PostsShowResponse {
  body: PostsShowResponseBody;
}

export type PostsShowResponseBody = { errors?: Error[] } | { meta?: object; post: Post };

export interface PostsUpdateRequest {
  body: PostsUpdateRequestBody;
}

export interface PostsUpdateRequestBody {
  post: PostUpdatePayload;
}

export interface PostsUpdateResponse {
  body: PostsUpdateResponseBody;
}

export type PostsUpdateResponseBody = { errors?: Error[] } | { meta?: object; post: Post };

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
  _type?: 'update';
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

export interface UserFilter {
  _and?: UserFilter[];
  _not?: UserFilter;
  _or?: UserFilter[];
  email?: StringFilter | string;
  username?: StringFilter | string;
}

export interface UserPage {
  number?: number;
  size?: number;
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

export interface UsersCreateRequest {
  body: UsersCreateRequestBody;
}

export interface UsersCreateRequestBody {
  user: UserCreatePayload;
}

export interface UsersCreateResponse {
  body: UsersCreateResponseBody;
}

export type UsersCreateResponseBody = { errors?: Error[] } | { meta?: object; user: User };

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

export type UsersIndexResponseBody = { errors?: Error[] } | { meta?: object; pagination?: OffsetPagination; users?: User[] };

export interface UsersShowResponse {
  body: UsersShowResponseBody;
}

export type UsersShowResponseBody = { errors?: Error[] } | { meta?: object; user: User };

export interface UsersUpdateRequest {
  body: UsersUpdateRequestBody;
}

export interface UsersUpdateRequestBody {
  user: UserUpdatePayload;
}

export interface UsersUpdateResponse {
  body: UsersUpdateResponseBody;
}

export type UsersUpdateResponseBody = { errors?: Error[] } | { meta?: object; user: User };