export interface Comment {
  author?: string;
  body?: string;
  id?: string;
}

export interface CommentCreatePayload {
  author: string;
  body: string;
}

export type CommentInclude = object;

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

export type CommentsCreateResponseBody = { comment: Comment; meta?: object } | { issues?: Issue[] };

export type CommentsDestroyResponse = never;

export interface CommentsIndexRequest {
  query: CommentsIndexRequestQuery;
}

export interface CommentsIndexRequestQuery {
  include?: CommentInclude;
  page?: CommentPage;
}

export interface CommentsIndexResponse {
  body: CommentsIndexResponseBody;
}

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: OffsetPagination } | { issues?: Issue[] };

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

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Post {
  comments: Comment[];
  id?: string;
  title?: string;
}

export interface PostCreatePayload {
  comments?: CommentNestedPayload[];
  title: string;
}

export interface PostInclude {
  comments?: CommentInclude;
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
  query: PostsCreateRequestQuery;
  body: PostsCreateRequestBody;
}

export interface PostsCreateRequestBody {
  post: PostCreatePayload;
}

export interface PostsCreateRequestQuery {
  include?: PostInclude;
}

export interface PostsCreateResponse {
  body: PostsCreateResponseBody;
}

export type PostsCreateResponseBody = { issues?: Issue[] } | { meta?: object; post: Post };

export type PostsDestroyResponse = never;

export interface PostsIndexRequest {
  query: PostsIndexRequestQuery;
}

export interface PostsIndexRequestQuery {
  include?: PostInclude;
  page?: PostPage;
}

export interface PostsIndexResponse {
  body: PostsIndexResponseBody;
}

export type PostsIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: OffsetPagination; posts?: Post[] };

export interface PostsShowRequest {
  query: PostsShowRequestQuery;
}

export interface PostsShowRequestQuery {
  include?: PostInclude;
}

export interface PostsShowResponse {
  body: PostsShowResponseBody;
}

export type PostsShowResponseBody = { issues?: Issue[] } | { meta?: object; post: Post };

export interface PostsUpdateRequest {
  query: PostsUpdateRequestQuery;
  body: PostsUpdateRequestBody;
}

export interface PostsUpdateRequestBody {
  post: PostUpdatePayload;
}

export interface PostsUpdateRequestQuery {
  include?: PostInclude;
}

export interface PostsUpdateResponse {
  body: PostsUpdateResponseBody;
}

export type PostsUpdateResponseBody = { issues?: Issue[] } | { meta?: object; post: Post };

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface User {
  createdAt?: string;
  email?: string;
  id?: string;
  posts: Post[];
  profile: object;
  updatedAt?: string;
  username?: string;
}

export interface UserCreatePayload {
  email: string;
  posts?: PostNestedPayload[];
  profile?: object;
  username: string;
}

export interface UserFilter {
  _and?: UserFilter[];
  _not?: UserFilter;
  _or?: UserFilter[];
  email?: StringFilter | string;
  username?: StringFilter | string;
}

export interface UserInclude {
  posts?: PostInclude;
  profile?: UserProfileInclude;
}

export interface UserPage {
  number?: number;
  size?: number;
}

export type UserProfileInclude = object;

export interface UserSort {
  createdAt?: SortDirection;
  updatedAt?: SortDirection;
}

export interface UserUpdatePayload {
  email?: string;
  posts?: PostNestedPayload[];
  profile?: object;
  username?: string;
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

export type UsersCreateResponseBody = { issues?: Issue[] } | { meta?: object; user: User };

export type UsersDestroyResponse = never;

export interface UsersIndexRequest {
  query: UsersIndexRequestQuery;
}

export interface UsersIndexRequestQuery {
  filter?: UserFilter | UserFilter[];
  include?: UserInclude;
  page?: UserPage;
  sort?: UserSort | UserSort[];
}

export interface UsersIndexResponse {
  body: UsersIndexResponseBody;
}

export type UsersIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: OffsetPagination; users?: User[] };

export interface UsersShowRequest {
  query: UsersShowRequestQuery;
}

export interface UsersShowRequestQuery {
  include?: UserInclude;
}

export interface UsersShowResponse {
  body: UsersShowResponseBody;
}

export type UsersShowResponseBody = { issues?: Issue[] } | { meta?: object; user: User };

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

export type UsersUpdateResponseBody = { issues?: Issue[] } | { meta?: object; user: User };