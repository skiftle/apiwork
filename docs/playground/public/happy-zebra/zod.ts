import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CommentSchema = z.object({
  author: z.string(),
  body: z.string(),
  id: z.string()
});

export const CommentCreatePayloadSchema = z.object({
  author: z.string(),
  body: z.string()
});

export const CommentNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  author: z.string(),
  body: z.string(),
  id: z.string().optional()
});

export const CommentNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const CommentNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  author: z.string().optional(),
  body: z.string().optional(),
  id: z.string().optional()
});

export const CommentPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CommentUpdatePayloadSchema = z.object({
  author: z.string().optional(),
  body: z.string().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const PostNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const PostPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ProfileIncludeSchema = z.object({
  user: z.boolean().optional()
});

export const ProfileNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  bio: z.string().nullable().optional(),
  id: z.string().optional(),
  website: z.string().nullable().optional()
});

export const ProfileNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const ProfileNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  bio: z.string().nullable().optional(),
  id: z.string().optional(),
  website: z.string().nullable().optional()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const UserPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const UserSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const CommentCreateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CommentShowSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const CommentUpdateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const PostSchema = z.object({
  comments: z.array(CommentSchema),
  id: z.string(),
  title: z.string()
});

export const CommentNestedPayloadSchema = z.discriminatedUnion('_op', [
  CommentNestedCreatePayloadSchema,
  CommentNestedUpdatePayloadSchema,
  CommentNestedDeletePayloadSchema
]);

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const CommentIndexSuccessResponseBodySchema = z.object({
  comments: z.array(CommentSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const UserIncludeSchema = z.object({
  profile: ProfileIncludeSchema.optional()
});

export const ProfileNestedPayloadSchema = z.discriminatedUnion('_op', [
  ProfileNestedCreatePayloadSchema,
  ProfileNestedUpdatePayloadSchema,
  ProfileNestedDeletePayloadSchema
]);

export const UserFilterSchema: z.ZodType<UserFilter> = z.lazy(() => z.object({
  _and: z.array(UserFilterSchema).optional(),
  _not: UserFilterSchema.optional(),
  _or: z.array(UserFilterSchema).optional(),
  email: z.union([z.string(), StringFilterSchema]).optional(),
  username: z.union([z.string(), StringFilterSchema]).optional()
}));

export const PostCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  post: PostSchema
});

export const PostIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema,
  posts: z.array(PostSchema)
});

export const PostShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  post: PostSchema
});

export const PostUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  post: PostSchema
});

export const PostCreatePayloadSchema = z.object({
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string()
});

export const PostNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  comments: z.array(CommentNestedPayloadSchema).optional(),
  id: z.string().optional(),
  title: z.string()
});

export const PostNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  comments: z.array(CommentNestedPayloadSchema).optional(),
  id: z.string().optional(),
  title: z.string().optional()
});

export const PostUpdatePayloadSchema = z.object({
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string().optional()
});

export const PostNestedPayloadSchema = z.discriminatedUnion('_op', [
  PostNestedCreatePayloadSchema,
  PostNestedUpdatePayloadSchema,
  PostNestedDeletePayloadSchema
]);

export const UserCreatePayloadSchema = z.object({
  email: z.string(),
  posts: z.array(PostNestedPayloadSchema).optional(),
  profile: ProfileNestedPayloadSchema.optional(),
  username: z.string()
});

export const UserUpdatePayloadSchema = z.object({
  email: z.string().optional(),
  posts: z.array(PostNestedPayloadSchema).optional(),
  profile: ProfileNestedPayloadSchema.optional(),
  username: z.string().optional()
});

export const ProfileSchema = z.object({
  bio: z.string().nullable(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  updatedAt: z.iso.datetime(),
  user: UserSchema.optional(),
  website: z.string().nullable()
});

export const UserSchema = z.object({
  createdAt: z.iso.datetime(),
  email: z.string(),
  id: z.string(),
  posts: z.array(PostSchema),
  profile: ProfileSchema,
  updatedAt: z.iso.datetime(),
  username: z.string()
});

export const UserCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  user: UserSchema
});

export const UserIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema,
  users: z.array(UserSchema)
});

export const UserShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  user: UserSchema
});

export const UserUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  user: UserSchema
});

export const UsersIndexRequestQuerySchema = z.object({
  filter: z.union([UserFilterSchema, z.array(UserFilterSchema)]).optional(),
  include: UserIncludeSchema.optional(),
  page: UserPageSchema.optional(),
  sort: z.union([UserSortSchema, z.array(UserSortSchema)]).optional()
});

export const UsersIndexRequestSchema = z.object({
  query: UsersIndexRequestQuerySchema
});

