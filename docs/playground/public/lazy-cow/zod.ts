import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const ErrorSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
});

export const ErrorResponseSchema = z.object({
  errors: z.array(ErrorSchema),
  layer: LayerSchema
});

export const StatusHealthResponseBodySchema = z.object({ status: z.string(), timestamp: z.iso.datetime(), version: z.string() });

export const StatusHealthResponseSchema = z.object({
  body: StatusHealthResponseBodySchema
});

export const StatusStatsResponseBodySchema = z.object({ postsCount: z.number().int(), uptimeSeconds: z.number().int(), usersCount: z.number().int() });

export const StatusStatsResponseSchema = z.object({
  body: StatusStatsResponseBodySchema
});

export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  errors: Error[];
  layer: Layer;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface StatusHealthResponse {
  body: StatusHealthResponseBody;
}

export type StatusHealthResponseBody = { status: string; timestamp: string; version: string };

export interface StatusStatsResponse {
  body: StatusStatsResponseBody;
}

export type StatusStatsResponseBody = { postsCount: number; uptimeSeconds: number; usersCount: number };
