import { z } from 'zod';

export const PostPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const CursorPaginationSchema = z.object({
  next_cursor: z.string().nullable().optional(),
  prev_cursor: z.string().nullable().optional()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const PagePaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export interface CursorPagination {
  next_cursor?: null | string;
  prev_cursor?: null | string;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type PostPriority = 'critical' | 'high' | 'low' | 'medium';
