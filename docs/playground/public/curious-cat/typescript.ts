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

export interface Profile {
  addresses: { city: string; primary: boolean; street: string; zip: string }[];
  createdAt: string;
  email: string;
  id: string;
  metadata: object;
  name: string;
  preferences: { notifications: { email: boolean; push: boolean }; ui: { sidebarCollapsed: boolean; theme: string } };
  settings: { language: string; notifications: boolean; theme: string };
  tags: string[];
  updatedAt: string;
}

export interface ProfileCreatePayload {
  addresses: { city: string; primary: boolean; street: string; zip: string }[];
  email: string;
  metadata: object;
  name: string;
  preferences: { notifications: { email: boolean; push: boolean }; ui: { sidebarCollapsed: boolean; theme: string } };
  settings: { language: string; notifications: boolean; theme: string };
  tags: string[];
}

export interface ProfilePage {
  number?: number;
  size?: number;
}

export interface ProfileUpdatePayload {
  addresses?: { city: string; primary: boolean; street: string; zip: string }[];
  email?: string;
  metadata?: object;
  name?: string;
  preferences?: { notifications: { email: boolean; push: boolean }; ui: { sidebarCollapsed: boolean; theme: string } };
  settings?: { language: string; notifications: boolean; theme: string };
  tags?: string[];
}

export interface ProfilesCreateRequest {
  body: ProfilesCreateRequestBody;
}

export interface ProfilesCreateRequestBody {
  profile: ProfileCreatePayload;
}

export interface ProfilesCreateResponse {
  body: ProfilesCreateResponseBody;
}

export type ProfilesCreateResponseBody = ErrorResponseBody | { meta?: object; profile: Profile };

export type ProfilesDestroyResponse = never;

export interface ProfilesIndexRequest {
  query: ProfilesIndexRequestQuery;
}

export interface ProfilesIndexRequestQuery {
  page?: ProfilePage;
}

export interface ProfilesIndexResponse {
  body: ProfilesIndexResponseBody;
}

export type ProfilesIndexResponseBody = ErrorResponseBody | { meta?: object; pagination?: OffsetPagination; profiles?: Profile[] };

export interface ProfilesShowResponse {
  body: ProfilesShowResponseBody;
}

export type ProfilesShowResponseBody = ErrorResponseBody | { meta?: object; profile: Profile };

export interface ProfilesUpdateRequest {
  body: ProfilesUpdateRequestBody;
}

export interface ProfilesUpdateRequestBody {
  profile: ProfileUpdatePayload;
}

export interface ProfilesUpdateResponse {
  body: ProfilesUpdateResponseBody;
}

export type ProfilesUpdateResponseBody = ErrorResponseBody | { meta?: object; profile: Profile };