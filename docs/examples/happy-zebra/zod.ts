import { z } from 'zod';

export const StatusSchema = z.enum(['archived', 'draft', 'published']);

export const StatusFilterSchema = z.union([
  StatusSchema,
  z.object({ eq: StatusSchema, in: z.array(StatusSchema) }).partial()
]);

export type Status = 'archived' | 'draft' | 'published';

export type StatusFilter = Status | { eq?: Status; in?: Status[] };
