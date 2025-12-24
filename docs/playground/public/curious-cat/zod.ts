import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

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

export const ProfileSchema = z.object({
  addresses: z.array(z.object({ city: z.string(), primary: z.boolean(), street: z.string(), zip: z.string() })),
  createdAt: z.iso.datetime(),
  email: z.email(),
  id: z.string(),
  metadata: z.object({}),
  name: z.string(),
  preferences: z.object({ notifications: z.object({ email: z.boolean(), push: z.boolean() }), ui: z.object({ sidebarCollapsed: z.boolean(), theme: z.string() }) }),
  settings: z.object({ language: z.string(), notifications: z.boolean(), theme: z.string() }),
  tags: z.array(z.string()),
  updatedAt: z.iso.datetime()
});

export const ProfileCreatePayloadSchema = z.object({
  addresses: z.array(z.object({ city: z.string(), primary: z.boolean(), street: z.string(), zip: z.string() })),
  email: z.email(),
  metadata: z.object({}),
  name: z.string(),
  preferences: z.object({ notifications: z.object({ email: z.boolean(), push: z.boolean() }), ui: z.object({ sidebarCollapsed: z.boolean(), theme: z.string() }) }),
  settings: z.object({ language: z.string(), notifications: z.boolean(), theme: z.string() }),
  tags: z.array(z.string())
});

export const ProfilePageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ProfileUpdatePayloadSchema = z.object({
  addresses: z.array(z.object({ city: z.string().optional(), primary: z.boolean().optional(), street: z.string().optional(), zip: z.string().optional() })),
  email: z.email().optional(),
  metadata: z.object({}).optional(),
  name: z.string().optional(),
  preferences: z.object({ notifications: z.object({ email: z.boolean().optional(), push: z.boolean().optional() }), ui: z.object({ sidebarCollapsed: z.boolean().optional(), theme: z.string().optional() }) }),
  settings: z.object({ language: z.string().optional(), notifications: z.boolean().optional(), theme: z.string().optional() }),
  tags: z.array(z.string()).optional()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ProfileCreateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  profile: ProfileSchema
});

export const ProfileIndexSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema,
  profiles: z.array(ProfileSchema)
});

export const ProfileShowSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  profile: ProfileSchema
});

export const ProfileUpdateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  profile: ProfileSchema
});

export const ProfilesIndexRequestQuerySchema = z.object({
  page: ProfilePageSchema.optional()
});

export const ProfilesIndexRequestSchema = z.object({
  query: ProfilesIndexRequestQuerySchema
});

export const ProfilesIndexResponseBodySchema = z.union([ProfileIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProfilesIndexResponseSchema = z.object({
  body: ProfilesIndexResponseBodySchema
});

export const ProfilesShowResponseBodySchema = z.union([ProfileShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProfilesShowResponseSchema = z.object({
  body: ProfilesShowResponseBodySchema
});

export const ProfilesCreateRequestBodySchema = z.object({
  profile: ProfileCreatePayloadSchema
});

export const ProfilesCreateRequestSchema = z.object({
  body: ProfilesCreateRequestBodySchema
});

export const ProfilesCreateResponseBodySchema = z.union([ProfileCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProfilesCreateResponseSchema = z.object({
  body: ProfilesCreateResponseBodySchema
});

export const ProfilesUpdateRequestBodySchema = z.object({
  profile: ProfileUpdatePayloadSchema
});

export const ProfilesUpdateRequestSchema = z.object({
  body: ProfilesUpdateRequestBodySchema
});

export const ProfilesUpdateResponseBodySchema = z.union([ProfileUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProfilesUpdateResponseSchema = z.object({
  body: ProfilesUpdateResponseBodySchema
});

export const ProfilesDestroyResponse = z.never();

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

export interface ProfileCreateSuccessResponseBody {
  meta?: object;
  profile: Profile;
}

export interface ProfileIndexSuccessResponseBody {
  meta?: object;
  pagination: OffsetPagination;
  profiles: Profile[];
}

export interface ProfilePage {
  number?: number;
  size?: number;
}

export interface ProfileShowSuccessResponseBody {
  meta?: object;
  profile: Profile;
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

export interface ProfileUpdateSuccessResponseBody {
  meta?: object;
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
