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
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface Task {
  archived?: boolean;
  createdAt?: string;
  description?: string;
  dueDate?: string;
  id?: string;
  priority?: string;
  status?: string;
  title?: string;
  updatedAt?: string;
}

export interface TaskCreatePayload {
  description?: null | string;
  dueDate?: null | string;
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
  createdAt?: unknown;
  dueDate?: unknown;
}

export interface TaskUpdatePayload {
  description?: null | string;
  dueDate?: null | string;
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