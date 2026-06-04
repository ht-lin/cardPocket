export interface RegisterRequest {
  email: string;
  password: string;
  userName: string;
  gdprConsent: boolean;
}

export interface RegisterResponse {
  id: string;
  email: string;
  userName: string;
  emailVerified: boolean;
  createdAt: string;
}

export interface ApiViolation {
  propertyPath: string;
  message: string;
}

export interface ApiValidationError {
  violations: ApiViolation[];
}

export interface ResendVerificationRequest {
  email: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}
