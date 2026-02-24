export interface CookingStep {
  DurationMinutes: null | number;
  Id: string;
  Instruction: string;
  StepNumber: number;
}

export interface CookingStepNestedCreatePayload {
  OP?: 'create';
  DurationMinutes?: null | number;
  Instruction: string;
  StepNumber: number;
}

export interface CookingStepNestedDeletePayload {
  OP?: 'delete';
  Id: string;
}

export type CookingStepNestedPayload = CookingStepNestedCreatePayload | CookingStepNestedUpdatePayload | CookingStepNestedDeletePayload;

export interface CookingStepNestedUpdatePayload {
  OP?: 'update';
  DurationMinutes?: null | number;
  Id?: string;
  Instruction?: string;
  StepNumber?: number;
}

export interface Error {
  Issues: Issue[];
  Layer: Layer;
}

export type ErrorResponseBody = Error;

export interface Issue {
  Code: string;
  Detail: string;
  Meta: Record<string, unknown>;
  Path: string[];
  Pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface MealPlan {
  CookTime: null | number;
  CookingSteps: CookingStep[];
  CreatedAt: string;
  Id: string;
  ServingSize: null | number;
  Title: string;
  UpdatedAt: string;
}

export interface MealPlanCreatePayload {
  CookTime?: null | number;
  CookingSteps?: CookingStepNestedPayload[];
  ServingSize?: null | number;
  Title: string;
}

export interface MealPlanCreateSuccessResponseBody {
  MealPlan: MealPlan;
  Meta?: Record<string, unknown>;
}

export interface MealPlanIndexSuccessResponseBody {
  MealPlans: MealPlan[];
  Meta?: Record<string, unknown>;
  Pagination: OffsetPagination;
}

export interface MealPlanPage {
  Number?: number;
  Size?: number;
}

export interface MealPlanShowSuccessResponseBody {
  MealPlan: MealPlan;
  Meta?: Record<string, unknown>;
}

export interface MealPlanUpdatePayload {
  CookTime?: null | number;
  CookingSteps?: CookingStepNestedPayload[];
  ServingSize?: null | number;
  Title?: string;
}

export interface MealPlanUpdateSuccessResponseBody {
  MealPlan: MealPlan;
  Meta?: Record<string, unknown>;
}

export interface MealPlansCreateRequest {
  body: MealPlansCreateRequestBody;
}

export interface MealPlansCreateRequestBody {
  MealPlan: MealPlanCreatePayload;
}

export interface MealPlansCreateResponse {
  body: MealPlansCreateResponseBody;
}

export type MealPlansCreateResponseBody = ErrorResponseBody | MealPlanCreateSuccessResponseBody;

export type MealPlansDestroyResponse = never;

export interface MealPlansIndexRequest {
  query: MealPlansIndexRequestQuery;
}

export interface MealPlansIndexRequestQuery {
  Page?: MealPlanPage;
}

export interface MealPlansIndexResponse {
  body: MealPlansIndexResponseBody;
}

export type MealPlansIndexResponseBody = ErrorResponseBody | MealPlanIndexSuccessResponseBody;

export interface MealPlansShowResponse {
  body: MealPlansShowResponseBody;
}

export type MealPlansShowResponseBody = ErrorResponseBody | MealPlanShowSuccessResponseBody;

export interface MealPlansUpdateRequest {
  body: MealPlansUpdateRequestBody;
}

export interface MealPlansUpdateRequestBody {
  MealPlan: MealPlanUpdatePayload;
}

export interface MealPlansUpdateResponse {
  body: MealPlansUpdateResponseBody;
}

export type MealPlansUpdateResponseBody = ErrorResponseBody | MealPlanUpdateSuccessResponseBody;

export interface OffsetPagination {
  Current: number;
  Items: number;
  Next?: null | number;
  Prev?: null | number;
  Total: number;
}