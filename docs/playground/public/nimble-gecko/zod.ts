import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const CookingStepSchema = z.object({
  DurationMinutes: z.number().int().nullable(),
  Id: z.string(),
  Instruction: z.string(),
  StepNumber: z.number().int()
});

export const CookingStepNestedCreatePayloadSchema = z.object({
  OP: z.literal('create').optional(),
  DurationMinutes: z.number().int().nullable().optional(),
  Instruction: z.string(),
  StepNumber: z.number().int()
});

export const CookingStepNestedDeletePayloadSchema = z.object({
  OP: z.literal('delete').optional(),
  Id: z.string()
});

export const CookingStepNestedUpdatePayloadSchema = z.object({
  OP: z.literal('update').optional(),
  DurationMinutes: z.number().int().nullable().optional(),
  Id: z.string().optional(),
  Instruction: z.string().optional(),
  StepNumber: z.number().int().optional()
});

export const IssueSchema = z.object({
  Code: z.string(),
  Detail: z.string(),
  Meta: z.record(z.string(), z.unknown()),
  Path: z.array(z.string()),
  Pointer: z.string()
});

export const MealPlanPageSchema = z.object({
  Number: z.number().int().min(1).optional(),
  Size: z.number().int().min(1).max(100).optional()
});

export const OffsetPaginationSchema = z.object({
  Current: z.number().int(),
  Items: z.number().int(),
  Next: z.number().int().nullable().optional(),
  Prev: z.number().int().nullable().optional(),
  Total: z.number().int()
});

export const CookingStepNestedPayloadSchema = z.discriminatedUnion('OP', [
  CookingStepNestedCreatePayloadSchema,
  CookingStepNestedUpdatePayloadSchema,
  CookingStepNestedDeletePayloadSchema
]);

export const ErrorSchema = z.object({
  Issues: z.array(IssueSchema),
  Layer: LayerSchema
});

export const MealPlanSchema = z.object({
  CookTime: z.number().int().nullable(),
  CookingSteps: z.array(CookingStepSchema),
  CreatedAt: z.iso.datetime(),
  Id: z.string(),
  ServingSize: z.number().int().nullable(),
  Title: z.string(),
  UpdatedAt: z.iso.datetime()
});

export const ErrorResponseBodySchema = ErrorSchema;

export const MealPlanCreatePayloadSchema = z.object({
  CookTime: z.number().int().nullable().optional(),
  CookingSteps: z.array(CookingStepNestedPayloadSchema).optional(),
  ServingSize: z.number().int().nullable().optional(),
  Title: z.string()
});

export const MealPlanCreateSuccessResponseBodySchema = z.object({
  MealPlan: MealPlanSchema,
  Meta: z.record(z.string(), z.unknown()).optional()
});

export const MealPlanIndexSuccessResponseBodySchema = z.object({
  MealPlans: z.array(MealPlanSchema),
  Meta: z.record(z.string(), z.unknown()).optional(),
  Pagination: OffsetPaginationSchema
});

export const MealPlanShowSuccessResponseBodySchema = z.object({
  MealPlan: MealPlanSchema,
  Meta: z.record(z.string(), z.unknown()).optional()
});

export const MealPlanUpdatePayloadSchema = z.object({
  CookTime: z.number().int().nullable().optional(),
  CookingSteps: z.array(CookingStepNestedPayloadSchema).optional(),
  ServingSize: z.number().int().nullable().optional(),
  Title: z.string().optional()
});

export const MealPlanUpdateSuccessResponseBodySchema = z.object({
  MealPlan: MealPlanSchema,
  Meta: z.record(z.string(), z.unknown()).optional()
});

export const MealPlansIndexRequestQuerySchema = z.object({
  Page: MealPlanPageSchema.optional()
});

export const MealPlansIndexRequestSchema = z.object({
  query: MealPlansIndexRequestQuerySchema
});

export const MealPlansIndexResponseBodySchema = z.union([MealPlanIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const MealPlansIndexResponseSchema = z.object({
  body: MealPlansIndexResponseBodySchema
});

export const MealPlansShowResponseBodySchema = z.union([MealPlanShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const MealPlansShowResponseSchema = z.object({
  body: MealPlansShowResponseBodySchema
});

export const MealPlansCreateRequestBodySchema = z.object({
  MealPlan: MealPlanCreatePayloadSchema
});

export const MealPlansCreateRequestSchema = z.object({
  body: MealPlansCreateRequestBodySchema
});

export const MealPlansCreateResponseBodySchema = z.union([MealPlanCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const MealPlansCreateResponseSchema = z.object({
  body: MealPlansCreateResponseBodySchema
});

export const MealPlansUpdateRequestBodySchema = z.object({
  MealPlan: MealPlanUpdatePayloadSchema
});

export const MealPlansUpdateRequestSchema = z.object({
  body: MealPlansUpdateRequestBodySchema
});

export const MealPlansUpdateResponseBodySchema = z.union([MealPlanUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const MealPlansUpdateResponseSchema = z.object({
  body: MealPlansUpdateResponseBodySchema
});

export const MealPlansDestroyResponseSchema = z.never();

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
