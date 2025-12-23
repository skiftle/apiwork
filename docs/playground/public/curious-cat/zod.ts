import { z } from 'zod';

export const ErrorSchema = z.object({
  code: z.string(),
  detail: z.string(),
  layer: z.enum(['http', 'contract', 'domain']),
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

export const ProfilesIndexRequestQuerySchema = z.object({
  page: ProfilePageSchema.optional()
});

export const ProfilesIndexRequestSchema = z.object({
  query: ProfilesIndexRequestQuerySchema
});

export const ProfilesIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional(), profiles: z.array(ProfileSchema).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ProfilesIndexResponseSchema = z.object({
  body: ProfilesIndexResponseBodySchema
});

export const ProfilesShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), profile: ProfileSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ProfilesShowResponseSchema = z.object({
  body: ProfilesShowResponseBodySchema
});

export const ProfilesCreateRequestBodySchema = z.object({
  profile: ProfileCreatePayloadSchema
});

export const ProfilesCreateRequestSchema = z.object({
  body: ProfilesCreateRequestBodySchema
});

export const ProfilesCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), profile: ProfileSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ProfilesCreateResponseSchema = z.object({
  body: ProfilesCreateResponseBodySchema
});

export const ProfilesUpdateRequestBodySchema = z.object({
  profile: ProfileUpdatePayloadSchema
});

export const ProfilesUpdateRequestSchema = z.object({
  body: ProfilesUpdateRequestBodySchema
});

export const ProfilesUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), profile: ProfileSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const ProfilesUpdateResponseSchema = z.object({
  body: ProfilesUpdateResponseBodySchema
});

export const ProfilesDestroyResponse = z.never();

export interface Error {
  code: string;
  detail: string;
  layer: 'contract' | 'domain' | 'http';
  meta: object;
  path: string[];
  pointer: string;
}

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

export type ProfilesCreateResponseBody = { errors?: Error[] } | { meta?: object; profile: Profile };

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

export type ProfilesIndexResponseBody = { errors?: Error[] } | { meta?: object; pagination?: OffsetPagination; profiles?: Profile[] };

export interface ProfilesShowResponse {
  body: ProfilesShowResponseBody;
}

export type ProfilesShowResponseBody = { errors?: Error[] } | { meta?: object; profile: Profile };

export interface ProfilesUpdateRequest {
  body: ProfilesUpdateRequestBody;
}

export interface ProfilesUpdateRequestBody {
  profile: ProfileUpdatePayload;
}

export interface ProfilesUpdateResponse {
  body: ProfilesUpdateResponseBody;
}

export type ProfilesUpdateResponseBody = { errors?: Error[] } | { meta?: object; profile: Profile };
