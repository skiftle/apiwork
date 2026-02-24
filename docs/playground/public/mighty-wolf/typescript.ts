export interface Car {
  brand: string;
  color: null | string;
  createdAt: string;
  doors: null | number;
  id: string;
  model: string;
  type: string;
  updatedAt: string;
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
  issues: Issue[];
  layer: Layer;
}

export type ErrorResponseBody = Error;

export interface IntegerFilterBetween {
  from?: number;
  to?: number;
}

export interface Issue {
  code: string;
  detail: string;
  meta: Record<string, unknown>;
  path: string[];
  pointer: string;
}

export type Layer = 'contract' | 'domain' | 'http';

export interface Motorcycle {
  brand: string;
  color: null | string;
  createdAt: string;
  engineCc: null | number;
  id: string;
  model: string;
  type: string;
  updatedAt: string;
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
  createdAt: string;
  id: string;
  model: string;
  payloadCapacity: null | number;
  type: string;
  updatedAt: string;
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

export type Vehicle = Car | Motorcycle | Truck;

export interface VehicleCreateSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehicleFilter {
  AND?: VehicleFilter[];
  NOT?: VehicleFilter;
  OR?: VehicleFilter[];
  brand?: StringFilter | string;
  model?: StringFilter | string;
  type?: VehicleTypeFilter;
  year?: NullableIntegerFilter | number;
}

export interface VehicleIndexSuccessResponseBody {
  meta?: Record<string, unknown>;
  pagination: OffsetPagination;
  vehicles: Vehicle[];
}

export interface VehiclePage {
  number?: number;
  size?: number;
}

export interface VehicleShowSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehicleSort {
  year?: SortDirection;
}

export type VehicleType = 'car' | 'motorcycle' | 'truck';

export type VehicleTypeFilter = VehicleType | { eq?: VehicleType; in?: VehicleType[] };

export interface VehicleUpdateSuccessResponseBody {
  meta?: Record<string, unknown>;
  vehicle: Vehicle;
}

export interface VehiclesCreateRequest {
  body: VehiclesCreateRequestBody;
}

export interface VehiclesCreateRequestBody {
  vehicle: CarCreatePayload | MotorcycleCreatePayload | TruckCreatePayload;
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
  vehicle: CarUpdatePayload | MotorcycleUpdatePayload | TruckUpdatePayload;
}

export interface VehiclesUpdateResponse {
  body: VehiclesUpdateResponseBody;
}

export type VehiclesUpdateResponseBody = ErrorResponseBody | VehicleUpdateSuccessResponseBody;