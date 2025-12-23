export interface Error {
  code: string;
  detail: string;
  layer: 'contract' | 'domain' | 'http';
  meta: object;
  path: string[];
  pointer: string;
}

export interface StatusHealthResponse {
  body: StatusHealthResponseBody;
}

export type StatusHealthResponseBody = { status: string; timestamp: string; version: string };

export interface StatusStatsResponse {
  body: StatusStatsResponseBody;
}

export type StatusStatsResponseBody = { postsCount: number; uptimeSeconds: number; usersCount: number };