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

/** A project with tasks and deadlines */
export interface Project {
  createdAt: string;
  deadline: null | string;
  description: null | string;
  id: string;
  name: string;
  priority: ProjectPriority | null;
  status: ProjectStatus | null;
  updatedAt: string;
}

/** A project with tasks and deadlines */
export interface ProjectCreatePayload {
  deadline?: null | string;
  description?: null | string;
  name: string;
  priority?: ProjectPriority | null;
  status?: ProjectStatus | null;
}

export interface ProjectCreateSuccessResponseBody {
  meta?: object;
  project: Project;
}

/** A project with tasks and deadlines */
export interface ProjectFilter {
  _and?: unknown[];
  _not?: unknown;
  _or?: unknown[];
  priority?: ProjectPriorityFilter;
  status?: ProjectStatusFilter;
}

export interface ProjectIndexSuccessResponseBody {
  meta?: object;
  pagination: OffsetPagination;
  projects: Project[];
}

export interface ProjectPage {
  number?: number;
  size?: number;
}

export type ProjectPriority = 'critical' | 'high' | 'low' | 'medium';

export type ProjectPriorityFilter = ProjectPriority | { eq?: ProjectPriority; in?: ProjectPriority[] };

export interface ProjectShowSuccessResponseBody {
  meta?: object;
  project: Project;
}

/** A project with tasks and deadlines */
export interface ProjectSort {
  createdAt?: SortDirection;
  deadline?: SortDirection;
}

export type ProjectStatus = 'active' | 'archived' | 'completed' | 'paused';

export type ProjectStatusFilter = ProjectStatus | { eq?: ProjectStatus; in?: ProjectStatus[] };

/** A project with tasks and deadlines */
export interface ProjectUpdatePayload {
  deadline?: null | string;
  description?: null | string;
  name?: string;
  priority?: ProjectPriority | null;
  status?: ProjectStatus | null;
}

export interface ProjectUpdateSuccessResponseBody {
  meta?: object;
  project: Project;
}

export interface ProjectsCreateRequest {
  body: ProjectsCreateRequestBody;
}

export interface ProjectsCreateRequestBody {
  project: ProjectCreatePayload;
}

export interface ProjectsCreateResponse {
  body: ProjectsCreateResponseBody;
}

export type ProjectsCreateResponseBody = ErrorResponseBody | ProjectCreateSuccessResponseBody;

export type ProjectsDestroyResponse = never;

export interface ProjectsIndexRequest {
  query: ProjectsIndexRequestQuery;
}

export interface ProjectsIndexRequestQuery {
  filter?: ProjectFilter | string[];
  page?: ProjectPage;
  sort?: ProjectSort | string[];
}

export interface ProjectsIndexResponse {
  body: ProjectsIndexResponseBody;
}

export type ProjectsIndexResponseBody = ErrorResponseBody | ProjectIndexSuccessResponseBody;

export interface ProjectsShowResponse {
  body: ProjectsShowResponseBody;
}

export type ProjectsShowResponseBody = ErrorResponseBody | ProjectShowSuccessResponseBody;

export interface ProjectsUpdateRequest {
  body: ProjectsUpdateRequestBody;
}

export interface ProjectsUpdateRequestBody {
  project: ProjectUpdatePayload;
}

export interface ProjectsUpdateResponse {
  body: ProjectsUpdateResponseBody;
}

export type ProjectsUpdateResponseBody = ErrorResponseBody | ProjectUpdateSuccessResponseBody;

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}