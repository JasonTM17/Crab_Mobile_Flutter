import {
  Bell,
  Car,
  CreditCard,
  LayoutDashboard,
  MapPin,
  ShoppingBag,
  Store,
  Ticket,
  Users,
} from 'lucide-react'

export const navItems = [
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
