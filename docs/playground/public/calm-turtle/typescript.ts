export interface Customer {
  billingCity: null | string;
  billingCountry: null | string;
  billingStreet: null | string;
  createdAt: string;
  id: string;
  name: string;
  updatedAt: string;
}

export interface CustomerCreatePayload {
  billingCity?: null | string;
  billingCountry?: null | string;
  billingStreet?: null | string;
  name: string;
}

export interface CustomerCreateSuccessResponseBody {
  customer: Customer;
  meta?: Record<string, unknown>;
}

export interface CustomerFilter {
  AND?: CustomerFilter[];
  NOT?: CustomerFilter;
  OR?: CustomerFilter[];
  name?: StringFilter | string;
}

export interface CustomerIndexSuccessResponseBody {
  customers: Customer[];
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
}

export interface CustomerPage {
  number?: number;
  size?: number;
}

export interface CustomerShowSuccessResponseBody {
  customer: Customer;
  meta?: Record<string, unknown>;
}

export interface CustomerUpdatePayload {
  billingCity?: null | string;
  billingCountry?: null | string;
  billingStreet?: null | string;
  name?: string;
}

export interface CustomerUpdateSuccessResponseBody {
  customer: Customer;
  meta?: Record<string, unknown>;
}

export interface CustomersCreateRequest {
  body: CustomersCreateRequestBody;
}

export interface CustomersCreateRequestBody {
  customer: CustomerCreatePayload;
}

export interface CustomersCreateResponse {
  body: CustomersCreateResponseBody;
}

export type CustomersCreateResponseBody = CustomerCreateSuccessResponseBody | ErrorResponseBody;

export type CustomersDestroyResponse = never;

export interface CustomersIndexRequest {
  query: CustomersIndexRequestQuery;
}

export interface CustomersIndexRequestQuery {
  filter?: CustomerFilter | CustomerFilter[];
  page?: CustomerPage;
}

export interface CustomersIndexResponse {
  body: CustomersIndexResponseBody;
}

export type CustomersIndexResponseBody = CustomerIndexSuccessResponseBody | ErrorResponseBody;

export interface CustomersShowResponse {
  body: CustomersShowResponseBody;
}

export type CustomersShowResponseBody = CustomerShowSuccessResponseBody | ErrorResponseBody;

export interface CustomersUpdateRequest {
  body: CustomersUpdateRequestBody;
}

export interface CustomersUpdateRequestBody {
  customer: CustomerUpdatePayload;
}

export interface CustomersUpdateResponse {
  body: CustomersUpdateResponseBody;
}

export type CustomersUpdateResponseBody = CustomerUpdateSuccessResponseBody | ErrorResponseBody;

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

export interface Order {
  createdAt: string;
  customerId: string;
  id: string;
  orderNumber: string;
  shippingCity: null | string;
  shippingCountry: null | string;
  shippingStreet: null | string;
  updatedAt: string;
}

export interface OrderCreatePayload {
  customerId: string;
  orderNumber: string;
  shippingCity?: null | string;
  shippingCountry?: null | string;
  shippingStreet?: null | string;
}

export interface OrderCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderFilter {
  AND?: OrderFilter[];
  NOT?: OrderFilter;
  OR?: OrderFilter[];
  orderNumber?: StringFilter | string;
}

export interface OrderIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  orders: Order[];
  pagination: OffsetPagination;
}

export interface OrderPage {
  number?: number;
  size?: number;
}

export interface OrderShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderUpdatePayload {
  customerId?: string;
  orderNumber?: string;
  shippingCity?: null | string;
  shippingCountry?: null | string;
  shippingStreet?: null | string;
}

export interface OrderUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
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

export type OrdersCreateResponseBody = ErrorResponseBody | OrderCreateSuccessResponseBody;

export type OrdersDestroyResponse = never;

export interface OrdersIndexRequest {
  query: OrdersIndexRequestQuery;
}

export interface OrdersIndexRequestQuery {
  filter?: OrderFilter | OrderFilter[];
  page?: OrderPage;
}

export interface OrdersIndexResponse {
  body: OrdersIndexResponseBody;
}

export type OrdersIndexResponseBody = ErrorResponseBody | OrderIndexSuccessResponseBody;

export interface OrdersShowResponse {
  body: OrdersShowResponseBody;
}

export type OrdersShowResponseBody = ErrorResponseBody | OrderShowSuccessResponseBody;

export interface OrdersUpdateRequest {
  body: OrdersUpdateRequestBody;
}

export interface OrdersUpdateRequestBody {
  order: OrderUpdatePayload;
}

export interface OrdersUpdateResponse {
  body: OrdersUpdateResponseBody;
}

export type OrdersUpdateResponseBody = ErrorResponseBody | OrderUpdateSuccessResponseBody;

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}