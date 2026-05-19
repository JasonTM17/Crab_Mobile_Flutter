import { Navigate, Route, Routes } from 'react-router-dom'
import { Toaster } from 'sonner'
import MainLayout from '@/components/layout/MainLayout'
import Login from '@/pages/Login'
import Dashboard from '@/pages/Dashboard'
import Users from '@/pages/Users'
import Drivers from '@/pages/Drivers'
import Rides from '@/pages/Rides'
import Restaurants from '@/pages/Restaurants'
import Orders from '@/pages/Orders'
import Promos from '@/pages/Promos'
import NotificationBroadcast from '@/pages/NotificationBroadcast'
import Payments from '@/pages/Payments'
import { useAuth } from '@/hooks/useAuth'

function AuthGuard({ children }: { children: React.ReactNode }) {
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
    </>
  )
}
