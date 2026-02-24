export interface ActivitiesCreateRequest {
  body: ActivitiesCreateRequestBody;
}

export interface ActivitiesCreateRequestBody {
  activity: ActivityCreatePayload;
}

export interface ActivitiesCreateResponse {
  body: ActivitiesCreateResponseBody;
}

export type ActivitiesCreateResponseBody = ActivityCreateSuccessResponseBody | ErrorResponseBody;

export type ActivitiesDestroyResponse = never;

export interface ActivitiesIndexRequest {
  query: ActivitiesIndexRequestQuery;
}

export interface ActivitiesIndexRequestQuery {
  page?: ActivityPage;
}

export interface ActivitiesIndexResponse {
  body: ActivitiesIndexResponseBody;
}

export type ActivitiesIndexResponseBody = ActivityIndexSuccessResponseBody | ErrorResponseBody;

export interface ActivitiesShowResponse {
  body: ActivitiesShowResponseBody;
}

export type ActivitiesShowResponseBody = ActivityShowSuccessResponseBody | ErrorResponseBody;

export interface ActivitiesUpdateRequest {
  body: ActivitiesUpdateRequestBody;
}

export interface ActivitiesUpdateRequestBody {
  activity: ActivityUpdatePayload;
}

export interface ActivitiesUpdateResponse {
  body: ActivitiesUpdateResponseBody;
}

export type ActivitiesUpdateResponseBody = ActivityUpdateSuccessResponseBody | ErrorResponseBody;

export interface Activity {
  action: string;
  createdAt: string;
  id: string;
  occurredAt: null | string;
  updatedAt: string;
}

export interface ActivityCreatePayload {
  action: string;
  occurredAt?: null | string;
}

export interface ActivityCreateSuccessResponseBody {
  activity: Activity;
  meta?: Record<string, unknown>;
}

export interface ActivityIndexSuccessResponseBody {
  activities: Activity[];
  meta?: Record<string, unknown>;
  pagination: CursorPagination;
}

export interface ActivityPage {
  after?: string;
  before?: string;
  size?: number;
}

export interface ActivityShowSuccessResponseBody {
  activity: Activity;
  meta?: Record<string, unknown>;
}

export interface ActivityUpdatePayload {
  action?: string;
  occurredAt?: null | string;
}

export interface ActivityUpdateSuccessResponseBody {
  activity: Activity;
  meta?: Record<string, unknown>;
}

export interface CursorPagination {
  next?: null | string;
  prev?: null | string;
}

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