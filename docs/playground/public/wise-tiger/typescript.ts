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
  /** Timestamp when project was created */
  createdAt: string;
  /** Target completion date */
  deadline: null | string;
  /** Detailed project description */
  description: null | string;
  /** Unique project identifier */
  id: string;
  /** Human-readable project name */
  name: string;
  /** Project priority for resource allocation */
  priority: ProjectPriority | null;
  /** Current project lifecycle status */
  status: ProjectStatus | null;
  /** Timestamp of last modification */
  updatedAt: string;
}

/** A project with tasks and deadlines */
export interface ProjectCreatePayload {
  /** Target completion date */
  deadline?: null | string;
  /** Detailed project description */
  description?: null | string;
  /** Human-readable project name */
  name: string;
  /** Project priority for resource allocation */
  priority?: ProjectPriority | null;
  /** Current project lifecycle status */
  status?: ProjectStatus | null;
}

/** A project with tasks and deadlines */
export interface ProjectFilter {
  _and?: ProjectFilter[];
  _not?: ProjectFilter;
  _or?: ProjectFilter[];
  /** Project priority for resource allocation */
  priority?: ProjectPriorityFilter;
  /** Current project lifecycle status */
  status?: ProjectStatusFilter;
}

export interface ProjectPage {
  number?: number;
  size?: number;
}

export type ProjectPriority = 'critical' | 'high' | 'low' | 'medium';

export type ProjectPriorityFilter = ProjectPriority | { eq?: ProjectPriority; in?: ProjectPriority[] };

/** A project with tasks and deadlines */
export interface ProjectSort {
  /** Timestamp when project was created */
  createdAt?: SortDirection;
  /** Target completion date */
  deadline?: SortDirection;
}

export type ProjectStatus = 'active' | 'archived' | 'completed' | 'paused';

export type ProjectStatusFilter = ProjectStatus | { eq?: ProjectStatus; in?: ProjectStatus[] };

/** A project with tasks and deadlines */
export interface ProjectUpdatePayload {
  /** Target completion date */
  deadline?: null | string;
  /** Detailed project description */
  description?: null | string;
  /** Human-readable project name */
  name?: string;
  /** Project priority for resource allocation */
  priority?: ProjectPriority | null;
  /** Current project lifecycle status */
  status?: ProjectStatus | null;
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

export type ProjectsCreateResponseBody = ErrorResponseBody | { meta?: object; project: Project };

export type ProjectsDestroyResponse = never;

export interface ProjectsIndexRequest {
  query: ProjectsIndexRequestQuery;
}

export interface ProjectsIndexRequestQuery {
  filter?: ProjectFilter | ProjectFilter[];
  page?: ProjectPage;
  sort?: ProjectSort | ProjectSort[];
}

export interface ProjectsIndexResponse {
  body: ProjectsIndexResponseBody;
}

export type ProjectsIndexResponseBody = ErrorResponseBody | { meta?: object; pagination?: OffsetPagination; projects?: Project[] };

export interface ProjectsShowResponse {
  body: ProjectsShowResponseBody;
}

export type ProjectsShowResponseBody = ErrorResponseBody | { meta?: object; project: Project };

export interface ProjectsUpdateRequest {
  body: ProjectsUpdateRequestBody;
}

export interface ProjectsUpdateRequestBody {
  project: ProjectUpdatePayload;
}

export interface ProjectsUpdateResponse {
  body: ProjectsUpdateResponseBody;
}

export type ProjectsUpdateResponseBody = ErrorResponseBody | { meta?: object; project: Project };

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}