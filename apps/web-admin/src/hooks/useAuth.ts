import { useMutation } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import api from '@/lib/axios'
import type { LoginRequest, LoginResponse } from '@/types/auth'

export function useAuth() {
  const navigate = useNavigate()

  const loginMutation = useMutation({
    mutationFn: async (credentials: LoginRequest): Promise<LoginResponse> => {
      const { data } = await api.post<LoginResponse>('/auth/admin/login', credentials)
      return data
    },
    onSuccess: (data) => {
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

  const isAuthenticated = !!localStorage.getItem('access_token')

  const currentUser = (() => {
    try {
      const raw = localStorage.getItem('user')
      return raw ? JSON.parse(raw) : null
    } catch {
      return null
    }
  })()

  return {
    loginMutation,
    logout,
    isAuthenticated,
    currentUser,
  }
}
