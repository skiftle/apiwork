export interface Error {
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

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
  priority: ProjectPriority;
  /** Current project lifecycle status */
  status: ProjectStatus;
  /** Timestamp of last modification */
  updatedAt: string;
}

export interface ProjectCreatePayload {
  /** Target completion date */
  deadline?: null | string;
  /** Detailed project description */
  description?: null | string;
  /** Human-readable project name */
  name: string;
  /** Project priority for resource allocation */
  priority?: ProjectPriority;
  /** Current project lifecycle status */
  status?: ProjectStatus;
}

export interface ProjectCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  project: Project;
}

export interface ProjectFilter {
  AND?: ProjectFilter[];
  NOT?: ProjectFilter;
  OR?: ProjectFilter[];
  /** Project priority for resource allocation */
  priority?: ProjectPriorityFilter;
  /** Current project lifecycle status */
  status?: ProjectStatusFilter;
}

export interface ProjectIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
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
  meta?: Record<string, unknown>;
  project: Project;
}

export interface ProjectSort {
  /** Timestamp when project was created */
  createdAt?: SortDirection;
  /** Target completion date */
  deadline?: SortDirection;
  /** Timestamp of last modification */
  updatedAt?: SortDirection;
}

export type ProjectStatus = 'active' | 'archived' | 'completed' | 'paused';

export type ProjectStatusFilter = ProjectStatus | { eq?: ProjectStatus; in?: ProjectStatus[] };

export interface ProjectUpdatePayload {
  /** Target completion date */
  deadline?: null | string;
  /** Detailed project description */
  description?: null | string;
  /** Human-readable project name */
  name?: string;
  /** Project priority for resource allocation */
  priority?: ProjectPriority;
  /** Current project lifecycle status */
  status?: ProjectStatus;
}

export interface ProjectUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
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
  filter?: ProjectFilter | ProjectFilter[];
  page?: ProjectPage;
  sort?: ProjectSort | ProjectSort[];
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