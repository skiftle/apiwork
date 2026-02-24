import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const AccountSchema = z.object({
  createdAt: z.iso.datetime(),
  email: z.string(),
  id: z.string(),
  name: z.string(),
  role: z.string(),
  updatedAt: z.iso.datetime(),
  verified: z.boolean()
});

export const AccountCreatePayloadSchema = z.object({
  email: z.string(),
  name: z.string()
});

export const AccountPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const AccountUpdatePayloadSchema = z.object({
  name: z.string().optional(),
  role: z.string().optional(),
  verified: z.boolean().optional()
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

export const AccountCreateSuccessResponseBodySchema = z.object({
  account: AccountSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const AccountIndexSuccessResponseBodySchema = z.object({
  accounts: z.array(AccountSchema),
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema
});

export const AccountShowSuccessResponseBodySchema = z.object({
  account: AccountSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const AccountUpdateSuccessResponseBodySchema = z.object({
  account: AccountSchema,
  meta: z.record(z.string(), z.unknown()).optional()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ErrorResponseBodySchema = ErrorSchema;

export const AccountsIndexRequestQuerySchema = z.object({
  page: AccountPageSchema.optional()
});

export const AccountsIndexRequestSchema = z.object({
  query: AccountsIndexRequestQuerySchema
});

export const AccountsIndexResponseBodySchema = z.union([AccountIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const AccountsIndexResponseSchema = z.object({
  body: AccountsIndexResponseBodySchema
});

export const AccountsShowResponseBodySchema = z.union([AccountShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const AccountsShowResponseSchema = z.object({
  body: AccountsShowResponseBodySchema
});

export const AccountsCreateRequestBodySchema = z.object({
  account: AccountCreatePayloadSchema
});

export const AccountsCreateRequestSchema = z.object({
  body: AccountsCreateRequestBodySchema
});

export const AccountsCreateResponseBodySchema = z.union([AccountCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const AccountsCreateResponseSchema = z.object({
  body: AccountsCreateResponseBodySchema
});

export const AccountsUpdateRequestBodySchema = z.object({
  account: AccountUpdatePayloadSchema
});

export const AccountsUpdateRequestSchema = z.object({
  body: AccountsUpdateRequestBodySchema
});

export const AccountsUpdateResponseBodySchema = z.union([AccountUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const AccountsUpdateResponseSchema = z.object({
  body: AccountsUpdateResponseBodySchema
});

export const AccountsDestroyResponseSchema = z.never();

export interface Account {
  createdAt: string;
  email: string;
  id: string;
  name: string;
  role: string;
  updatedAt: string;
  verified: boolean;
}

export interface AccountCreatePayload {
  email: string;
  name: string;
}

export interface AccountCreateSuccessResponseBody {
  account: Account;
  meta?: Record<string, unknown>;
}

export interface AccountIndexSuccessResponseBody {
  accounts: Account[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface AccountPage {
  number?: number;
  size?: number;
}

export interface AccountShowSuccessResponseBody {
  account: Account;
  meta?: Record<string, unknown>;
}

export interface AccountUpdatePayload {
  name?: string;
  role?: string;
  verified?: boolean;
}

export interface AccountUpdateSuccessResponseBody {
  account: Account;
  meta?: Record<string, unknown>;
}

export interface AccountsCreateRequest {
  body: AccountsCreateRequestBody;
}

export interface AccountsCreateRequestBody {
  account: AccountCreatePayload;
}

export interface AccountsCreateResponse {
  body: AccountsCreateResponseBody;
}

export type AccountsCreateResponseBody = AccountCreateSuccessResponseBody | ErrorResponseBody;

export type AccountsDestroyResponse = never;

export interface AccountsIndexRequest {
  query: AccountsIndexRequestQuery;
}

export interface AccountsIndexRequestQuery {
  page?: AccountPage;
}

export interface AccountsIndexResponse {
  body: AccountsIndexResponseBody;
}

export type AccountsIndexResponseBody = AccountIndexSuccessResponseBody | ErrorResponseBody;

export interface AccountsShowResponse {
  body: AccountsShowResponseBody;
}

export type AccountsShowResponseBody = AccountShowSuccessResponseBody | ErrorResponseBody;

export interface AccountsUpdateRequest {
  body: AccountsUpdateRequestBody;
}

export interface AccountsUpdateRequestBody {
  account: AccountUpdatePayload;
}

export interface AccountsUpdateResponse {
  body: AccountsUpdateResponseBody;
}

export type AccountsUpdateResponseBody = AccountUpdateSuccessResponseBody | ErrorResponseBody;

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
