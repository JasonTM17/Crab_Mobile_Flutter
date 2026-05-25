import { Suspense } from 'react'
import { NavLink, Outlet } from 'react-router-dom'
import Sidebar from './Sidebar'
import Header from './Header'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'
import { navItems } from './navItems'

function RouteFallback() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-8 w-64" />
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-28 w-full" />
        ))}
      </div>
      <Skeleton className="h-64 w-full" />
    </div>
  )
}

function MobileNav() {
  return (
    <nav className="md:hidden border-b bg-card px-3 py-2">
      <div className="grid grid-cols-3 gap-2">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/dashboard'}
            className={({ isActive }: { isActive: boolean }) =>
              cn(
                'flex min-w-0 items-center justify-center gap-1.5 rounded-full px-2 py-2 text-[11px] font-medium transition-colors',
                isActive
                  ? 'bg-primary text-primary-foreground'
                  : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
              )
            }
          >
            <Icon className="h-4 w-4" aria-hidden="true" />
            <span className="truncate">{label}</span>
          </NavLink>
        ))}
      </div>
    </nav>
  )
}

export default function MainLayout() {
  return (
    <div className="flex h-screen overflow-hidden bg-background">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        <Header />
        <MobileNav />
        <main className="flex-1 overflow-y-auto p-3 sm:p-4 md:p-6">
          <Suspense fallback={<RouteFallback />}>
            <Outlet />
          </Suspense>
        </main>
      </div>
    </div>
  )
}
