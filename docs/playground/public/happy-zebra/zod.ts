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

export const PostCommentNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  author: z.string(),
  body: z.string(),
  id: z.string().optional()
});

export const PostCommentNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const PostCommentNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  author: z.string().optional(),
  body: z.string().optional(),
  id: z.string().optional()
});

export const PostPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const UserCommentNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  author: z.string(),
  body: z.string(),
  id: z.string().optional()
});

export const UserCommentNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const UserCommentNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  author: z.string().optional(),
  body: z.string().optional(),
  id: z.string().optional()
});

export const UserPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const UserPostNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const UserProfileNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  bio: z.string().nullable().optional(),
  id: z.string().optional(),
  website: z.string().nullable().optional()
});

export const UserProfileNestedDeletePayloadSchema = z.object({
  _op: z.literal('delete').optional(),
  id: z.string()
});

export const UserProfileNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  bio: z.string().nullable().optional(),
  id: z.string().optional(),
  website: z.string().nullable().optional()
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

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const CommentIndexSuccessResponseBodySchema = z.object({
  comments: z.array(CommentSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const PostCommentNestedPayloadSchema = z.discriminatedUnion('_op', [
  PostCommentNestedCreatePayloadSchema,
  PostCommentNestedUpdatePayloadSchema,
  PostCommentNestedDeletePayloadSchema
]);

export const UserFilterSchema: z.ZodType<UserFilter> = z.lazy(() => z.object({
  _and: z.array(UserFilterSchema).optional(),
  _not: UserFilterSchema.optional(),
  _or: z.array(UserFilterSchema).optional(),
  email: z.union([z.string(), StringFilterSchema]).optional(),
  username: z.union([z.string(), StringFilterSchema]).optional()
}));

export const UserCommentNestedPayloadSchema = z.discriminatedUnion('_op', [
  UserCommentNestedCreatePayloadSchema,
  UserCommentNestedUpdatePayloadSchema,
  UserCommentNestedDeletePayloadSchema
]);

export const UserProfileNestedPayloadSchema = z.discriminatedUnion('_op', [
  UserProfileNestedCreatePayloadSchema,
  UserProfileNestedUpdatePayloadSchema,
  UserProfileNestedDeletePayloadSchema
]);

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
  comments: z.array(PostCommentNestedPayloadSchema).optional(),
  title: z.string()
});

export const PostUpdatePayloadSchema = z.object({
  comments: z.array(PostCommentNestedPayloadSchema).optional(),
  title: z.string().optional()
});

export const UserPostNestedCreatePayloadSchema = z.object({
  _op: z.literal('create').optional(),
  comments: z.array(UserCommentNestedPayloadSchema).optional(),
  id: z.string().optional(),
  title: z.string()
});

export const UserPostNestedUpdatePayloadSchema = z.object({
  _op: z.literal('update').optional(),
  comments: z.array(UserCommentNestedPayloadSchema).optional(),
  id: z.string().optional(),
  title: z.string().optional()
});

export const UserPostNestedPayloadSchema = z.discriminatedUnion('_op', [
  UserPostNestedCreatePayloadSchema,
  UserPostNestedUpdatePayloadSchema,
  UserPostNestedDeletePayloadSchema
]);

export const UserCreatePayloadSchema = z.object({
  email: z.string(),
  posts: z.array(UserPostNestedPayloadSchema).optional(),
  profile: UserProfileNestedPayloadSchema.optional(),
  username: z.string()
});

export const UserUpdatePayloadSchema = z.object({
  email: z.string().optional(),
  posts: z.array(UserPostNestedPayloadSchema).optional(),
  profile: UserProfileNestedPayloadSchema.optional(),
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

export const ProfileIncludeSchema = z.object({
  user: z.union([z.boolean(), UserIncludeSchema]).optional()
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

export const UserIncludeSchema = z.object({
  profile: ProfileIncludeSchema.optional()
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

export interface PostCommentNestedCreatePayload {
  _op?: 'create';
  author: string;
  body: string;
  id?: string;
}

export interface PostCommentNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type PostCommentNestedPayload = PostCommentNestedCreatePayload | PostCommentNestedUpdatePayload | PostCommentNestedDeletePayload;

export interface PostCommentNestedUpdatePayload {
  _op?: 'update';
  author?: string;
  body?: string;
  id?: string;
}

export interface PostCreatePayload {
  comments?: PostCommentNestedPayload[];
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

export interface PostPage {
  number?: number;
  size?: number;
}

export interface PostShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  post: Post;
}

export interface PostUpdatePayload {
  comments?: PostCommentNestedPayload[];
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
  user?: UserInclude | boolean;
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

export interface UserCommentNestedCreatePayload {
  _op?: 'create';
  author: string;
  body: string;
  id?: string;
}

export interface UserCommentNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type UserCommentNestedPayload = UserCommentNestedCreatePayload | UserCommentNestedUpdatePayload | UserCommentNestedDeletePayload;

export interface UserCommentNestedUpdatePayload {
  _op?: 'update';
  author?: string;
  body?: string;
  id?: string;
}

export interface UserCreatePayload {
  email: string;
  posts?: UserPostNestedPayload[];
  profile?: UserProfileNestedPayload;
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

export interface UserPostNestedCreatePayload {
  _op?: 'create';
  comments?: UserCommentNestedPayload[];
  id?: string;
  title: string;
}

export interface UserPostNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type UserPostNestedPayload = UserPostNestedCreatePayload | UserPostNestedUpdatePayload | UserPostNestedDeletePayload;

export interface UserPostNestedUpdatePayload {
  _op?: 'update';
  comments?: UserCommentNestedPayload[];
  id?: string;
  title?: string;
}

export interface UserProfileNestedCreatePayload {
  _op?: 'create';
  bio?: null | string;
  id?: string;
  website?: null | string;
}

export interface UserProfileNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type UserProfileNestedPayload = UserProfileNestedCreatePayload | UserProfileNestedUpdatePayload | UserProfileNestedDeletePayload;

export interface UserProfileNestedUpdatePayload {
  _op?: 'update';
  bio?: null | string;
  id?: string;
  website?: null | string;
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
  posts?: UserPostNestedPayload[];
  profile?: UserProfileNestedPayload;
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
