import { z } from 'zod';

export const StatusSchema = z.enum(['archived', 'draft', 'published']);

export type Status = 'archived' | 'draft' | 'published';
