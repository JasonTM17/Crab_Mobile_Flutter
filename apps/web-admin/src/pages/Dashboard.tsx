import { Users, Car, ShoppingBag, DollarSign } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

const stats = [
  {
    title: 'Total Users',
    value: '—',
    description: 'Registered users',
    icon: Users,
  },
  {
    title: 'Active Rides',
    value: '—',
    description: 'Rides in progress',
    icon: Car,
  },
  {
    title: 'Orders Today',
    value: '—',
    description: 'Food & delivery orders',
    icon: ShoppingBag,
  },
  {
    title: 'Revenue',
    value: '—',
    description: 'Total this month',
    icon: DollarSign,
  },
]

export default function Dashboard() {
  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Welcome back</h2>
        <p className="text-muted-foreground">Here's an overview of your platform.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map(({ title, value, description, icon: Icon }) => (
          <Card key={title}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{title}</CardTitle>
              <Icon className="h-4 w-4 text-muted-foreground" aria-hidden="true" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{value}</div>
              <p className="text-xs text-muted-foreground">{description}</p>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}
