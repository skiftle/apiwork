import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  starts_with: z.string().optional()
});

export const PagePaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  ends_with: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  starts_with: z.string().optional()
});

export const TaskSchema = z.object({
  archived: z.boolean().optional(),
  created_at: z.iso.datetime().optional(),
  description: z.string().optional(),
  due_date: z.iso.datetime().optional(),
  id: z.string().optional(),
  priority: z.string().optional(),
  status: z.string().optional(),
  title: z.string().optional(),
  updated_at: z.iso.datetime().optional()
});

export const TaskCreatePayloadSchema = z.object({
  description: z.string().nullable().optional(),
  due_date: z.iso.datetime().nullable().optional(),
  priority: z.string().nullable().optional(),
  status: z.string().nullable().optional(),
  title: z.string()
});

export const TaskIncludeSchema = z.object({

});

export const TaskPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const TaskSortSchema = z.object({
  created_at: z.unknown().optional(),
  due_date: z.unknown().optional()
});

export const TaskUpdatePayloadSchema = z.object({
  description: z.string().nullable().optional(),
  due_date: z.iso.datetime().nullable().optional(),
  priority: z.string().nullable().optional(),
  status: z.string().nullable().optional(),
  title: z.string().optional()
});

export const TaskFilterSchema: z.ZodType<TaskFilter> = z.lazy(() => z.object({
  _and: z.array(TaskFilterSchema).optional(),
  _not: TaskFilterSchema.optional(),
  _or: z.array(TaskFilterSchema).optional(),
  priority: z.union([z.string(), NullableStringFilterSchema]).optional(),
  status: z.union([z.string(), NullableStringFilterSchema]).optional()
}));

export const TaskSchema = z.object({
  archived: z.boolean().nullable().optional(),
  created_at: z.iso.datetime(),
  description: z.string().nullable().optional(),
  due_date: z.iso.datetime().nullable().optional(),
  id: z.string(),
  priority: z.string().nullable().optional(),
  status: z.string().nullable().optional(),
  title: z.string(),
  updated_at: z.iso.datetime()
});

export const TasksIndexRequestQuerySchema = z.object({
  filter: z.union([TaskFilterSchema, z.array(TaskFilterSchema)]).optional(),
  include: TaskIncludeSchema.optional(),
  page: TaskPageSchema.optional(),
  sort: z.union([TaskSortSchema, z.array(TaskSortSchema)]).optional()
});

export const TasksIndexRequestSchema = z.object({
  query: TasksIndexRequestQuerySchema
});

export const TasksIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: PagePaginationSchema.optional(), tasks: z.array(TaskSchema).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksIndexResponseSchema = z.object({
  body: TasksIndexResponseBodySchema
});

export const TasksShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksShowResponseSchema = z.object({
  body: TasksShowResponseBodySchema
});

export const TasksCreateRequestBodySchema = z.object({
  task: TaskCreatePayloadSchema
});

export const TasksCreateRequestSchema = z.object({
  body: TasksCreateRequestBodySchema
});

export const TasksCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksCreateResponseSchema = z.object({
  body: TasksCreateResponseBodySchema
});

export const TasksUpdateRequestBodySchema = z.object({
  task: TaskUpdatePayloadSchema
});

export const TasksUpdateRequestSchema = z.object({
  body: TasksUpdateRequestBodySchema
});

export const TasksUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksUpdateResponseSchema = z.object({
  body: TasksUpdateResponseBodySchema
});

export const TasksArchiveResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksArchiveResponseSchema = z.object({
  body: TasksArchiveResponseBodySchema
});

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface NullableStringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  starts_with?: string;
}

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  ends_with?: string;
  eq?: string;
  in?: string[];
  starts_with?: string;
}

export interface Task {
  archived?: boolean | null;
  created_at: string;
  description?: null | string;
  due_date?: null | string;
  id: string;
  priority?: null | string;
  status?: null | string;
  title: string;
  updated_at: string;
}

export interface Task {
  archived?: boolean;
  created_at?: string;
  description?: string;
  due_date?: string;
  id?: string;
  priority?: string;
  status?: string;
  title?: string;
  updated_at?: string;
}

export interface TaskCreatePayload {
  description?: null | string;
  due_date?: null | string;
  priority?: null | string;
  status?: null | string;
  title: string;
}

export interface TaskFilter {
  _and?: TaskFilter[];
  _not?: TaskFilter;
  _or?: TaskFilter[];
  priority?: NullableStringFilter | string;
  status?: NullableStringFilter | string;
}

export type TaskInclude = object;

export interface TaskPage {
  number?: number;
  size?: number;
}

export interface TaskSort {
  created_at?: unknown;
  due_date?: unknown;
}

export interface TaskUpdatePayload {
  description?: null | string;
  due_date?: null | string;
  priority?: null | string;
  status?: null | string;
  title?: string;
}

export interface TasksArchiveResponse {
  body: TasksArchiveResponseBody;
}

export type TasksArchiveResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };

export interface TasksCreateRequest {
  body: TasksCreateRequestBody;
}

export interface TasksCreateRequestBody {
  task: TaskCreatePayload;
}

export interface TasksCreateResponse {
  body: TasksCreateResponseBody;
}

export type TasksCreateResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };

export interface TasksIndexRequest {
  query: TasksIndexRequestQuery;
}

export interface TasksIndexRequestQuery {
  filter?: TaskFilter | TaskFilter[];
  include?: TaskInclude;
  page?: TaskPage;
  sort?: TaskSort | TaskSort[];
}

export interface TasksIndexResponse {
  body: TasksIndexResponseBody;
}

export type TasksIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: PagePagination; tasks?: Task[] };

export interface TasksShowResponse {
  body: TasksShowResponseBody;
}

export type TasksShowResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };

export interface TasksUpdateRequest {
  body: TasksUpdateRequestBody;
}

export interface TasksUpdateRequestBody {
  task: TaskUpdatePayload;
}

export interface TasksUpdateResponse {
  body: TasksUpdateResponseBody;
}

export type TasksUpdateResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };
