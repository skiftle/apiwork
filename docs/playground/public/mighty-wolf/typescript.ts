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
  type: 'car';
  year?: null | number;
}

export interface ErrorResponseBody {
  issues: Issue[];
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

export interface Issue {
  code: string;
  detail: string;
  meta: object;
  path: string[];
  pointer: string;
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
  type: 'motorcycle';
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
  type: 'truck';
  year?: null | number;
}

export type Vehicle = Car | Motorcycle | Truck;

export type VehicleCreatePayload = CarCreatePayload | MotorcycleCreatePayload | TruckCreatePayload;

export interface VehicleCreateSuccessResponseBody {
  meta?: object;
  vehicle: Vehicle;
}

export interface VehicleFilter {
  _and?: VehicleFilter[];
  _not?: VehicleFilter;
  _or?: VehicleFilter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  year?: NullableIntegerFilter | number;
}

export interface VehicleIndexSuccessResponseBody {
  meta?: object;
  pagination: OffsetPagination;
  vehicles: Vehicle[];
}

export interface VehiclePage {
  number?: number;
  size?: number;
}

export interface VehicleShowSuccessResponseBody {
  meta?: object;
  vehicle: Vehicle;
}

export interface VehicleSort {
  year?: SortDirection;
}

export type VehicleUpdatePayload = CarUpdatePayload | MotorcycleUpdatePayload | TruckUpdatePayload;

export interface VehicleUpdateSuccessResponseBody {
  meta?: object;
  vehicle: Vehicle;
}

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: VehicleCreatePayload;
}

export interface VehiclesCreateResponse {
  body: VehiclesCreateResponseBody;
}

export type VehiclesCreateResponseBody = ErrorResponseBody | VehicleCreateSuccessResponseBody;

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

export type VehiclesIndexResponseBody = ErrorResponseBody | VehicleIndexSuccessResponseBody;

export interface VehiclesShowResponse {
  body: VehiclesShowResponseBody;
}

export type VehiclesShowResponseBody = ErrorResponseBody | VehicleShowSuccessResponseBody;

export interface VehiclesUpdateRequest {
  body: VehiclesUpdateRequestBody;
}

export interface VehiclesUpdateRequestBody {
  vehicle: VehicleUpdatePayload;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = ErrorResponseBody | VehicleUpdateSuccessResponseBody;