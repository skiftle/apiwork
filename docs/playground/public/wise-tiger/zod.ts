import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const ProjectPrioritySchema = z.enum(['critical', 'high', 'low', 'medium']);

export const ProjectStatusSchema = z.enum(['active', 'archived', 'completed', 'paused']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const ProjectFilterSchema: z.ZodType<ProjectFilter> = z.lazy(() => z.object({
  AND: z.array(ProjectFilterSchema).optional(),
  NOT: ProjectFilterSchema.optional(),
  OR: z.array(ProjectFilterSchema).optional(),
  priority: ProjectPriorityFilterSchema.optional(),
  status: ProjectStatusFilterSchema.optional()
}));

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

export const ProjectSchema = z.object({
  createdAt: z.iso.datetime(),
  deadline: z.iso.date().nullable(),
  description: z.string().nullable(),
  id: z.string(),
  name: z.string(),
  priority: ProjectPrioritySchema,
  status: ProjectStatusSchema,
  updatedAt: z.iso.datetime()
});

export const ProjectCreatePayloadSchema = z.object({
  deadline: z.iso.date().nullable().optional(),
  description: z.string().nullable().optional(),
  name: z.string(),
  priority: ProjectPrioritySchema.optional(),
  status: ProjectStatusSchema.optional()
});

export const ProjectPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ProjectPriorityFilterSchema = z.union([
  ProjectPrioritySchema,
  z.object({ eq: ProjectPrioritySchema, in: z.array(ProjectPrioritySchema) }).partial()
]);

export const ProjectSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  deadline: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const ProjectStatusFilterSchema = z.union([
  ProjectStatusSchema,
  z.object({ eq: ProjectStatusSchema, in: z.array(ProjectStatusSchema) }).partial()
]);

export const ProjectUpdatePayloadSchema = z.object({
  deadline: z.iso.date().nullable().optional(),
  description: z.string().nullable().optional(),
  name: z.string().optional(),
  priority: ProjectPrioritySchema.optional(),
  status: ProjectStatusSchema.optional()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ProjectCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  project: ProjectSchema
});

export const ProjectIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema,
  projects: z.array(ProjectSchema)
});

export const ProjectShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  project: ProjectSchema
});

export const ProjectUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  project: ProjectSchema
});

export const ErrorResponseBodySchema = ErrorSchema;

export const ProjectsIndexRequestQuerySchema = z.object({
  filter: z.union([ProjectFilterSchema, z.array(ProjectFilterSchema)]).optional(),
  page: ProjectPageSchema.optional(),
  sort: z.union([ProjectSortSchema, z.array(ProjectSortSchema)]).optional()
});

export const ProjectsIndexRequestSchema = z.object({
  query: ProjectsIndexRequestQuerySchema
});

export const ProjectsIndexResponseBodySchema = z.union([ProjectIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProjectsIndexResponseSchema = z.object({
  body: ProjectsIndexResponseBodySchema
});

export const ProjectsShowResponseBodySchema = z.union([ProjectShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProjectsShowResponseSchema = z.object({
  body: ProjectsShowResponseBodySchema
});

export const ProjectsCreateRequestBodySchema = z.object({
  project: ProjectCreatePayloadSchema
});

export const ProjectsCreateRequestSchema = z.object({
  body: ProjectsCreateRequestBodySchema
});

export const ProjectsCreateResponseBodySchema = z.union([ProjectCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProjectsCreateResponseSchema = z.object({
  body: ProjectsCreateResponseBodySchema
});

export const ProjectsUpdateRequestBodySchema = z.object({
  project: ProjectUpdatePayloadSchema
});

export const ProjectsUpdateRequestSchema = z.object({
  body: ProjectsUpdateRequestBodySchema
});

export const ProjectsUpdateResponseBodySchema = z.union([ProjectUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProjectsUpdateResponseSchema = z.object({
  body: ProjectsUpdateResponseBodySchema
});

export const ProjectsDestroyResponseSchema = z.never();

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
