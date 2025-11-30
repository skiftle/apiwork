export type Status = 'archived' | 'draft' | 'published';

export type StatusFilter = Status | { eq?: Status; in?: Status[] };