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

/** A task representing work to be completed */
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

/** A task representing work to be completed */
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

export interface TasksArchiveResponse {
  body: TasksArchiveResponseBody;
}

export type TasksArchiveResponseBody = ErrorResponseBody | { meta?: object; task: Task };

export interface TasksCreateRequest {
  body: TasksCreateRequestBody;
}

export interface TasksCreateRequestBody {
  task: TaskCreatePayload;
}

export interface TasksCreateResponse {
  body: TasksCreateResponseBody;
}

export type TasksCreateResponseBody = ErrorResponseBody | { meta?: object; task: Task };

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

export type TasksIndexResponseBody = ErrorResponseBody | { meta?: object; pagination?: OffsetPagination; tasks?: Task[] };

export interface TasksShowResponse {
  body: TasksShowResponseBody;
}

export type TasksShowResponseBody = ErrorResponseBody | { meta?: object; task: Task };

export interface TasksUpdateRequest {
  body: TasksUpdateRequestBody;
}

export interface TasksUpdateRequestBody {
  task: TaskUpdatePayload;
}

export interface TasksUpdateResponse {
  body: TasksUpdateResponseBody;
}

export type TasksUpdateResponseBody = ErrorResponseBody | { meta?: object; task: Task };