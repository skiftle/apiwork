import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const TaskPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const TaskStatusSchema = z.enum(['archived', 'completed', 'in_progress', 'pending']);

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.object({}),
  path: z.array(z.string()),
  pointer: z.string()
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
  archived: z.boolean().nullable(),
  assignee: z.object({}).nullable().optional(),
  comments: z.array(z.string()).optional(),
  createdAt: z.iso.datetime(),
  description: z.string().nullable(),
  dueDate: z.iso.datetime().nullable(),
  id: z.string(),
  priority: TaskPrioritySchema.nullable(),
  status: TaskStatusSchema.nullable(),
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

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const TaskArchiveSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  task: TaskSchema
});

export const TaskCreateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  task: TaskSchema
});

export const TaskIndexSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  pagination: OffsetPaginationSchema,
  tasks: z.array(TaskSchema)
});

export const TaskShowSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  task: TaskSchema
});

export const TaskUpdateSuccessResponseBodySchema = z.object({
  meta: z.object({}).optional(),
  task: TaskSchema
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

export const TasksIndexResponseBodySchema = z.union([TaskIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksIndexResponseSchema = z.object({
  body: TasksIndexResponseBodySchema
});

export const TasksShowResponseBodySchema = z.union([TaskShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksShowResponseSchema = z.object({
  body: TasksShowResponseBodySchema
});

export const TasksCreateRequestBodySchema = z.object({
  task: TaskCreatePayloadSchema
});

export const TasksCreateRequestSchema = z.object({
  body: TasksCreateRequestBodySchema
});

export const TasksCreateResponseBodySchema = z.union([TaskCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksCreateResponseSchema = z.object({
  body: TasksCreateResponseBodySchema
});

export const TasksUpdateRequestBodySchema = z.object({
  task: TaskUpdatePayloadSchema
});

export const TasksUpdateRequestSchema = z.object({
  body: TasksUpdateRequestBodySchema
});

export const TasksUpdateResponseBodySchema = z.union([TaskUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksUpdateResponseSchema = z.object({
  body: TasksUpdateResponseBodySchema
});

export const TasksDestroyResponse = z.never();

export const TasksArchiveResponseBodySchema = z.union([TaskArchiveSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksArchiveResponseSchema = z.object({
  body: TasksArchiveResponseBodySchema
});

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

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
  /** Whether the task has been archived */
  archived: boolean | null;
  /** User responsible for completing this task */
  assignee?: null | object;
  /** Discussion comments on this task */
  comments?: string[];
  /** Timestamp when the task was created */
  createdAt: string;
  /**
   * Detailed description of what needs to be done
   * @example "Add OAuth2 login support for Google and GitHub providers"
   */
  description: null | string;
  /**
   * Target date for task completion
   * @example "2024-02-01T00:00:00Z"
   */
  dueDate: null | string;
  /** Unique task identifier */
  id: string;
  /**
   * Priority level for task ordering
   * @example "high"
   */
  priority: TaskPriority | null;
  /**
   * Current status of the task
   * @example "pending"
   */
  status: TaskStatus | null;
  /**
   * Short title describing the task
   * @example "Implement user authentication"
   */
  title: string;
  /** Timestamp of last modification */
  updatedAt: string;
}

export interface TaskArchiveSuccessResponseBody {
  meta?: object;
  task: Task;
}

export interface TaskCreatePayload {
  /**
   * Detailed description of what needs to be done
   * @example "Add OAuth2 login support for Google and GitHub providers"
   */
  description?: null | string;
  /**
   * Target date for task completion
   * @example "2024-02-01T00:00:00Z"
   */
  dueDate?: null | string;
  /**
   * Priority level for task ordering
   * @example "high"
   */
  priority?: TaskPriority | null;
  /**
   * Current status of the task
   * @example "pending"
   */
  status?: TaskStatus | null;
  /**
   * Short title describing the task
   * @example "Implement user authentication"
   */
  title: string;
}

export interface TaskCreateSuccessResponseBody {
  meta?: object;
  task: Task;
}

export interface TaskFilter {
  _and?: TaskFilter[];
  _not?: TaskFilter;
  _or?: TaskFilter[];
  priority?: TaskPriorityFilter;
  status?: TaskStatusFilter;
}

export interface TaskIndexSuccessResponseBody {
  meta?: object;
  pagination: OffsetPagination;
  tasks: Task[];
}

export interface TaskPage {
  number?: number;
  size?: number;
}

export type TaskPriority = 'critical' | 'high' | 'low' | 'medium';

export type TaskPriorityFilter = TaskPriority | { eq?: TaskPriority; in?: TaskPriority[] };

export interface TaskShowSuccessResponseBody {
  meta?: object;
  task: Task;
}

export interface TaskSort {
  createdAt?: SortDirection;
  dueDate?: SortDirection;
}

export type TaskStatus = 'archived' | 'completed' | 'in_progress' | 'pending';

export type TaskStatusFilter = TaskStatus | { eq?: TaskStatus; in?: TaskStatus[] };

export interface TaskUpdatePayload {
  /**
   * Detailed description of what needs to be done
   * @example "Add OAuth2 login support for Google and GitHub providers"
   */
  description?: null | string;
  /**
   * Target date for task completion
   * @example "2024-02-01T00:00:00Z"
   */
  dueDate?: null | string;
  /**
   * Priority level for task ordering
   * @example "high"
   */
  priority?: TaskPriority | null;
  /**
   * Current status of the task
   * @example "pending"
   */
  status?: TaskStatus | null;
  /**
   * Short title describing the task
   * @example "Implement user authentication"
   */
  title?: string;
}

export interface TaskUpdateSuccessResponseBody {
  meta?: object;
  task: Task;
}

export interface TasksArchiveResponse {
  body: TasksArchiveResponseBody;
}

export type TasksArchiveResponseBody = ErrorResponseBody | TaskArchiveSuccessResponseBody;

export interface TasksCreateRequest {
  body: TasksCreateRequestBody;
}

export interface TasksCreateRequestBody {
  task: TaskCreatePayload;
}

export interface TasksCreateResponse {
  body: TasksCreateResponseBody;
}

export type TasksCreateResponseBody = ErrorResponseBody | TaskCreateSuccessResponseBody;

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

export type TasksIndexResponseBody = ErrorResponseBody | TaskIndexSuccessResponseBody;

export interface TasksShowResponse {
  body: TasksShowResponseBody;
}

export type TasksShowResponseBody = ErrorResponseBody | TaskShowSuccessResponseBody;

export interface TasksUpdateRequest {
  body: TasksUpdateRequestBody;
}

export interface TasksUpdateRequestBody {
  task: TaskUpdatePayload;
}

export interface TasksUpdateResponse {
  body: TasksUpdateResponseBody;
}

export type TasksUpdateResponseBody = ErrorResponseBody | TaskUpdateSuccessResponseBody;
