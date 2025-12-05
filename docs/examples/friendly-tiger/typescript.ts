export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface OrderAddress {
  city: string;
  street: string;
}

export type OrderPriority = 'high' | 'low' | 'normal' | 'urgent';

export interface OrdersCreateRequest {
  body: OrdersCreateRequestBody;
}

export interface OrdersCreateRequestBody {
  priority: OrderPriority;
  shipping_address: OrderAddress;
}

export interface OrdersCreateResponse {
  body: OrdersCreateResponseBody;
}

export type OrdersCreateResponseBody = { id: number; status: string };