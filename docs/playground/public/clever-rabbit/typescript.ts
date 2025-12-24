export interface Error {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
}

export interface ErrorResponse {
  errors: Error[];
  layer: Layer;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface NullableStringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  null?: boolean;
  startsWith?: string;
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export interface Order {
  createdAt: string;
  id: string;
  lineItems: string[];
  orderNumber: string;
  shippingAddress: object;
  status: null | string;
  total: null | number;
  updatedAt: string;
}

export interface OrderCreatePayload {
  lineItems?: string[];
  orderNumber: string;
  shippingAddress?: object;
}

export interface OrderFilter {
  _and?: OrderFilter[];
  _not?: OrderFilter;
  _or?: OrderFilter[];
  status?: NullableStringFilter | string;
}

export interface OrderPage {
  number?: number;
  size?: number;
}

export interface OrderSort {
  createdAt?: SortDirection;
  status?: SortDirection;
}

export interface OrderUpdatePayload {
  lineItems?: string[];
  orderNumber?: string;
  shippingAddress?: object;
}

export interface OrdersCreateRequest {
  body: OrdersCreateRequestBody;
}

export interface OrdersCreateRequestBody {
  order: OrderCreatePayload;
}

export interface OrdersCreateResponse {
  body: OrdersCreateResponseBody;
}

export type OrdersCreateResponseBody = { errors?: Error[] } | { meta?: object; order: Order };

export type OrdersDestroyResponse = never;

export interface OrdersIndexRequest {
  query: OrdersIndexRequestQuery;
}

export interface OrdersIndexRequestQuery {
  filter?: OrderFilter | OrderFilter[];
  page?: OrderPage;
  sort?: OrderSort | OrderSort[];
}

export interface OrdersIndexResponse {
  body: OrdersIndexResponseBody;
}

export type OrdersIndexResponseBody = { errors?: Error[] } | { meta?: object; orders?: Order[]; pagination?: OffsetPagination };

export interface OrdersShowResponse {
  body: OrdersShowResponseBody;
}

export type OrdersShowResponseBody = { errors?: Error[] } | { meta?: object; order: Order };

export interface OrdersUpdateRequest {
  body: OrdersUpdateRequestBody;
}

export interface OrdersUpdateRequestBody {
  order: OrderUpdatePayload;
}

export interface OrdersUpdateResponse {
  body: OrdersUpdateResponseBody;
}

export type OrdersUpdateResponseBody = { errors?: Error[] } | { meta?: object; order: Order };

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}