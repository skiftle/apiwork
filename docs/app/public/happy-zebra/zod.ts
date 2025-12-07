import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const CommentSchema = z.object({
  author: z.string().optional(),
  body: z.string().optional(),
  id: z.string().optional()
});

export const CommentCreatePayloadSchema = z.object({
  author: z.string(),
  body: z.string()
});

export const CommentIncludeSchema = z.object({

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

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const PagePaginationSchema = z.object({
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

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  starts_with: z.string().optional()
});

export const UserPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const UserProfileIncludeSchema = z.object({

});

export const UserSortSchema = z.object({
  created_at: z.unknown().optional(),
  updated_at: z.unknown().optional()
});

export const PostSchema = z.object({
  comments: z.array(CommentSchema),
  id: z.string().optional(),
  title: z.string().optional()
});

export const PostIncludeSchema = z.object({
  comments: CommentIncludeSchema.optional()
});

export const CommentNestedPayloadSchema = z.discriminatedUnion('_type', [
  CommentNestedCreatePayloadSchema,
  CommentNestedUpdatePayloadSchema
]);

export const UserFilterSchema: z.ZodType<UserFilter> = z.lazy(() => z.object({
  _and: z.array(UserFilterSchema).optional(),
  _not: UserFilterSchema.optional(),
  _or: z.array(UserFilterSchema).optional(),
  email: z.union([z.string(), StringFilterSchema]).optional(),
  username: z.union([z.string(), StringFilterSchema]).optional()
}));

export const UserSchema = z.object({
  created_at: z.iso.datetime().optional(),
  email: z.string().optional(),
  id: z.string().optional(),
  posts: z.array(PostSchema),
  profile: z.object({}),
  updated_at: z.iso.datetime().optional(),
  username: z.string().optional()
});

export const UserIncludeSchema = z.object({
  posts: PostIncludeSchema.optional(),
  profile: UserProfileIncludeSchema.optional()
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
  profile: z.object({}).optional(),
  username: z.string()
});

export const UserUpdatePayloadSchema = z.object({
  email: z.string().optional(),
  posts: z.array(PostNestedPayloadSchema).optional(),
  profile: z.object({}).optional(),
  username: z.string().optional()
});

export const UserSchema = z.object({
  created_at: z.iso.datetime(),
  email: z.string(),
  id: z.string(),
  updated_at: z.iso.datetime(),
  username: z.string()
});

export const PostSchema = z.object({
  id: z.string(),
  title: z.string()
});

export const CommentSchema = z.object({
  author: z.string(),
  body: z.string(),
  id: z.string()
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

export const UsersIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: PagePaginationSchema.optional(), users: z.array(UserSchema).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const UsersIndexResponseSchema = z.object({
  body: UsersIndexResponseBodySchema
});

export const UsersShowRequestQuerySchema = z.object({
  include: UserIncludeSchema.optional()
});

export const UsersShowRequestSchema = z.object({
  query: UsersShowRequestQuerySchema
});

export const UsersShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), user: UserSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

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

export const UsersCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), user: UserSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

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

export const UsersUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), user: UserSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const UsersUpdateResponseSchema = z.object({
  body: UsersUpdateResponseBodySchema
});

export const PostsIndexRequestQuerySchema = z.object({
  include: PostIncludeSchema.optional(),
  page: PostPageSchema.optional()
});

export const PostsIndexRequestSchema = z.object({
  query: PostsIndexRequestQuerySchema
});

export const PostsIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: PagePaginationSchema.optional(), posts: z.array(PostSchema).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const PostsIndexResponseSchema = z.object({
  body: PostsIndexResponseBodySchema
});

export const PostsShowRequestQuerySchema = z.object({
  include: PostIncludeSchema.optional()
});

export const PostsShowRequestSchema = z.object({
  query: PostsShowRequestQuerySchema
});

export const PostsShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const PostsShowResponseSchema = z.object({
  body: PostsShowResponseBodySchema
});

export const PostsCreateRequestQuerySchema = z.object({
  include: PostIncludeSchema.optional()
});

export const PostsCreateRequestBodySchema = z.object({
  post: PostCreatePayloadSchema
});

export const PostsCreateRequestSchema = z.object({
  query: PostsCreateRequestQuerySchema,
  body: PostsCreateRequestBodySchema
});

export const PostsCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const PostsCreateResponseSchema = z.object({
  body: PostsCreateResponseBodySchema
});

export const PostsUpdateRequestQuerySchema = z.object({
  include: PostIncludeSchema.optional()
});

export const PostsUpdateRequestBodySchema = z.object({
  post: PostUpdatePayloadSchema
});

export const PostsUpdateRequestSchema = z.object({
  query: PostsUpdateRequestQuerySchema,
  body: PostsUpdateRequestBodySchema
});

export const PostsUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), post: PostSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const PostsUpdateResponseSchema = z.object({
  body: PostsUpdateResponseBodySchema
});

export const CommentsIndexRequestQuerySchema = z.object({
  include: CommentIncludeSchema.optional(),
  page: CommentPageSchema.optional()
});

export const CommentsIndexRequestSchema = z.object({
  query: CommentsIndexRequestQuerySchema
});

export const CommentsIndexResponseBodySchema = z.union([z.object({ comments: z.array(CommentSchema).optional(), meta: z.object({}).optional(), pagination: PagePaginationSchema.optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsIndexResponseSchema = z.object({
  body: CommentsIndexResponseBodySchema
});

export const CommentsShowResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsShowResponseSchema = z.object({
  body: CommentsShowResponseBodySchema
});

export const CommentsCreateRequestBodySchema = z.object({
  comment: CommentCreatePayloadSchema
});

export const CommentsCreateRequestSchema = z.object({
  body: CommentsCreateRequestBodySchema
});

export const CommentsCreateResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsCreateResponseSchema = z.object({
  body: CommentsCreateResponseBodySchema
});

export const CommentsUpdateRequestBodySchema = z.object({
  comment: CommentUpdatePayloadSchema
});

export const CommentsUpdateRequestSchema = z.object({
  body: CommentsUpdateRequestBodySchema
});

export const CommentsUpdateResponseBodySchema = z.union([z.object({ comment: CommentSchema, meta: z.object({}).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const CommentsUpdateResponseSchema = z.object({
  body: CommentsUpdateResponseBodySchema
});

export interface Comment {
  author: string;
  body: string;
  id: string;
}

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

export type CommentNestedPayload = CommentNestedCreatePayload | CommentNestedUpdatePayload;

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

export type CommentsIndexResponseBody = { comments?: Comment[]; meta?: object; pagination?: PagePagination } | { issues?: Issue[] };

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

export interface PagePagination {
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

export interface Post {
  id: string;
  title: string;
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

export type PostNestedPayload = PostNestedCreatePayload | PostNestedUpdatePayload;

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

export type PostsIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: PagePagination; posts?: Post[] };

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
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}

export interface User {
  created_at: string;
  email: string;
  id: string;
  updated_at: string;
  username: string;
}

export interface User {
  created_at?: string;
  email?: string;
  id?: string;
  posts: Post[];
  profile: object;
  updated_at?: string;
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
  created_at?: unknown;
  updated_at?: unknown;
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

export type UsersIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: PagePagination; users?: User[] };

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
