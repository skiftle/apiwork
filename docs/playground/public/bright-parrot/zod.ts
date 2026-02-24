import { z } from 'zod';

export const NotificationsIndexResponseBodySchema = z.object({ preference: z.discriminatedUnion('channel', [z.object({ address: z.string(), digest: z.boolean() }), z.object({ phoneNumber: z.string() }), z.object({ deviceToken: z.string(), silent: z.boolean() })]) });

export const NotificationsIndexResponseSchema = z.object({
  body: NotificationsIndexResponseBodySchema
});

export const NotificationsCreateRequestBodySchema = z.object({
  preference: z.discriminatedUnion('channel', [z.object({ address: z.string(), digest: z.boolean() }), z.object({ phoneNumber: z.string() }), z.object({ deviceToken: z.string(), silent: z.boolean() })])
});

export const NotificationsCreateRequestSchema = z.object({
  body: NotificationsCreateRequestBodySchema
});

export const NotificationsCreateResponseBodySchema = z.object({ preference: z.discriminatedUnion('channel', [z.object({ address: z.string(), digest: z.boolean() }), z.object({ phoneNumber: z.string() }), z.object({ deviceToken: z.string(), silent: z.boolean() })]) });

export const NotificationsCreateResponseSchema = z.object({
  body: NotificationsCreateResponseBodySchema
});

export interface NotificationsCreateRequest {
  body: NotificationsCreateRequestBody;
}

export interface NotificationsCreateRequestBody {
  preference: { address: string; digest: boolean } | { deviceToken: string; silent: boolean } | { phoneNumber: string };
}

export interface NotificationsCreateResponse {
  body: NotificationsCreateResponseBody;
}

export type NotificationsCreateResponseBody = { preference: { address: string; digest: boolean } | { deviceToken: string; silent: boolean } | { phoneNumber: string } };

export interface NotificationsIndexResponse {
  body: NotificationsIndexResponseBody;
}

export type NotificationsIndexResponseBody = { preference: { address: string; digest: boolean } | { deviceToken: string; silent: boolean } | { phoneNumber: string } };
