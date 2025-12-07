import { z } from 'zod';

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const StatusHealthResponseBodySchema = z.object({ status: z.string(), timestamp: z.iso.datetime(), version: z.string() });

export const StatusHealthResponseSchema = z.object({
  body: StatusHealthResponseBodySchema
});

export const StatusStatsResponseBodySchema = z.object({ postsCount: z.number().int(), uptimeSeconds: z.number().int(), usersCount: z.number().int() });

export const StatusStatsResponseSchema = z.object({
  body: StatusStatsResponseBodySchema
});

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}
