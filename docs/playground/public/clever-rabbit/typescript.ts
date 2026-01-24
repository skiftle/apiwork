export interface ErrorResponseBody {
  issues: Issue[];
  layer: Layer;
}

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
  lineItems: LineItem[];
  orderNumber: string;
  shippingAddress: ShippingAddress;
  status: null | string;
  total: null | number;
  updatedAt: string;
}

export interface OrderCreatePayload {
  lineItems?: OrderLineItemNestedPayload[];
  orderNumber: string;
  shippingAddress?: OrderShippingAddressNestedPayload;
}

export interface OrderCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderFilter {
  _and?: OrderFilter[];
  _not?: OrderFilter;
  _or?: OrderFilter[];
  status?: NullableStringFilter | string;
}

export interface OrderIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  orders: Order[];
  pagination: OffsetPagination;
}

export interface OrderLineItemNestedCreatePayload {
  _op?: 'create';
  id?: string;
  productName: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

export interface OrderLineItemNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type OrderLineItemNestedPayload = OrderLineItemNestedCreatePayload | OrderLineItemNestedUpdatePayload | OrderLineItemNestedDeletePayload;

export interface OrderLineItemNestedUpdatePayload {
  _op?: 'update';
  id?: string;
  productName?: string;
  quantity?: null | number;
  unitPrice?: null | number;
}

export interface OrderPage {
  number?: number;
  size?: number;
}

export interface OrderShippingAddressNestedCreatePayload {
  _op?: 'create';
  city: string;
  country: string;
  id?: string;
  postalCode: string;
  street: string;
}

export interface OrderShippingAddressNestedDeletePayload {
  _op?: 'delete';
  id: string;
}

export type OrderShippingAddressNestedPayload = OrderShippingAddressNestedCreatePayload | OrderShippingAddressNestedUpdatePayload | OrderShippingAddressNestedDeletePayload;

export interface OrderShippingAddressNestedUpdatePayload {
  _op?: 'update';
  city?: string;
  country?: string;
  id?: string;
  postalCode?: string;
  street?: string;
}

export interface OrderShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  order: Order;
}

export interface OrderSort {
  createdAt?: SortDirection;
  status?: SortDirection;
}

export interface OrderUpdatePayload {
  lineItems?: OrderLineItemNestedPayload[];
  orderNumber?: string;
  shippingAddress?: OrderShippingAddressNestedPayload;
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
  sort?: OrderSort | OrderSort[];
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

export type SortDirection = 'asc' | 'desc';