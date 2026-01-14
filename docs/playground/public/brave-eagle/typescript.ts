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