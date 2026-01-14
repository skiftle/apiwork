import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const TaskPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const TaskStatusSchema = z.enum(['archived', 'completed', 'in_progress', 'pending']);

export const CommentSchema = z.object({
  authorName: z.string().nullable(),
  body: z.string(),
  createdAt: z.iso.datetime(),
  id: z.string()
});

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const TaskCreatePayloadSchema = z.object({
  description: z.string().nullable().optional(),
  dueDate: z.iso.datetime().nullable().optional(),
  priority: TaskPrioritySchema.nullable().optional(),
  status: TaskStatusSchema.nullable().optional(),
  title: z.string()
});

export const TaskIncludeSchema = z.object({
  assignee: z.boolean().optional(),
  comments: z.boolean().optional()
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

export const UserSchema = z.object({
  email: z.email(),
  id: z.string(),
  name: z.string()
});

export const ErrorResponseBodySchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const TaskFilterSchema: z.ZodType<TaskFilter> = z.lazy(() => z.object({
  _and: z.array(TaskFilterSchema).optional(),
  _not: TaskFilterSchema.optional(),
  _or: z.array(TaskFilterSchema).optional(),
  priority: TaskPriorityFilterSchema.optional(),
  status: TaskStatusFilterSchema.optional()
}));

export const TaskSchema = z.object({
  archived: z.boolean().nullable(),
  assignee: UserSchema.nullable().optional(),
  comments: z.array(CommentSchema).optional(),
  createdAt: z.iso.datetime(),
  description: z.string().nullable(),
  dueDate: z.iso.datetime().nullable(),
  id: z.string(),
  priority: TaskPrioritySchema.nullable(),
  status: TaskStatusSchema.nullable(),
  title: z.string(),
  updatedAt: z.iso.datetime()
});

export const TaskArchiveSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  task: TaskSchema
});

export const TaskCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  task: TaskSchema
});

export const TaskIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema,
  tasks: z.array(TaskSchema)
});

export const TaskShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  task: TaskSchema
});

export const TaskUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  task: TaskSchema
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

export const TasksIndexResponseBodySchema = z.union([TaskIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksIndexResponseSchema = z.object({
  body: TasksIndexResponseBodySchema
});

export const TasksShowRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksShowRequestSchema = z.object({
  query: TasksShowRequestQuerySchema
});

export const TasksShowResponseBodySchema = z.union([TaskShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

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

export const TasksCreateResponseBodySchema = z.union([TaskCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

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

export const TasksUpdateResponseBodySchema = z.union([TaskUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksUpdateResponseSchema = z.object({
  body: TasksUpdateResponseBodySchema
});

export const TasksDestroyRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksDestroyRequestSchema = z.object({
  query: TasksDestroyRequestQuerySchema
});

export const TasksDestroyResponse = z.never();

export const TasksArchiveRequestQuerySchema = z.object({
  include: TaskIncludeSchema.optional()
});

export const TasksArchiveRequestSchema = z.object({
  query: TasksArchiveRequestQuerySchema
});

export const TasksArchiveResponseBodySchema = z.union([TaskArchiveSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const TasksArchiveResponseSchema = z.object({
  body: TasksArchiveResponseBodySchema
});

/** A comment on a task */
export interface Comment {
  /**
   * Name of the person who wrote the comment
   * @example "John Doe"
   */
  authorName: null | string;
  /**
   * Comment content
   * @example "This looks good, ready for review."
   */
  body: string;
  /** When the comment was created */
  createdAt: string;
  /** Unique comment identifier */
  id: string;
}

export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

export interface Issue {
  code: string;
  detail: string;
  meta: Record<string, unknown>;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

/** A task representing work to be completed */
export interface Task {
  /** Whether the task has been archived */
  archived: boolean | null;
  /** User responsible for completing this task */
  assignee?: User | null;
  /** Discussion comments on this task */
  comments?: Comment[];
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
  meta?: Record<string, unknown>;
  task: Task;
}

/** A task representing work to be completed */
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
  meta?: Record<string, unknown>;
  task: Task;
}

/** A task representing work to be completed */
export interface TaskFilter {
  _and?: TaskFilter[];
  _not?: TaskFilter;
  _or?: TaskFilter[];
  priority?: TaskPriorityFilter;
  status?: TaskStatusFilter;
}

export interface TaskInclude {
  assignee?: boolean;
  comments?: boolean;
}

export interface TaskIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
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
  meta?: Record<string, unknown>;
  task: Task;
}

/** A task representing work to be completed */
export interface TaskSort {
  createdAt?: SortDirection;
  dueDate?: SortDirection;
}

export type TaskStatus = 'archived' | 'completed' | 'in_progress' | 'pending';

export type TaskStatusFilter = TaskStatus | { eq?: TaskStatus; in?: TaskStatus[] };

/** A task representing work to be completed */
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
  meta?: Record<string, unknown>;
  task: Task;
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

export type TasksArchiveResponseBody = ErrorResponseBody | TaskArchiveSuccessResponseBody;

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

export type TasksCreateResponseBody = ErrorResponseBody | TaskCreateSuccessResponseBody;

export interface TasksDestroyRequest {
  query: TasksDestroyRequestQuery;
}

export interface TasksDestroyRequestQuery {
  include?: TaskInclude;
}

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

export type TasksIndexResponseBody = ErrorResponseBody | TaskIndexSuccessResponseBody;

export interface TasksShowRequest {
  query: TasksShowRequestQuery;
}

export interface TasksShowRequestQuery {
  include?: TaskInclude;
}

export interface TasksShowResponse {
  body: TasksShowResponseBody;
}

export type TasksShowResponseBody = ErrorResponseBody | TaskShowSuccessResponseBody;

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

export type TasksUpdateResponseBody = ErrorResponseBody | TaskUpdateSuccessResponseBody;

/** A user who can be assigned to tasks */
export interface User {
  /**
   * User's email address
   * @example "jane@example.com"
   */
  email: string;
  /** Unique user identifier */
  id: string;
  /**
   * User's display name
   * @example "Jane Doe"
   */
  name: string;
}
