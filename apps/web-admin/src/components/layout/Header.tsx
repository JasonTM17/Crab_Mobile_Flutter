import { Bell } from 'lucide-react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import { useAuth } from '@/hooks/useAuth'

const pageTitles: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/dashboard/users': 'Users',
  '/dashboard/drivers': 'Drivers',
  '/dashboard/merchants': 'Merchants',
  '/dashboard/restaurants': 'Restaurants',
  '/dashboard/rides': 'Rides',
  '/dashboard/orders': 'Orders',
  '/dashboard/promos': 'Promos',
  '/dashboard/notifications': 'Notifications',
  '/dashboard/payments': 'Payments',
}

export default function Header() {
  const { logout, currentUser } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()
  const title = pageTitles[location.pathname] ?? 'Dashboard'

  const fullName =
    currentUser?.name ??
    [currentUser?.firstName, currentUser?.lastName].filter(Boolean).join(' ') ??
    'Admin'
  const initials = fullName
    ? fullName
        .split(' ')
        .filter(Boolean)
        .map((n: string) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    : 'AD'

  return (
    <header className="flex h-14 items-center justify-between gap-3 border-b bg-card px-3 sm:px-4 md:h-16 md:px-6">
      <h1 className="min-w-0 truncate text-lg font-semibold md:text-xl">
        {title}
      </h1>

      <div className="flex shrink-0 items-center gap-2 sm:gap-3">
        <Tooltip>
          <TooltipTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              aria-label="Notifications"
              onClick={() => navigate('/dashboard/notifications')}
            >
              <Bell className="h-5 w-5" />
            </Button>
          </TooltipTrigger>
          <TooltipContent side="bottom">Open notifications</TooltipContent>
        </Tooltip>

        <DropdownMenu>
          <DropdownMenuTrigger
            className="flex items-center gap-2 rounded-full focus:outline-none focus:ring-2 focus:ring-ring"
            aria-label="User menu"
          >
            <span className="flex items-center justify-center w-9 h-9 rounded-full bg-primary text-primary-foreground text-sm font-semibold">
              {initials}
            </span>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>
              <div className="flex flex-col">
                <span className="truncate">{fullName}</span>
                <span className="text-xs font-normal text-muted-foreground truncate">
                  {currentUser?.email ?? ''}
                </span>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onSelect={logout}
              className="text-destructive focus:text-destructive"
            >
              Sign out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
