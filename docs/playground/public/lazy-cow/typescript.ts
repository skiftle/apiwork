export interface Error {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface StatusHealthResponse {
  body: StatusHealthResponseBody;
}

export type StatusHealthResponseBody = { status: string; timestamp: string; version: string };

export interface StatusStatsResponse {
  body: StatusStatsResponseBody;
}

export type StatusStatsResponseBody = { postsCount: number; uptimeSeconds: number; usersCount: number };