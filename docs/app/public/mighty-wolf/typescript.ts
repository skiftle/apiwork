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
  field: string;
  path: string[];
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

export interface PagePagination {
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

export type Vehicle = VehicleCar | VehicleMotorcycle | VehicleTruck;

export interface VehicleCar {
  brand?: string;
  color?: string;
  doors?: number;
  id?: unknown;
  model?: string;
  type: 'car';
  year?: number;
}

export interface VehicleCarCreatePayload {
  brand: string;
  color?: null | string;
  doors?: null | number;
  model: string;
  type: 'car';
  year?: null | number;
}

export interface VehicleCarUpdatePayload {
  brand?: string;
  color?: null | string;
  doors?: null | number;
  model?: string;
  type?: 'car';
  year?: null | number;
}

export type VehicleCreatePayload = VehicleCarCreatePayload | VehicleMotorcycleCreatePayload | VehicleTruckCreatePayload;

export interface VehicleFilter {
  _and?: VehicleFilter[];
  _not?: VehicleFilter;
  _or?: VehicleFilter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  year?: NullableIntegerFilter | number;
}

export type VehicleInclude = object;

export interface VehicleMotorcycle {
  brand?: string;
  color?: string;
  engineCc?: number;
  id?: unknown;
  model?: string;
  type: 'motorcycle';
  year?: number;
}

export interface VehicleMotorcycleCreatePayload {
  brand: string;
  color?: null | string;
  engineCc?: null | number;
  model: string;
  type: 'motorcycle';
  year?: null | number;
}

export interface VehicleMotorcycleUpdatePayload {
  brand?: string;
  color?: null | string;
  engineCc?: null | number;
  model?: string;
  type?: 'motorcycle';
  year?: null | number;
}

export interface VehiclePage {
  number?: number;
  size?: number;
}

export interface VehicleSort {
  year?: unknown;
}

export interface VehicleTruck {
  brand?: string;
  color?: string;
  id?: unknown;
  model?: string;
  payloadCapacity?: number;
  type: 'truck';
  year?: number;
}

export interface VehicleTruckCreatePayload {
  brand: string;
  color?: null | string;
  model: string;
  payloadCapacity?: null | number;
  type: 'truck';
  year?: null | number;
}

export interface VehicleTruckUpdatePayload {
  brand?: string;
  color?: null | string;
  model?: string;
  payloadCapacity?: null | number;
  type?: 'truck';
  year?: null | number;
}

export type VehicleUpdatePayload = VehicleCarUpdatePayload | VehicleMotorcycleUpdatePayload | VehicleTruckUpdatePayload;

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: VehicleCreatePayload;
}

export interface VehiclesCreateResponse {
  body: VehiclesCreateResponseBody;
}

export type VehiclesCreateResponseBody = { issues?: Issue[] } | { meta?: object; vehicle: Vehicle };

export interface VehiclesIndexRequest {
  query: VehiclesIndexRequestQuery;
}

export interface VehiclesIndexRequestQuery {
  filter?: VehicleFilter | VehicleFilter[];
  include?: VehicleInclude;
  page?: VehiclePage;
  sort?: VehicleSort | VehicleSort[];
}

export interface VehiclesIndexResponse {
  body: VehiclesIndexResponseBody;
}

export type VehiclesIndexResponseBody = { issues?: Issue[] } | { meta?: object; pagination?: PagePagination; vehicles?: Vehicle[] };

export interface VehiclesShowResponse {
  body: VehiclesShowResponseBody;
}

export type VehiclesShowResponseBody = { issues?: Issue[] } | { meta?: object; vehicle: Vehicle };

export interface VehiclesUpdateRequest {
  body: VehiclesUpdateRequestBody;
}

export interface VehiclesUpdateRequestBody {
  vehicle: VehicleUpdatePayload;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = { issues?: Issue[] } | { meta?: object; vehicle: Vehicle };