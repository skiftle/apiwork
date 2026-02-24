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