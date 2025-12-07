export interface ActivitiesCreateRequest {
  body: ActivitiesCreateRequestBody;
}

export interface ActivitiesCreateRequestBody {
  activity: ActivityCreatePayload;
}

export interface ActivitiesCreateResponse {
  body: ActivitiesCreateResponseBody;
}

export type ActivitiesCreateResponseBody = { activity: Activity; meta?: object } | { issues?: Issue[] };

export interface ActivitiesIndexRequest {
  query: ActivitiesIndexRequestQuery;
}

export interface ActivitiesIndexRequestQuery {
  include?: ActivityInclude;
  page?: ActivityPage;
}

export interface ActivitiesIndexResponse {
  body: ActivitiesIndexResponseBody;
}

export type ActivitiesIndexResponseBody = { activities?: Activity[]; meta?: object; pagination?: CursorPagination } | { issues?: Issue[] };

export interface ActivitiesShowResponse {
  body: ActivitiesShowResponseBody;
}

export type ActivitiesShowResponseBody = { activity: Activity; meta?: object } | { issues?: Issue[] };

export interface ActivitiesUpdateRequest {
  body: ActivitiesUpdateRequestBody;
}

export interface ActivitiesUpdateRequestBody {
  activity: ActivityUpdatePayload;
}

export interface ActivitiesUpdateResponse {
  body: ActivitiesUpdateResponseBody;
}

export type ActivitiesUpdateResponseBody = { activity: Activity; meta?: object } | { issues?: Issue[] };

export interface Activity {
  action?: string;
  created_at?: string;
  id?: string;
  occurred_at?: string;
}

export interface ActivityCreatePayload {
  action: string;
  occurred_at?: null | string;
}

export type ActivityInclude = object;

export interface ActivityPage {
  after?: string;
  before?: string;
  size?: number;
}

export interface ActivityUpdatePayload {
  action?: string;
  occurred_at?: null | string;
}

export interface CursorPagination {
  next_cursor?: null | string;
  prev_cursor?: null | string;
}

export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}