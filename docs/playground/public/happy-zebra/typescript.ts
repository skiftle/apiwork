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
  meta?: Record<string, unknown>;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface CommentNestedCreatePayload {
  _destroy?: boolean;
  _type: 'create';
  author: string;
  body: string;
  id?: number;
}

export type CommentNestedPayload = CommentNestedCreatePayload | CommentNestedUpdatePayload;

export interface CommentNestedUpdatePayload {
  _destroy?: boolean;
  _type: 'update';
  author?: string;
  body?: string;
  id?: number;
}

export interface CommentPage {
  number?: number;
  size?: number;
}

export interface CommentShowSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
}

export interface CommentUpdatePayload {
  author?: string;
  body?: string;
}

export interface CommentUpdateSuccessResponseBody {
  comment: Comment;
  meta?: Record<string, unknown>;
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

export interface PostCreatePayload {
  comments?: CommentNestedPayload[];
  title: string;
}

export interface PostCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  post: Post;
}

export interface PostIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  posts: Post[];
}

export interface PostNestedCreatePayload {
  _destroy?: boolean;
  _type: 'create';
  comments?: CommentNestedPayload[];
  id?: number;
  title: string;
}

export type PostNestedPayload = PostNestedCreatePayload | PostNestedUpdatePayload;

export interface PostNestedUpdatePayload {
  _destroy?: boolean;
  _type: 'update';
  comments?: CommentNestedPayload[];
  id?: number;
  title?: string;
}

export interface PostPage {
  number?: number;
  size?: number;
}

export interface PostShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  post: Post;
}

export interface PostUpdatePayload {
  comments?: CommentNestedPayload[];
  title?: string;
}

export interface PostUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
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
  created_at: string;
  id: string;
  updated_at: string;
  user?: Record<string, unknown>;
  website: null | string;
}

export interface ProfileNestedCreatePayload {
  _destroy?: boolean;
  _type: 'create';
  bio?: null | string;
  id?: number;
  website?: null | string;
}

export type ProfileNestedPayload = ProfileNestedCreatePayload | ProfileNestedUpdatePayload;

export interface ProfileNestedUpdatePayload {
  _destroy?: boolean;
  _type: 'update';
  bio?: null | string;
  id?: number;
  website?: null | string;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}

export interface User {
  created_at: string;
  email: string;
  id: string;
  posts: Post[];
  profile: Profile;
  updated_at: string;
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
  _and?: UserFilter[];
  _not?: UserFilter;
  _or?: UserFilter[];
  email?: StringFilter | string;
  username?: StringFilter | string;
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

export interface UserSort {
  created_at?: SortDirection;
  updated_at?: SortDirection;
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