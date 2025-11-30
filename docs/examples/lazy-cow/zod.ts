import { z } from 'zod';

export const PostPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export type PostPriority = 'critical' | 'high' | 'low' | 'medium';
