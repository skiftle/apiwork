export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

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
  createdAt?: string;
  id?: string;
  lineItems: string[];
  orderNumber?: string;
  shippingAddress: object;
  status?: string;
  total?: number;
  updatedAt?: string;
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

export type OrderInclude = object;

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
  query: OrdersCreateRequestQuery;
  body: OrdersCreateRequestBody;
}

export interface OrdersCreateRequestBody {
  order: OrderCreatePayload;
}

export interface OrdersCreateRequestQuery {
  include?: OrderInclude;
}

export interface OrdersCreateResponse {
  body: OrdersCreateResponseBody;
}

export type OrdersCreateResponseBody = { issues?: Issue[] } | { meta?: object; order: Order };

export interface OrdersDestroyRequest {
  query: OrdersDestroyRequestQuery;
}

export interface OrdersDestroyRequestQuery {
  include?: OrderInclude;
}

export type OrdersDestroyResponse = never;

export interface OrdersIndexRequest {
  query: OrdersIndexRequestQuery;
}

export interface OrdersIndexRequestQuery {
  filter?: OrderFilter | OrderFilter[];
  include?: OrderInclude;
  page?: OrderPage;
  sort?: OrderSort | OrderSort[];
}

export interface OrdersIndexResponse {
  body: OrdersIndexResponseBody;
}

export type OrdersIndexResponseBody = { issues?: Issue[] } | { meta?: object; orders?: Order[]; pagination?: OffsetPagination };

export interface OrdersShowRequest {
  query: OrdersShowRequestQuery;
}

export interface OrdersShowRequestQuery {
  include?: OrderInclude;
}

export interface OrdersShowResponse {
  body: OrdersShowResponseBody;
}

export type OrdersShowResponseBody = { issues?: Issue[] } | { meta?: object; order: Order };

export interface OrdersUpdateRequest {
  query: OrdersUpdateRequestQuery;
  body: OrdersUpdateRequestBody;
}

export interface OrdersUpdateRequestBody {
  order: OrderUpdatePayload;
}

export interface OrdersUpdateRequestQuery {
  include?: OrderInclude;
}

export interface OrdersUpdateResponse {
  body: OrdersUpdateResponseBody;
}

export type OrdersUpdateResponseBody = { issues?: Issue[] } | { meta?: object; order: Order };

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}