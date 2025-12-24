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
  _type: z.literal('create'),
  author: z.string(),
  body: z.string()
});

export const CommentNestedUpdatePayloadSchema = z.object({
  _type: z.literal('update'),
  author: z.string().optional(),
  body: z.string().optional()
});

export const CommentPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const CommentUpdatePayloadSchema = z.object({
  author: z.string().optional(),
  body: z.string().optional()
});

export const ErrorSchema = z.object({
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

export const PostPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
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
  _type: z.literal('create'),
  bio: z.string().nullable().optional(),
  website: z.string().nullable().optional()
});

export const ProfileNestedUpdatePayloadSchema = z.object({
  _type: z.literal('update'),
  bio: z.string().nullable().optional(),
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

export const UserPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const UserSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const PostSchema = z.object({
  comments: z.array(CommentSchema),
  id: z.string(),
  title: z.string()
});

export const CommentNestedPayloadSchema = z.discriminatedUnion('_type', [
  CommentNestedCreatePayloadSchema,
  CommentNestedUpdatePayloadSchema
]);

export const ErrorResponseSchema = z.object({
  issues: z.array(ErrorSchema),
  layer: LayerSchema
});

export const ProfileNestedPayloadSchema = z.discriminatedUnion('_type', [
  ProfileNestedCreatePayloadSchema,
  ProfileNestedUpdatePayloadSchema
]);

export const UserFilterSchema: z.ZodType<UserFilter> = z.lazy(() => z.object({
  _and: z.array(UserFilterSchema).optional(),
  _not: UserFilterSchema.optional(),
  _or: z.array(UserFilterSchema).optional(),
  email: z.union([z.string(), StringFilterSchema]).optional(),
  username: z.union([z.string(), StringFilterSchema]).optional()
}));

export const UserSchema = z.object({
  createdAt: z.iso.datetime(),
  email: z.string(),
  id: z.string(),
  posts: z.array(PostSchema),
  profile: ProfileSchema,
  updatedAt: z.iso.datetime(),
  username: z.string()
});

export const PostCreatePayloadSchema = z.object({
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string()
});

export const PostNestedCreatePayloadSchema = z.object({
  _type: z.literal('create'),
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string()
});

export const PostNestedUpdatePayloadSchema = z.object({
  _type: z.literal('update'),
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string().optional()
});

export const PostUpdatePayloadSchema = z.object({
  comments: z.array(CommentNestedPayloadSchema).optional(),
  title: z.string().optional()
});

export const PostNestedPayloadSchema = z.discriminatedUnion('_type', [
  PostNestedCreatePayloadSchema,
  PostNestedUpdatePayloadSchema
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

export const UsersIndexRequestQuerySchema = z.object({
  filter: z.union([UserFilterSchema, z.array(UserFilterSchema)]).optional(),
  page: UserPageSchema.optional(),
  sort: z.union([UserSortSchema, z.array(UserSortSchema)]).optional()
});

export const UsersIndexRequestSchema = z.object({
  query: UsersIndexRequestQuerySchema
});

export const UsersIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional(), users: z.array(UserSchema).optional() }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const UsersIndexResponseSchema = z.object({
  body: UsersIndexResponseBodySchema
});

export const UsersShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), user: UserSchema }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const UsersShowResponseSchema = z.object({
  body: UsersShowResponseBodySchema
});

export const UsersCreateRequestBodySchema = z.object({
  user: UserCreatePayloadSchema
});

export const UsersCreateRequestSchema = z.object({
  body: UsersCreateRequestBodySchema
});

export const UsersCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), user: UserSchema }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const UsersCreateResponseSchema = z.object({
  body: UsersCreateResponseBodySchema
});

export const UsersUpdateRequestBodySchema = z.object({
  user: UserUpdatePayloadSchema
});

export const UsersUpdateRequestSchema = z.object({
  body: UsersUpdateRequestBodySchema
});

export const UsersUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), user: UserSchema }), z.object({ issues: z.array(ErrorSchema).optional() })]);

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

export const PostsIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional(), posts: z.array(PostSchema).optional() }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const PostsIndexResponseSchema = z.object({
  body: PostsIndexResponseBodySchema
});

