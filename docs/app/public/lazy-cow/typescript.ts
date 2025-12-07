export interface Issue {
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

export type StatusStatsResponseBody = { posts_count: number; uptime_seconds: number; users_count: number };