import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const TaskPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const TaskStatusSchema = z.enum(['archived', 'completed', 'in_progress', 'pending']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  field: z.string(),
  path: z.array(z.string())
});

export const NullableStringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  null: z.boolean().optional(),
  startsWith: z.string().optional()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const TaskSchema = z.object({
  archived: z.boolean().optional(),
  assignee: z.object({}).nullable().optional(),
  comments: z.array(z.string()).optional(),
  createdAt: z.iso.datetime().optional(),
  description: z.string().optional(),
  dueDate: z.iso.datetime().optional(),
  id: z.string().optional(),
  priority: TaskPrioritySchema.optional(),
  status: TaskStatusSchema.optional(),
  title: z.string().optional(),
  updatedAt: z.iso.datetime().optional()
});

export const TaskCreatePayloadSchema = z.object({
  description: z.string().nullable().optional(),
  dueDate: z.iso.datetime().nullable().optional(),
  priority: TaskPrioritySchema.nullable().optional(),
  status: TaskStatusSchema.nullable().optional(),
  title: z.string()
});

export const TaskIncludeSchema = z.object({

});

export const TaskPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const TaskPriorityFilterSchema = z.union([
  TaskPrioritySchema,
  z.object({ eq: TaskPrioritySchema, in: z.array(TaskPrioritySchema) }).partial()
]);

export const TaskSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  dueDate: SortDirectionSchema.optional()
});

export const TaskStatusFilterSchema = z.union([
  TaskStatusSchema,
  z.object({ eq: TaskStatusSchema, in: z.array(TaskStatusSchema) }).partial()
]);

export const TaskUpdatePayloadSchema = z.object({
  description: z.string().nullable().optional(),
  dueDate: z.iso.datetime().nullable().optional(),
  priority: TaskPrioritySchema.nullable().optional(),
  status: TaskStatusSchema.nullable().optional(),
  title: z.string().optional()
});

export const TaskFilterSchema: z.ZodType<TaskFilter> = z.lazy(() => z.object({
  _and: z.array(TaskFilterSchema).optional(),
  _not: TaskFilterSchema.optional(),
  _or: z.array(TaskFilterSchema).optional(),
  priority: TaskPriorityFilterSchema.optional(),
  status: TaskStatusFilterSchema.optional()
}));

export const TasksIndexRequestQuerySchema = z.object({
  filter: z.union([TaskFilterSchema, z.array(TaskFilterSchema)]).optional(),
  include: TaskIncludeSchema.optional(),
  page: TaskPageSchema.optional(),
  sort: z.union([TaskSortSchema, z.array(TaskSortSchema)]).optional()
});

export const TasksIndexRequestSchema = z.object({
  query: TasksIndexRequestQuerySchema
});

export const TasksIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional(), tasks: z.array(TaskSchema).optional() }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksIndexResponseSchema = z.object({
  body: TasksIndexResponseBodySchema
});

export const TasksShowRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksShowRequestSchema = z.object({
  query: TasksShowRequestQuerySchema
});

export const TasksShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksShowResponseSchema = z.object({
  body: TasksShowResponseBodySchema
});

export const TasksCreateRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksCreateRequestBodySchema = z.object({
  task: TaskCreatePayloadSchema
});

export const TasksCreateRequestSchema = z.object({
  query: TasksCreateRequestQuerySchema,
  body: TasksCreateRequestBodySchema
});

export const TasksCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksCreateResponseSchema = z.object({
  body: TasksCreateResponseBodySchema
});

export const TasksUpdateRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksUpdateRequestBodySchema = z.object({
  task: TaskUpdatePayloadSchema
});

export const TasksUpdateRequestSchema = z.object({
  query: TasksUpdateRequestQuerySchema,
  body: TasksUpdateRequestBodySchema
});

export const TasksUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ issues: z.array(IssueSchema).optional() })]);

export const TasksUpdateResponseSchema = z.object({
  body: TasksUpdateResponseBodySchema
});

export const TasksDestroyResponse = z.never();

export const TasksArchiveRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksArchiveRequestSchema = z.object({
  query: TasksArchiveRequestQuerySchema
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
  endsWith?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  startsWith?: string;
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface Task {
  archived?: boolean;
  assignee?: null | object;
  comments?: string[];
  createdAt?: string;
  description?: string;
  dueDate?: string;
  id?: string;
  priority?: TaskPriority;
  status?: TaskStatus;
  title?: string;
  updatedAt?: string;
}

export interface TaskCreatePayload {
  description?: null | string;
  dueDate?: null | string;
  priority?: TaskPriority | null;
  status?: TaskStatus | null;
  title: string;
}

export interface TaskFilter {
  _and?: TaskFilter[];
  _not?: TaskFilter;
  _or?: TaskFilter[];
  priority?: TaskPriorityFilter;
  status?: TaskStatusFilter;
}

export type TaskInclude = object;

export interface TaskPage {
  number?: number;
  size?: number;
}

export type TaskPriority = 'critical' | 'high' | 'low' | 'medium';

export type TaskPriorityFilter = TaskPriority | { eq?: TaskPriority; in?: TaskPriority[] };

export interface TaskSort {
  createdAt?: SortDirection;
  dueDate?: SortDirection;
}

export type TaskStatus = 'archived' | 'completed' | 'in_progress' | 'pending';

export type TaskStatusFilter = TaskStatus | { eq?: TaskStatus; in?: TaskStatus[] };

export interface TaskUpdatePayload {
  description?: null | string;
  dueDate?: null | string;
  priority?: TaskPriority | null;
  status?: TaskStatus | null;
  title?: string;
}

export interface TasksArchiveRequest {
  query: TasksArchiveRequestQuery;
}

export interface TasksArchiveRequestQuery {
  include?: TaskInclude;
}

export interface TasksArchiveResponse {
  body: TasksArchiveResponseBody;
}

export type TasksArchiveResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };

export interface TasksCreateRequest {
  query: TasksCreateRequestQuery;
  body: TasksCreateRequestBody;
}

export interface TasksCreateRequestBody {
  task: TaskCreatePayload;
}

export interface TasksCreateRequestQuery {
  include?: TaskInclude;
}

export interface TasksCreateResponse {
  body: TasksCreateResponseBody;
}

export type TasksCreateResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };

export type TasksDestroyResponse = never;

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

export type TasksIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: OffsetPagination; tasks?: Task[] };

export interface TasksShowRequest {
  query: TasksShowRequestQuery;
}

export interface TasksShowRequestQuery {
  include?: TaskInclude;
}

export interface TasksShowResponse {
  body: TasksShowResponseBody;
}

export type TasksShowResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };

export interface TasksUpdateRequest {
  query: TasksUpdateRequestQuery;
  body: TasksUpdateRequestBody;
}

export interface TasksUpdateRequestBody {
  task: TaskUpdatePayload;
}

export interface TasksUpdateRequestQuery {
  include?: TaskInclude;
}

export interface TasksUpdateResponse {
  body: TasksUpdateResponseBody;
}

export type TasksUpdateResponseBody = { issues?: Issue[] } | { meta?: object; task: Task };
