export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export type PostPriority = 'critical' | 'high' | 'low' | 'medium';