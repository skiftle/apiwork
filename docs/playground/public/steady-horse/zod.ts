import { z } from 'zod';

export const LayerSchema = z.enum(['contract', 'domain', 'http']);

export const SortDirectionSchema = z.enum(['asc', 'desc']);

export const ProductFilterSchema: z.ZodType<ProductFilter> = z.lazy(() => z.object({
  AND: z.array(ProductFilterSchema).optional(),
  NOT: ProductFilterSchema.optional(),
  OR: z.array(ProductFilterSchema).optional(),
  category: z.union([z.string(), StringFilterSchema]).optional(),
  name: z.union([z.string(), StringFilterSchema]).optional()
}));

export const IssueSchema = z.object({
  code: z.string(),
  detail: z.string(),
  meta: z.record(z.string(), z.unknown()),
  path: z.array(z.string()),
  pointer: z.string()
});

export const OffsetPaginationSchema = z.object({
  current: z.number().int(),
  items: z.number().int(),
  next: z.number().int().nullable().optional(),
  prev: z.number().int().nullable().optional(),
  total: z.number().int()
});

export const ProductSchema = z.object({
  category: z.string(),
  createdAt: z.iso.datetime(),
  id: z.string(),
  name: z.string(),
  price: z.number(),
  updatedAt: z.iso.datetime()
});

export const ProductCreatePayloadSchema = z.object({
  category: z.string(),
  name: z.string(),
  price: z.number()
});

export const ProductPageSchema = z.object({
  number: z.number().int().min(1).optional(),
  size: z.number().int().min(1).max(100).optional()
});

export const ProductSortSchema = z.object({
  createdAt: SortDirectionSchema.optional(),
  price: SortDirectionSchema.optional(),
  updatedAt: SortDirectionSchema.optional()
});

export const ProductUpdatePayloadSchema = z.object({
  category: z.string().optional(),
  name: z.string().optional(),
  price: z.number().optional()
});

export const StringFilterSchema = z.object({
  contains: z.string().optional(),
  endsWith: z.string().optional(),
  eq: z.string().optional(),
  in: z.array(z.string()).optional(),
  startsWith: z.string().optional()
});

export const ErrorSchema = z.object({
  issues: z.array(IssueSchema),
  layer: LayerSchema
});

export const ProductCreateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  product: ProductSchema
});

export const ProductIndexSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  pagination: OffsetPaginationSchema,
  products: z.array(ProductSchema)
});

export const ProductShowSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  product: ProductSchema
});

export const ProductUpdateSuccessResponseBodySchema = z.object({
  meta: z.record(z.string(), z.unknown()).optional(),
  product: ProductSchema
});

export const ErrorResponseBodySchema = ErrorSchema;

export const ProductsIndexRequestQuerySchema = z.object({
  filter: z.union([ProductFilterSchema, z.array(ProductFilterSchema)]).optional(),
  page: ProductPageSchema.optional(),
  sort: z.union([ProductSortSchema, z.array(ProductSortSchema)]).optional()
});

export const ProductsIndexRequestSchema = z.object({
  query: ProductsIndexRequestQuerySchema
});

export const ProductsIndexResponseBodySchema = z.union([ProductIndexSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProductsIndexResponseSchema = z.object({
  body: ProductsIndexResponseBodySchema
});

export const ProductsShowResponseBodySchema = z.union([ProductShowSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProductsShowResponseSchema = z.object({
  body: ProductsShowResponseBodySchema
});

export const ProductsCreateRequestBodySchema = z.object({
  product: ProductCreatePayloadSchema
});

export const ProductsCreateRequestSchema = z.object({
  body: ProductsCreateRequestBodySchema
});

export const ProductsCreateResponseBodySchema = z.union([ProductCreateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProductsCreateResponseSchema = z.object({
  body: ProductsCreateResponseBodySchema
});

export const ProductsUpdateRequestBodySchema = z.object({
  product: ProductUpdatePayloadSchema
});

export const ProductsUpdateRequestSchema = z.object({
  body: ProductsUpdateRequestBodySchema
});

export const ProductsUpdateResponseBodySchema = z.union([ProductUpdateSuccessResponseBodySchema, ErrorResponseBodySchema]);

export const ProductsUpdateResponseSchema = z.object({
  body: ProductsUpdateResponseBodySchema
});

export const ProductsDestroyResponseSchema = z.never();

export interface Error {
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

export interface Issue {
  code: string;
  detail: string;
  meta: Record<string, unknown>;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Product {
  category: string;
  createdAt: string;
  id: string;
  name: string;
  price: number;
  updatedAt: string;
}

export interface ProductCreatePayload {
  category: string;
  name: string;
  price: number;
}

export interface ProductCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  product: Product;
}

export interface ProductFilter {
  AND?: ProductFilter[];
  NOT?: ProductFilter;
  OR?: ProductFilter[];
  category?: StringFilter | string;
  name?: StringFilter | string;
}

export interface ProductIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  products: Product[];
}

export interface ProductPage {
  number?: number;
  size?: number;
}

export interface ProductShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  product: Product;
}

export interface ProductSort {
  createdAt?: SortDirection;
  price?: SortDirection;
  updatedAt?: SortDirection;
}

export interface ProductUpdatePayload {
  category?: string;
  name?: string;
  price?: number;
}

export interface ProductUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  product: Product;
}

export interface ProductsCreateRequest {
  body: ProductsCreateRequestBody;
}

export interface ProductsCreateRequestBody {
  product: ProductCreatePayload;
}

export interface ProductsCreateResponse {
  body: ProductsCreateResponseBody;
}

export type ProductsCreateResponseBody = ErrorResponseBody | ProductCreateSuccessResponseBody;

export type ProductsDestroyResponse = never;

export interface ProductsIndexRequest {
  query: ProductsIndexRequestQuery;
}

export interface ProductsIndexRequestQuery {
  filter?: ProductFilter | ProductFilter[];
  page?: ProductPage;
  sort?: ProductSort | ProductSort[];
}

export interface ProductsIndexResponse {
  body: ProductsIndexResponseBody;
}

export type ProductsIndexResponseBody = ErrorResponseBody | ProductIndexSuccessResponseBody;

export interface ProductsShowResponse {
  body: ProductsShowResponseBody;
}

export type ProductsShowResponseBody = ErrorResponseBody | ProductShowSuccessResponseBody;

export interface ProductsUpdateRequest {
  body: ProductsUpdateRequestBody;
}

export interface ProductsUpdateRequestBody {
  product: ProductUpdatePayload;
}

export interface ProductsUpdateResponse {
  body: ProductsUpdateResponseBody;
}

export type ProductsUpdateResponseBody = ErrorResponseBody | ProductUpdateSuccessResponseBody;

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}
