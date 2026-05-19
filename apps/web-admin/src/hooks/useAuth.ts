import { useMutation } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import api from '@/lib/axios'
import type { LoginRequest, LoginResponse } from '@/types/auth'

const ALLOWED_ADMIN_ROLES = ['ADMIN', 'SUPER_ADMIN']

export function useAuth() {
  const navigate = useNavigate()

  const loginMutation = useMutation({
    mutationFn: async (credentials: LoginRequest): Promise<LoginResponse> => {
      const { data } = await api.post<LoginResponse>('/auth/admin/login', credentials)
      return data
    },
    onSuccess: (data) => {
      const role = data.user?.role
      if (!role || !ALLOWED_ADMIN_ROLES.includes(role)) {
        // Reject non-admin users
        throw new Error('Account does not have admin access')
      }
      localStorage.setItem('access_token', data.tokens.access_token)
      localStorage.setItem('refresh_token', data.tokens.refresh_token)
      localStorage.setItem('user', JSON.stringify(data.user))
      navigate('/dashboard')
    },
  })

  const logout = () => {
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('user')
    navigate('/login')
  }

  const currentUser = (() => {
    try {
      const raw = localStorage.getItem('user')
      return raw ? JSON.parse(raw) : null
    } catch {
      return null
    }
  })()

  const isAuthenticated =
    !!localStorage.getItem('access_token') &&
    !!currentUser &&
    ALLOWED_ADMIN_ROLES.includes(currentUser.role)

  return {
    loginMutation,
    logout,
    isAuthenticated,
    currentUser,
  }
}
