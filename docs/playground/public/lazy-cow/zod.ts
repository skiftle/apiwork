import { z } from 'zod';

export const StatusHealthResponseBodySchema = z.object({ status: z.string(), timestamp: z.iso.datetime(), version: z.string() });

export const StatusHealthResponseSchema = z.object({
  body: StatusHealthResponseBodySchema
});

export const StatusStatsResponseBodySchema = z.object({ posts_count: z.number().int(), uptime_seconds: z.number().int(), users_count: z.number().int() });

export const StatusStatsResponseSchema = z.object({
  body: StatusStatsResponseBodySchema
});

export interface StatusHealthResponse {
  body: StatusHealthResponseBody;
}

export type StatusHealthResponseBody = { status: string; timestamp: string; version: string };

export interface StatusStatsResponse {
  body: StatusStatsResponseBody;
}

export type StatusStatsResponseBody = { posts_count: number; uptime_seconds: number; users_count: number };
