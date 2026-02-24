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