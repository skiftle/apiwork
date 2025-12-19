import { z } from 'zod';

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const TaskPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const TaskStatusSchema = z.enum(['archived', 'completed', 'in_progress', 'pending']);

export const ErrorSchema = z.object({
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
  archived: z.boolean().nullable().optional(),
  assignee: z.object({}).nullable().optional(),
  comments: z.array(z.string()).optional(),
  createdAt: z.iso.datetime(),
  description: z.string().nullable().optional(),
  dueDate: z.iso.datetime().nullable().optional(),
  id: z.string(),
  priority: TaskPrioritySchema.nullable().optional(),
  status: TaskStatusSchema.nullable().optional(),
  title: z.string(),
  updatedAt: z.iso.datetime()
});

export const TaskCreatePayloadSchema = z.object({
  description: z.string().nullable().optional(),
  dueDate: z.iso.datetime().nullable().optional(),
  priority: TaskPrioritySchema.nullable().optional(),
  status: TaskStatusSchema.nullable().optional(),
  title: z.string()
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
  page: TaskPageSchema.optional(),
  sort: z.union([TaskSortSchema, z.array(TaskSortSchema)]).optional()
});

export const TasksIndexRequestSchema = z.object({
  query: TasksIndexRequestQuerySchema
});

export const TasksIndexResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), pagination: OffsetPaginationSchema.optional(), tasks: z.array(TaskSchema).optional() }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const TasksIndexResponseSchema = z.object({
  body: TasksIndexResponseBodySchema
});

export const TasksShowResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const TasksShowResponseSchema = z.object({
  body: TasksShowResponseBodySchema
});

export const TasksCreateRequestBodySchema = z.object({
  task: TaskCreatePayloadSchema
});

export const TasksCreateRequestSchema = z.object({
  body: TasksCreateRequestBodySchema
});

export const TasksCreateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const TasksCreateResponseSchema = z.object({
  body: TasksCreateResponseBodySchema
});

export const TasksUpdateRequestBodySchema = z.object({
  task: TaskUpdatePayloadSchema
});

export const TasksUpdateRequestSchema = z.object({
  body: TasksUpdateRequestBodySchema
});

export const TasksUpdateResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const TasksUpdateResponseSchema = z.object({
  body: TasksUpdateResponseBodySchema
});

export const TasksDestroyResponse = z.never();

export const TasksArchiveResponseBodySchema = z.union([z.object({ meta: z.object({}).optional(), task: TaskSchema }), z.object({ errors: z.array(ErrorSchema).optional() })]);

export const TasksArchiveResponseSchema = z.object({
  body: TasksArchiveResponseBodySchema
});

export interface Error {
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
  archived?: boolean | null;
  assignee?: null | object;
  comments?: string[];
  createdAt: string;
  description?: null | string;
  dueDate?: null | string;
  id: string;
  priority?: TaskPriority | null;
  status?: TaskStatus | null;
  title: string;
  updatedAt: string;
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

export interface TasksArchiveResponse {
  body: TasksArchiveResponseBody;
}

export type TasksArchiveResponseBody = { errors?: Error[] } | { meta?: object; task: Task };

export interface TasksCreateRequest {
  body: TasksCreateRequestBody;
}

export interface TasksCreateRequestBody {
  task: TaskCreatePayload;
}

export interface TasksCreateResponse {
  body: TasksCreateResponseBody;
}

export type TasksCreateResponseBody = { errors?: Error[] } | { meta?: object; task: Task };

export type TasksDestroyResponse = never;

export interface TasksIndexRequest {
  query: TasksIndexRequestQuery;
}

export interface TasksIndexRequestQuery {
  filter?: TaskFilter | TaskFilter[];
  page?: TaskPage;
  sort?: TaskSort | TaskSort[];
}

export interface TasksIndexResponse {
  body: TasksIndexResponseBody;
}

export type TasksIndexResponseBody = { errors?: Error[] } | { meta?: object; pagination?: OffsetPagination; tasks?: Task[] };

export interface TasksShowResponse {
  body: TasksShowResponseBody;
}

export type TasksShowResponseBody = { errors?: Error[] } | { meta?: object; task: Task };

export interface TasksUpdateRequest {
  body: TasksUpdateRequestBody;
}

export interface TasksUpdateRequestBody {
  task: TaskUpdatePayload;
}

export interface TasksUpdateResponse {
  body: TasksUpdateResponseBody;
}

export type TasksUpdateResponseBody = { errors?: Error[] } | { meta?: object; task: Task };
