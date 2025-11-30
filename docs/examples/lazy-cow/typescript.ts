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

export interface PagePagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type PostPriority = 'critical' | 'high' | 'low' | 'medium';