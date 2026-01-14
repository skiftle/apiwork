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

export interface Profile {
  addresses: { city: string; primary: boolean; street: string; zip: string }[];
  created_at: string;
  email: string;
  id: string;
  metadata: string;
  name: string;
  preferences: { notifications: { email: boolean; push: boolean }; ui: { sidebar_collapsed: boolean; theme: string } };
  settings: { language: string; notifications: boolean; theme: string };
  tags: string[];
  updated_at: string;
}

export interface ProfileCreatePayload {
  addresses: { city: string; primary: boolean; street: string; zip: string }[];
  email: string;
  metadata: string;
  name: string;
  preferences: { notifications: { email: boolean; push: boolean }; ui: { sidebar_collapsed: boolean; theme: string } };
  settings: { language: string; notifications: boolean; theme: string };
  tags: string[];
}

export interface ProfileCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  profile: Profile;
}

export interface ProfileIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  profiles: Profile[];
}

export interface ProfilePage {
  number?: number;
  size?: number;
}

export interface ProfileShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  profile: Profile;
}

export interface ProfileUpdatePayload {
  addresses?: { city: string; primary: boolean; street: string; zip: string }[];
  email?: string;
  metadata?: string;
  name?: string;
  preferences?: { notifications: { email: boolean; push: boolean }; ui: { sidebar_collapsed: boolean; theme: string } };
  settings?: { language: string; notifications: boolean; theme: string };
  tags?: string[];
}

export interface ProfileUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  profile: Profile;
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

export type ProfilesCreateResponseBody = ErrorResponseBody | ProfileCreateSuccessResponseBody;

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

export type ProfilesIndexResponseBody = ErrorResponseBody | ProfileIndexSuccessResponseBody;

export interface ProfilesShowResponse {
  body: ProfilesShowResponseBody;
}

export type ProfilesShowResponseBody = ErrorResponseBody | ProfileShowSuccessResponseBody;

export interface ProfilesUpdateRequest {
  body: ProfilesUpdateRequestBody;
}

export interface ProfilesUpdateRequestBody {
  profile: ProfileUpdatePayload;
}

export interface ProfilesUpdateResponse {
  body: ProfilesUpdateResponseBody;
}

export type ProfilesUpdateResponseBody = ErrorResponseBody | ProfileUpdateSuccessResponseBody;