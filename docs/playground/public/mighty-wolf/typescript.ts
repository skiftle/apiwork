export interface Car {
  brand: string;
  color: null | string;
  doors: null | number;
  id: string;
  model: string;
  type: 'car';
  year: null | number;
}

export interface CarCreatePayload {
  brand: string;
  color?: null | string;
  doors?: null | number;
  model: string;
  type: 'car';
  year?: null | number;
}

export interface CarUpdatePayload {
  brand?: string;
  color?: null | string;
  doors?: null | number;
  model?: string;
  type?: 'car';
  year?: null | number;
}

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

export interface IntegerFilter {
  between?: IntegerFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
}

export interface IntegerFilterBetween {
  from?: number;
  to?: number;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface Motorcycle {
  brand: string;
  color: null | string;
  engineCc: null | number;
  id: string;
  model: string;
  type: 'motorcycle';
  year: null | number;
}

export interface MotorcycleCreatePayload {
  brand: string;
  color?: null | string;
  engineCc?: null | number;
  model: string;
  type: 'motorcycle';
  year?: null | number;
}

export interface MotorcycleUpdatePayload {
  brand?: string;
  color?: null | string;
  engineCc?: null | number;
  model?: string;
  type?: 'motorcycle';
  year?: null | number;
}

export interface NullableIntegerFilter {
  between?: IntegerFilterBetween;
  eq?: number;
  gt?: number;
  gte?: number;
  in?: number[];
  lt?: number;
  lte?: number;
  null?: boolean;
}

export interface OffsetPagination {
  current: number;
  items: number;
  next?: null | number;
  prev?: null | number;
  total: number;
}

export type SortDirection = 'asc' | 'desc';

export interface StringFilter {
  contains?: string;
  endsWith?: string;
  eq?: string;
  in?: string[];
  startsWith?: string;
}

export interface Truck {
  brand: string;
  color: null | string;
  id: string;
  model: string;
  payloadCapacity: null | number;
  type: 'truck';
  year: null | number;
}

export interface TruckCreatePayload {
  brand: string;
  color?: null | string;
  model: string;
  payloadCapacity?: null | number;
  type: 'truck';
  year?: null | number;
}

export interface TruckUpdatePayload {
  brand?: string;
  color?: null | string;
  model?: string;
  payloadCapacity?: null | number;
  type?: 'truck';
  year?: null | number;
}

export type Vehicle = { type: 'car' } & Car | { type: 'motorcycle' } & Motorcycle | { type: 'truck' } & Truck;

export type VehicleCreatePayload = { type: 'car' } & CarCreatePayload | { type: 'motorcycle' } & MotorcycleCreatePayload | { type: 'truck' } & TruckCreatePayload;

export interface VehicleFilter {
  _and?: VehicleFilter[];
  _not?: VehicleFilter;
  _or?: VehicleFilter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  year?: NullableIntegerFilter | number;
}

export interface VehiclePage {
  number?: number;
  size?: number;
}

export interface VehicleSort {
  year?: SortDirection;
}

export type VehicleUpdatePayload = { type: 'car' } & CarUpdatePayload | { type: 'motorcycle' } & MotorcycleUpdatePayload | { type: 'truck' } & TruckUpdatePayload;

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: VehicleCreatePayload;
}

export interface VehiclesCreateResponse {
  body: VehiclesCreateResponseBody;
}

export type VehiclesCreateResponseBody = { errors?: Error[] } | { meta?: object; vehicle: Vehicle };

export type VehiclesDestroyResponse = never;

export interface VehiclesIndexRequest {
  query: VehiclesIndexRequestQuery;
}

export interface VehiclesIndexRequestQuery {
  filter?: VehicleFilter | VehicleFilter[];
  page?: VehiclePage;
  sort?: VehicleSort | VehicleSort[];
}

export interface VehiclesIndexResponse {
  body: VehiclesIndexResponseBody;
}

export type VehiclesIndexResponseBody = { errors?: Error[] } | { meta?: object; pagination?: OffsetPagination; vehicles?: Vehicle[] };

export interface VehiclesShowResponse {
  body: VehiclesShowResponseBody;
}

export type VehiclesShowResponseBody = { errors?: Error[] } | { meta?: object; vehicle: Vehicle };

export interface VehiclesUpdateRequest {
  body: VehiclesUpdateRequestBody;
}

export interface VehiclesUpdateRequestBody {
  vehicle: VehicleUpdatePayload;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = { errors?: Error[] } | { meta?: object; vehicle: Vehicle };