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

export interface LineItem {
  id: string;
  productName: string;
  quantity: null | number;
  unitPrice: null | number;
}

export interface LineItemNestedCreatePayload {
  OP?: 'create';
  productName: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

export interface LineItemNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type LineItemNestedPayload = LineItemNestedCreatePayload | LineItemNestedUpdatePayload | LineItemNestedDeletePayload;

export interface LineItemNestedUpdatePayload {
  OP?: 'update';
  id?: string;
  productName?: string;
  quantity?: null | number;
  unitPrice?: null | number;
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
  lineItems: LineItem[];
  orderNumber: string;
  shippingAddress: ShippingAddress;
  status: null | string;
  total: null | number;
  updatedAt: string;
}

export interface OrderCreatePayload {
  lineItems?: LineItemNestedPayload[];
  orderNumber: string;
  shippingAddress?: ShippingAddressNestedPayload;
}

export interface OrderCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
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
  lineItems?: LineItemNestedPayload[];
  orderNumber?: string;
  shippingAddress?: ShippingAddressNestedPayload;
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

export interface ShippingAddress {
  city: string;
  country: string;
  id: string;
  postalCode: string;
  street: string;
}

export interface ShippingAddressNestedCreatePayload {
  OP?: 'create';
  city: string;
  country: string;
  postalCode: string;
  street: string;
}

export interface ShippingAddressNestedDeletePayload {
  OP?: 'delete';
  id: string;
}

export type ShippingAddressNestedPayload = ShippingAddressNestedCreatePayload | ShippingAddressNestedUpdatePayload | ShippingAddressNestedDeletePayload;

export interface ShippingAddressNestedUpdatePayload {
  OP?: 'update';
  city?: string;
  country?: string;
  id?: string;
  postalCode?: string;
  street?: string;
}