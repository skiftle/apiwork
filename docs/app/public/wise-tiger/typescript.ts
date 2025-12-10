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

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Project {
  createdAt?: string;
  deadline?: string;
  description?: string;
  id?: string;
  name?: string;
  priority?: ProjectPriority;
  status?: ProjectStatus;
  updatedAt?: string;
}

export interface ProjectCreatePayload {
  deadline?: null | string;
  description?: null | string;
  name: string;
  priority?: ProjectPriority | null;
  status?: ProjectStatus | null;
}

export interface ProjectFilter {
  _and?: ProjectFilter[];
  _not?: ProjectFilter;
  _or?: ProjectFilter[];
  priority?: ProjectPriorityFilter;
  status?: ProjectStatusFilter;
}

export type ProjectInclude = object;

export interface ProjectPage {
  number?: number;
  size?: number;
}

export type ProjectPriority = 'critical' | 'high' | 'low' | 'medium';

export type ProjectPriorityFilter = ProjectPriority | { eq?: ProjectPriority; in?: ProjectPriority[] };

export interface ProjectSort {
  createdAt?: SortDirection;
  deadline?: SortDirection;
}

export type ProjectStatus = 'active' | 'archived' | 'completed' | 'paused';

export type ProjectStatusFilter = ProjectStatus | { eq?: ProjectStatus; in?: ProjectStatus[] };

export interface ProjectUpdatePayload {
  deadline?: null | string;
  description?: null | string;
  name?: string;
  priority?: ProjectPriority | null;
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

export type ProjectsCreateResponseBody = { issues?: Issue[] } | { meta?: object; project: Project };

export type ProjectsDestroyResponse = never;

export interface ProjectsIndexRequest {
  query: ProjectsIndexRequestQuery;
}

export interface ProjectsIndexRequestQuery {
  filter?: ProjectFilter | ProjectFilter[];
  include?: ProjectInclude;
  page?: ProjectPage;
  sort?: ProjectSort | ProjectSort[];
}

export interface ProjectsIndexResponse {
  body: ProjectsIndexResponseBody;
}

export type ProjectsIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: OffsetPagination; projects?: Project[] };

export interface ProjectsShowResponse {
  body: ProjectsShowResponseBody;
}

export type ProjectsShowResponseBody = { issues?: Issue[] } | { meta?: object; project: Project };

export interface ProjectsUpdateRequest {
  body: ProjectsUpdateRequestBody;
}

export interface ProjectsUpdateRequestBody {
  project: ProjectUpdatePayload;
}

export interface ProjectsUpdateResponse {
  body: ProjectsUpdateResponseBody;
}

export type ProjectsUpdateResponseBody = { issues?: Issue[] } | { meta?: object; project: Project };

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}