import { useState } from 'react'
import { NavLink, useNavigate } from 'react-router-dom'
import { cn } from '@/lib/utils'
import {
  LayoutDashboard,
  Users,
  Car,
  Store,
  MapPin,
  ShoppingBag,
  CreditCard,
  Ticket,
  Bell,
  ChevronLeft,
  ChevronRight,
  LogOut,
  User as UserIcon,
} from 'lucide-react'
import { Logo } from '@/components/ui/logo'
import { Badge } from '@/components/ui/badge'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { useAuth } from '@/hooks/useAuth'

const navItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/dashboard/users', icon: Users, label: 'Users' },
  { to: '/dashboard/drivers', icon: Car, label: 'Drivers' },
  { to: '/dashboard/merchants', icon: Store, label: 'Merchants' },
  { to: '/dashboard/rides', icon: MapPin, label: 'Rides' },
  { to: '/dashboard/orders', icon: ShoppingBag, label: 'Orders' },
  { to: '/dashboard/promos', icon: Ticket, label: 'Promos' },
  { to: '/dashboard/notifications', icon: Bell, label: 'Notifications' },
  { to: '/dashboard/payments', icon: CreditCard, label: 'Payments' },
]

export default function Sidebar() {
  const [collapsed, setCollapsed] = useState(false)
  const navigate = useNavigate()
  const { logout, currentUser } = useAuth()

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
  const role = currentUser?.role ?? 'ADMIN'

  return (
    <aside
      className={cn(
        'relative flex flex-col bg-card border-r transition-all duration-300',
        collapsed ? 'w-16' : 'w-64',
      )}
    >
      {/* Logo */}
      <div className="flex items-center h-16 px-4 border-b overflow-hidden">
        <Logo size="md" showText={!collapsed} />
      </div>

      {/* Nav */}
      <nav className="flex-1 py-4 space-y-1 overflow-hidden">
        {navItems.map(({ to, icon: Icon, label }) => {
          const link = (
            <NavLink
              key={to}
              to={to}
              end={to === '/dashboard'}
              className={({ isActive }: { isActive: boolean }) =>
                cn(
                  'flex items-center gap-3 px-4 py-2.5 text-sm font-medium rounded-md mx-2 transition-colors',
                  isActive
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
                )
              }
            >
              <Icon className="h-5 w-5 shrink-0" aria-hidden="true" />
              {!collapsed && <span className="whitespace-nowrap">{label}</span>}
            </NavLink>
          )
          if (!collapsed) return link
          return (
            <Tooltip key={to}>
              <TooltipTrigger asChild>{link}</TooltipTrigger>
              <TooltipContent side="right">{label}</TooltipContent>
            </Tooltip>
          )
        })}
      </nav>

      {/* User footer */}
      <div className="border-t p-3">
        <DropdownMenu>
          <DropdownMenuTrigger
            className={cn(
              'flex w-full items-center gap-2 rounded-md p-2 text-left transition-colors hover:bg-accent focus:outline-none focus:ring-2 focus:ring-ring',
              collapsed && 'justify-center',
            )}
          >
            <span className="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground text-xs font-semibold shrink-0">
              {initials}
            </span>
            {!collapsed && (
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{fullName}</p>
                <Badge variant="success" className="mt-0.5 text-[10px]">
                  {role}
                </Badge>
              </div>
            )}
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" side="top" className="w-56">
            <DropdownMenuLabel>
              <div className="flex flex-col">
                <span className="truncate">{fullName}</span>
                <span className="text-xs font-normal text-muted-foreground truncate">
                  {currentUser?.email ?? ''}
                </span>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem onSelect={() => navigate('/dashboard')}>
              <UserIcon className="h-4 w-4" />
              <span>Profile</span>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onSelect={logout}
              className="text-destructive focus:text-destructive"
            >
              <LogOut className="h-4 w-4" />
              <span>Sign out</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      {/* Collapse toggle */}
      <button
        onClick={() => setCollapsed((c) => !c)}
        className="absolute -right-3 top-20 flex items-center justify-center w-6 h-6 rounded-full border bg-background shadow-sm hover:bg-accent transition-colors"
        aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
      >
        {collapsed ? (
          <ChevronRight className="h-3 w-3" />
        ) : (
          <ChevronLeft className="h-3 w-3" />
        )}
      </button>
    </aside>
  )
}
