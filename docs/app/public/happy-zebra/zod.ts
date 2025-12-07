import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

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

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  starts_with: z.string().optional()
});

export const UserSchema = z.object({
  created_at: z.iso.datetime().optional(),
  email: z.string().optional(),
  id: z.string().optional(),
  profile: z.object({}),
  updated_at: z.iso.datetime().optional(),
  username: z.string().optional()
});

export const UserCreatePayloadSchema = z.object({
  email: z.string(),
  profile: z.object({}).optional(),
  username: z.string()
});

export const UserIncludeSchema = z.object({

});

export const UserPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const UserSortSchema = z.object({
  created_at: z.unknown().optional(),
  updated_at: z.unknown().optional()
});

export const UserUpdatePayloadSchema = z.object({
  email: z.string().optional(),
  profile: z.object({}).optional(),
  username: z.string().optional()
});

export const UserFilterSchema: z.ZodType<UserFilter> = z.lazy(() => z.object({
  _and: z.array(UserFilterSchema).optional(),
  _not: UserFilterSchema.optional(),
  _or: z.array(UserFilterSchema).optional(),
  email: z.union([z.string(), StringFilterSchema]).optional(),
  username: z.union([z.string(), StringFilterSchema]).optional()
}));

export const UserSchema = z.object({
  created_at: z.iso.datetime(),
  email: z.string(),
  id: z.string(),
  updated_at: z.iso.datetime(),
  username: z.string()
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
  profile: object;
  updated_at?: string;
  username?: string;
}

export interface UserCreatePayload {
  email: string;
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

export type UserInclude = object;

export interface UserPage {
  number?: number;
  size?: number;
}

export interface UserSort {
  created_at?: unknown;
  updated_at?: unknown;
}

export interface UserUpdatePayload {
  email?: string;
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