export const PostsShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const PostsShowResponseSchema = z.object({
  body: PostsShowResponseBodySchema
});

export const PostsCreateRequestBodySchema = z.object({
  post: PostCreatePayloadSchema
});

export const PostsCreateRequestSchema = z.object({
  body: PostsCreateRequestBodySchema
});

export const PostsCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const PostsCreateResponseSchema = z.object({
  body: PostsCreateResponseBodySchema
});

export const PostsUpdateRequestBodySchema = z.object({
  post: PostUpdatePayloadSchema
});

export const PostsUpdateRequestSchema = z.object({
  body: PostsUpdateRequestBodySchema
});

export const PostsUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(ErrorSchema).optional() })]);

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

export const CommentsIndexResponseBodySchema = z.union([z.object({ comments: z.array(CommentSchema).optional(), meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional() }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const CommentsIndexResponseSchema = z.object({
  body: CommentsIndexResponseBodySchema
});

export const CommentsShowResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const CommentsShowResponseSchema = z.object({
  body: CommentsShowResponseBodySchema
});

export const CommentsCreateRequestBodySchema = z.object({
  comment: CommentCreatePayloadSchema
});

export const CommentsCreateRequestSchema = z.object({
  body: CommentsCreateRequestBodySchema
});

export const CommentsCreateResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(ErrorSchema).optional() })]);

export const CommentsCreateResponseSchema = z.object({
  body: CommentsCreateResponseBodySchema
});

export const CommentsUpdateRequestBodySchema = z.object({
  comment: CommentUpdatePayloadSchema
});

export const CommentsUpdateRequestSchema = z.object({
  body: CommentsUpdateRequestBodySchema
});

export const CommentsUpdateResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(ErrorSchema).optional() })]);

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

export type CommentsCreateResponseBody = { comment: Comment; meta?: object } | { issues?: Error[] };

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

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: OffsetPagination } | { issues?: Error[] };

export interface CommentsShowResponse {
  body: CommentsShowResponseBody;
}

export type CommentsShowResponseBody = { comment: Comment; meta?: object } | { issues?: Error[] };

export interface CommentsUpdateRequest {
  body: CommentsUpdateRequestBody;
}

export interface CommentsUpdateRequestBody {
  comment: CommentUpdatePayload;
}

export interface CommentsUpdateResponse {
  body: CommentsUpdateResponseBody;
}

export type CommentsUpdateResponseBody = { comment: Comment; meta?: object } | { issues?: Error[] };

export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  issues: Error[];
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

export type PostsCreateResponseBody = { issues?: Error[] } | { meta?: object; post: Post };

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

export type PostsIndexResponseBody = { issues?: Error[] } | { meta?: object; pagination?: OffsetPagination; posts?: Post[] };

export interface PostsShowResponse {
  body: PostsShowResponseBody;
}

export type PostsShowResponseBody = { issues?: Error[] } | { meta?: object; post: Post };

export interface PostsUpdateRequest {
  body: PostsUpdateRequestBody;
}

export interface PostsUpdateRequestBody {
  post: PostUpdatePayload;
}

export interface PostsUpdateResponse {
  body: PostsUpdateResponseBody;
}

export type PostsUpdateResponseBody = { issues?: Error[] } | { meta?: object; post: Post };

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

export type UsersCreateResponseBody = { issues?: Error[] } | { meta?: object; user: User };

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

export type UsersIndexResponseBody = { issues?: Error[] } | { meta?: object; pagination?: OffsetPagination; users?: User[] };

export interface UsersShowResponse {
  body: UsersShowResponseBody;
}

export type UsersShowResponseBody = { issues?: Error[] } | { meta?: object; user: User };

export interface UsersUpdateRequest {
  body: UsersUpdateRequestBody;
}

export interface UsersUpdateRequestBody {
  user: UserUpdatePayload;
}

export interface UsersUpdateResponse {
  body: UsersUpdateResponseBody;
}

export type UsersUpdateResponseBody = { issues?: Error[] } | { meta?: object; user: User };