export const UsersIndexResponseBodySchema = z.union([UserIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersIndexResponseSchema = z.object({
  body: UsersIndexResponseBodySchema
});

export const UsersShowRequestQuerySchema = z.object({
  include: UserIncludeSchema.optional()
});

export const UsersShowRequestSchema = z.object({
  query: UsersShowRequestQuerySchema
});

export const UsersShowResponseBodySchema = z.union([UserShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersShowResponseSchema = z.object({
  body: UsersShowResponseBodySchema
});

export const UsersCreateRequestQuerySchema = z.object({
  include: UserIncludeSchema.optional()
});

export const UsersCreateRequestBodySchema = z.object({
  user: UserCreatePayloadSchema
});

export const UsersCreateRequestSchema = z.object({
  query: UsersCreateRequestQuerySchema,
  body: UsersCreateRequestBodySchema
});

export const UsersCreateResponseBodySchema = z.union([UserCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersCreateResponseSchema = z.object({
  body: UsersCreateResponseBodySchema
});

export const UsersUpdateRequestQuerySchema = z.object({
  include: UserIncludeSchema.optional()
});

export const UsersUpdateRequestBodySchema = z.object({
  user: UserUpdatePayloadSchema
});

export const UsersUpdateRequestSchema = z.object({
  query: UsersUpdateRequestQuerySchema,
  body: UsersUpdateRequestBodySchema
});

export const UsersUpdateResponseBodySchema = z.union([UserUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersUpdateResponseSchema = z.object({
  body: UsersUpdateResponseBodySchema
});

export const UsersDestroyRequestQuerySchema = z.object({
  include: UserIncludeSchema.optional()
});

export const UsersDestroyRequestSchema = z.object({
  query: UsersDestroyRequestQuerySchema
});

export const UsersDestroyResponse = z.never();

export const PostsIndexRequestQuerySchema = z.object({
  page: PostPageSchema.optional()
});

export const PostsIndexRequestSchema = z.object({
  query: PostsIndexRequestQuerySchema
});

export const PostsIndexResponseBodySchema = z.union([PostIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const PostsIndexResponseSchema = z.object({
  body: PostsIndexResponseBodySchema
});

export const PostsShowResponseBodySchema = z.union([PostShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const PostsShowResponseSchema = z.object({
  body: PostsShowResponseBodySchema
});

export const PostsCreateRequestBodySchema = z.object({
  post: PostCreatePayloadSchema
});

export const PostsCreateRequestSchema = z.object({
  body: PostsCreateRequestBodySchema
});

export const PostsCreateResponseBodySchema = z.union([PostCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const PostsCreateResponseSchema = z.object({
  body: PostsCreateResponseBodySchema
});

export const PostsUpdateRequestBodySchema = z.object({
  post: PostUpdatePayloadSchema
});

export const PostsUpdateRequestSchema = z.object({
  body: PostsUpdateRequestBodySchema
});

export const PostsUpdateResponseBodySchema = z.union([PostUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const PostsUpdateResponseSchema = z.object({
  body: PostsUpdateResponseBodySchema
});

export const PostsDestroyResponse = z.never();

export const CommentsIndexRequestQuerySchema = z.object({
  page: CommentPageSchema.optional()
});

export const CommentsIndexRequestSchema = z.object({
  query: CommentsIndexRequestQuerySchema
});

export const CommentsIndexResponseBodySchema = z.union([CommentIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsIndexResponseSchema = z.object({
  body: CommentsIndexResponseBodySchema
});

export const CommentsShowResponseBodySchema = z.union([CommentShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsShowResponseSchema = z.object({
  body: CommentsShowResponseBodySchema
});

export const CommentsCreateRequestBodySchema = z.object({
  comment: CommentCreatePayloadSchema
});

export const CommentsCreateRequestSchema = z.object({
  body: CommentsCreateRequestBodySchema
});

export const CommentsCreateResponseBodySchema = z.union([CommentCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsCreateResponseSchema = z.object({
  body: CommentsCreateResponseBodySchema
});

export const CommentsUpdateRequestBodySchema = z.object({
  comment: CommentUpdatePayloadSchema
});

export const CommentsUpdateRequestSchema = z.object({
  body: CommentsUpdateRequestBodySchema
});

export const CommentsUpdateResponseBodySchema = z.union([CommentUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const CommentsUpdateResponseSchema = z.object({
  body: CommentsUpdateResponseBodySchema
});

export const CommentsDestroyResponse = z.never();

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
  _op?: 'create';
  author: string;
  body: string;
  id?: string;
}

export interface CommentNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type CommentNestedPayload = CommentNestedCreatePayload | CommentNestedUpdatePayload | CommentNestedDeletePayload;

export interface CommentNestedUpdatePayload {
  _op?: 'update';
  author?: string;
  body?: string;
  id?: string;
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
  _op?: 'create';
  comments?: CommentNestedPayload[];
  id?: string;
  title: string;
}

export interface PostNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type PostNestedPayload = PostNestedCreatePayload | PostNestedUpdatePayload | PostNestedDeletePayload;

export interface PostNestedUpdatePayload {
  _op?: 'update';
  comments?: CommentNestedPayload[];
  id?: string;
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
  _op?: 'create';
  bio?: null | string;
  id?: string;
  website?: null | string;
}

export interface ProfileNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type ProfileNestedPayload = ProfileNestedCreatePayload | ProfileNestedUpdatePayload | ProfileNestedDeletePayload;

export interface ProfileNestedUpdatePayload {
  _op?: 'update';
  bio?: null | string;
  id?: string;
  website?: null | string;
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
  sort?: UserSort | UserSort[];
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
