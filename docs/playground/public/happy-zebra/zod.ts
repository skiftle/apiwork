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

export const CommentCreateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.object({}).optional()
});

export const CommentIndexSuccessResponseBodySchema = z.object({
  comments: z.array(CommentSchema),
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema
});

export const CommentNestedCreatePayloadSchema = z.object({
  _destroy: z.boolean().optional(),
  _type: z.literal('create'),
  author: z.string(),
  body: z.string(),
  id: z.number().int().optional()
});

export const CommentNestedPayloadSchema = z.discriminatedUnion('_type', [
  CommentNestedCreatePayloadSchema,
  CommentNestedUpdatePayloadSchema
]);

export const CommentNestedUpdatePayloadSchema = z.object({
  _destroy: z.boolean().optional(),
  _type: z.literal('update'),
  author: z.string().optional(),
  body: z.string().optional(),
  id: z.number().int().optional()
});

export const CommentPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CommentShowSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.object({}).optional()
});

export const CommentUpdatePayloadSchema = z.object({
  author: z.string().optional(),
  body: z.string().optional()
});

export const CommentUpdateSuccessResponseBodySchema = z.object({
  comment: CommentSchema,
  meta: z.object({}).optional()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
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

export const PostSchema = z.object({
  comments: z.array(CommentSchema),
  id: z.string(),
  title: z.string()
});

export const PostCreatePayloadSchema = z.object({
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string()
});

export const PostCreateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  post: PostSchema
});

export const PostIndexSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema,
  posts: z.array(PostSchema)
});

export const PostNestedCreatePayloadSchema = z.object({
  _destroy: z.boolean().optional(),
  _type: z.literal('create'),
  comments: z.array(CommentNestedPayloadSchema).optional(),
  id: z.number().int().optional(),
  title: z.string()
});

export const PostNestedPayloadSchema = z.discriminatedUnion('_type', [
  PostNestedCreatePayloadSchema,
  PostNestedUpdatePayloadSchema
]);

export const PostNestedUpdatePayloadSchema = z.object({
  _destroy: z.boolean().optional(),
  _type: z.literal('update'),
  comments: z.array(CommentNestedPayloadSchema).optional(),
  id: z.number().int().optional(),
  title: z.string().optional()
});

export const PostPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const PostShowSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  post: PostSchema
});

export const PostUpdatePayloadSchema = z.object({
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string().optional()
});

export const PostUpdateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  post: PostSchema
});

export const ProfileSchema = z.object({
  bio: z.string().nullable(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  updatedAt: z.iso.datetime(),
  user: z.object({}).optional(),
  website: z.string().nullable()
});

export const ProfileNestedCreatePayloadSchema = z.object({
  _destroy: z.boolean().optional(),
  _type: z.literal('create'),
  bio: z.string().nullable().optional(),
  id: z.number().int().optional(),
  website: z.string().nullable().optional()
});

export const ProfileNestedPayloadSchema = z.discriminatedUnion('_type', [
  ProfileNestedCreatePayloadSchema,
  ProfileNestedUpdatePayloadSchema
]);

export const ProfileNestedUpdatePayloadSchema = z.object({
  _destroy: z.boolean().optional(),
  _type: z.literal('update'),
  bio: z.string().nullable().optional(),
  id: z.number().int().optional(),
  website: z.string().nullable().optional()
});

export const ProfileSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
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

export const UserCreatePayloadSchema = z.object({
  email: z.string(),
  posts: z.array(PostNestedPayloadSchema).optional(),
  profile: ProfileNestedPayloadSchema.optional(),
  username: z.string()
});

export const UserCreateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  user: UserSchema
});

export const UserFilterSchema = z.object({
  _and: z.array(z.unknown()).optional(),
  _not: z.unknown().optional(),
  _or: z.array(z.unknown()).optional(),
  email: z.union([z.string(), StringFilterSchema]).optional(),
  username: z.union([z.string(), StringFilterSchema]).optional()
});

export const UserIndexSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema,
  users: z.array(UserSchema)
});

export const UserPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const UserShowSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  user: UserSchema
});

export const UserSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const UserUpdatePayloadSchema = z.object({
  email: z.string().optional(),
  posts: z.array(PostNestedPayloadSchema).optional(),
  profile: ProfileNestedPayloadSchema.optional(),
  username: z.string().optional()
});

export const UserUpdateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  user: UserSchema
});

export const UsersIndexRequestQuerySchema = z.object({
  filter: z.union([UserFilterSchema, z.array(z.string())]).optional(),
  page: UserPageSchema.optional(),
  sort: z.union([UserSortSchema, z.array(z.string())]).optional()
});

export const UsersIndexRequestSchema = z.object({
  query: UsersIndexRequestQuerySchema
});

export const UsersIndexResponseBodySchema = z.union([UserIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersIndexResponseSchema = z.object({
  body: UsersIndexResponseBodySchema
});

export const UsersShowResponseBodySchema = z.union([UserShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersShowResponseSchema = z.object({
  body: UsersShowResponseBodySchema
});

export const UsersCreateRequestBodySchema = z.object({
  user: UserCreatePayloadSchema
});

export const UsersCreateRequestSchema = z.object({
  body: UsersCreateRequestBodySchema
});

export const UsersCreateResponseBodySchema = z.union([UserCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersCreateResponseSchema = z.object({
  body: UsersCreateResponseBodySchema
});

export const UsersUpdateRequestBodySchema = z.object({
  user: UserUpdatePayloadSchema
});

export const UsersUpdateRequestSchema = z.object({
  body: UsersUpdateRequestBodySchema
});

export const UsersUpdateResponseBodySchema = z.union([UserUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const UsersUpdateResponseSchema = z.object({
  body: UsersUpdateResponseBodySchema
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
  meta?: object;
}

export interface CommentIndexSuccessResponseBody {
  comments: Comment[];
  meta?: object;
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
  _and?: unknown[];
  _not?: unknown;
  _or?: unknown[];
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
  filter?: UserFilter | string[];
  page?: UserPage;
  sort?: UserSort | string[];
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
