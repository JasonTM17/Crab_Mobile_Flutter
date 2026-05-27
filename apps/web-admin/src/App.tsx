import { lazy, Suspense, type ReactNode } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import { Toaster } from 'sonner'
import { useAuth } from '@/hooks/useAuth'

const MainLayout = lazy(() => import('@/components/layout/MainLayout'))
const Login = lazy(() => import('@/pages/Login'))
const Dashboard = lazy(() => import('@/pages/Dashboard'))
const Users = lazy(() => import('@/pages/Users'))
const Drivers = lazy(() => import('@/pages/Drivers'))
const Rides = lazy(() => import('@/pages/Rides'))
const Restaurants = lazy(() => import('@/pages/Restaurants'))
const Orders = lazy(() => import('@/pages/Orders'))
const Promos = lazy(() => import('@/pages/Promos'))
const NotificationBroadcast = lazy(
  () => import('@/pages/NotificationBroadcast'),
)
const Payments = lazy(() => import('@/pages/Payments'))

function RouteFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 text-sm font-medium text-slate-600">
      Loading
    </div>
  )
}

function AuthGuard({ children }: { children: ReactNode }) {
  const { isAuthenticated } = useAuth()
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  return <>{children}</>
}

export default function App() {
  return (
    <>
      <Toaster position="top-right" richColors closeButton />
      <Suspense fallback={<RouteFallback />}>
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/login" element={<Login />} />
          <Route
            path="/dashboard"
            element={
              <AuthGuard>
                <MainLayout />
              </AuthGuard>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="users" element={<Users />} />
            <Route path="drivers" element={<Drivers />} />
            <Route path="merchants" element={<Restaurants />} />
            <Route path="restaurants" element={<Restaurants />} />
            <Route path="rides" element={<Rides />} />
            <Route path="orders" element={<Orders />} />
            <Route path="promos" element={<Promos />} />
            <Route path="notifications" element={<NotificationBroadcast />} />
            <Route path="payments" element={<Payments />} />
          </Route>
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </Suspense>
    </>
  )
}
