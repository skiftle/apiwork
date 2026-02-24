export interface NotificationsCreateRequest {
  body: NotificationsCreateRequestBody;
}

export interface NotificationsCreateRequestBody {
  preference: { address: string; digest: boolean } | { deviceToken: string; silent: boolean } | { phoneNumber: string };
}

export interface NotificationsCreateResponse {
  body: NotificationsCreateResponseBody;
}

export type NotificationsCreateResponseBody = { preference: { address: string; digest: boolean } | { deviceToken: string; silent: boolean } | { phoneNumber: string } };

export interface NotificationsIndexResponse {
  body: NotificationsIndexResponseBody;
}

export type NotificationsIndexResponseBody = { preference: { address: string; digest: boolean } | { deviceToken: string; silent: boolean } | { phoneNumber: string } };