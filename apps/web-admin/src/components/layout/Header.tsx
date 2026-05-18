import { Bell } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useAuth } from '@/hooks/useAuth'
import { useLocation } from 'react-router-dom'

const pageTitles: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/dashboard/users': 'Users',
  '/dashboard/drivers': 'Drivers',
  '/dashboard/merchants': 'Merchants',
  '/dashboard/rides': 'Rides',
  '/dashboard/orders': 'Orders',
  '/dashboard/payments': 'Payments',
}

export default function Header() {
  const { logout, currentUser } = useAuth()
  const location = useLocation()
  const title = pageTitles[location.pathname] ?? 'Dashboard'

  const initials = currentUser?.name
    ? currentUser.name
        .split(' ')
        .map((n: string) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    : 'AD'

  return (
    <header className="flex items-center justify-between h-16 px-6 border-b bg-card">
      <h1 className="text-xl font-semibold">{title}</h1>

      <div className="flex items-center gap-3">
        {/* Notification bell */}
        <Button variant="ghost" size="icon" aria-label="Notifications">
          <Bell className="h-5 w-5" />
        </Button>

        {/* Avatar dropdown */}
        <div className="relative group">
          <button
            className="flex items-center gap-2 rounded-full focus:outline-none focus:ring-2 focus:ring-ring"
            aria-label="User menu"
          >
            <span className="flex items-center justify-center w-9 h-9 rounded-full bg-primary text-primary-foreground text-sm font-semibold">
              {initials}
            </span>
          </button>

          {/* Dropdown */}
          <div className="absolute right-0 mt-2 w-48 rounded-md border bg-popover shadow-md opacity-0 invisible group-focus-within:opacity-100 group-focus-within:visible transition-all z-50">
            <div className="px-4 py-3 border-b">
              <p className="text-sm font-medium truncate">{currentUser?.name ?? 'Admin'}</p>
              <p className="text-xs text-muted-foreground truncate">{currentUser?.email ?? ''}</p>
            </div>
            <div className="py-1">
              <button
                className="w-full text-left px-4 py-2 text-sm hover:bg-accent transition-colors"
                onClick={() => {}}
              >
                Profile
              </button>
              <button
                className="w-full text-left px-4 py-2 text-sm text-destructive hover:bg-accent transition-colors"
                onClick={logout}
              >
                Sign out
              </button>
            </div>
          </div>
        </div>
      </div>
    </header>
  )
}
