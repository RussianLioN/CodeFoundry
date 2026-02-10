// ═════════════════════════════════════════════════════════════════════════════
// Shared Types - User
// ═══════════════════════════════════════════════════════════════════════════════

export interface User {
  id: string
  email: string
  username: string
  firstName?: string
  lastName?: string
  avatarUrl?: string
  createdAt: string
  updatedAt: string
}

export interface CreateUserDto {
  email: string
  username: string
  password: string
  firstName?: string
  lastName?: string
}

export interface UpdateUserDto {
  email?: string
  username?: string
  firstName?: string
  lastName?: string
  avatarUrl?: string
}

export interface LoginDto {
  email: string
  password: string
}

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  user: User
}

export interface UsersListParams {
  page?: number
  limit?: number
  search?: string
  sortBy?: 'createdAt' | 'username' | 'email'
  sortOrder?: 'asc' | 'desc'
}

export interface UsersListResponse {
  data: User[]
  total: number
  page: number
  limit: number
  totalPages: number
}
