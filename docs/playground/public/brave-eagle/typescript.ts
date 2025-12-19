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
  archived?: boolean;
  assignee?: null | object;
  comments?: string[];
  createdAt: string;
  description?: string;
  dueDate?: string;
  id: string;
  priority?: TaskPriority;
  status?: TaskStatus;
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