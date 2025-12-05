export interface Issue {
  code: string;
  detail: string;
  field: string;
  path: string[];
}

export interface OrdersCreateRequest {
  body: OrdersCreateRequestBody;
}

export interface OrdersCreateRequestBody {
  shipping_address: { city: string; street: string };
}

export interface OrdersCreateResponse {
  body: OrdersCreateResponseBody;
}

export type OrdersCreateResponseBody = { id: number; status: string };