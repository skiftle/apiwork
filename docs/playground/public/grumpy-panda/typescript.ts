export interface ActivitiesCreateRequest {
  body: ActivitiesCreateRequestBody;
}

export interface ActivitiesCreateRequestBody {
  activity: ActivityCreatePayload;
}

export interface ActivitiesCreateResponse {
  body: ActivitiesCreateResponseBody;
}

export type ActivitiesCreateResponseBody = { activity: Activity; meta?: object } | { issues?: Error[] };

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

export type ActivitiesIndexResponseBody = { activities?: Activity[]; meta?: object; pagination?: CursorPagination } | { issues?: Error[] };

export interface ActivitiesShowResponse {
  body: ActivitiesShowResponseBody;
}

export type ActivitiesShowResponseBody = { activity: Activity; meta?: object } | { issues?: Error[] };

export interface ActivitiesUpdateRequest {
  body: ActivitiesUpdateRequestBody;
}

export interface ActivitiesUpdateRequestBody {
  activity: ActivityUpdatePayload;
}

export interface ActivitiesUpdateResponse {
  body: ActivitiesUpdateResponseBody;
}

export type ActivitiesUpdateResponseBody = { activity: Activity; meta?: object } | { issues?: Error[] };

export interface Activity {
  action: string;
  createdAt: string;
  id: string;
  occurredAt: null | string;
}

export interface ActivityCreatePayload {
  action: string;
  occurredAt?: null | string;
}

export interface ActivityPage {
  after?: string;
  before?: string;
  size?: number;
}

export interface ActivityUpdatePayload {
  action?: string;
  occurredAt?: null | string;
}

export interface CursorPagination {
  next?: null | string;
  prev?: null | string;
}

export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  issues: Error[];
  layer: Layer;
}

export type Layer = 'contract' | 'domain' | 'http';