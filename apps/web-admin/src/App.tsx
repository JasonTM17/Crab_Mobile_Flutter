import { Navigate, Route, Routes } from 'react-router-dom'
import MainLayout from '@/components/layout/MainLayout'
import Login from '@/pages/Login'
import Dashboard from '@/pages/Dashboard'
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
        {/* Placeholder routes — pages added in later tasks */}
        <Route path="users" element={<div className="p-4 text-muted-foreground">Users — coming soon</div>} />
        <Route path="drivers" element={<div className="p-4 text-muted-foreground">Drivers — coming soon</div>} />
        <Route path="merchants" element={<div className="p-4 text-muted-foreground">Merchants — coming soon</div>} />
        <Route path="rides" element={<div className="p-4 text-muted-foreground">Rides — coming soon</div>} />
        <Route path="orders" element={<div className="p-4 text-muted-foreground">Orders — coming soon</div>} />
        <Route path="payments" element={<div className="p-4 text-muted-foreground">Payments — coming soon</div>} />
      </Route>
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  )
}
