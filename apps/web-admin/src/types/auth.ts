export interface User {
  id: string
  email: string
  name: string
  role: 'admin' | 'super_admin'
  avatar?: string
}

export interface AuthTokens {
  access_token: string
  refresh_token: string
}

export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  user: User
  tokens: AuthTokens
}
