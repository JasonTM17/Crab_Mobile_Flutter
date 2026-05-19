import { useQuery } from '@tanstack/react-query'
import { Users, Car, ShoppingBag, DollarSign } from 'lucide-react'
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import api from '@/lib/axios'

const COLORS = ['#00B14F', '#0EA5E9', '#F59E0B', '#EF4444']

type DashboardSummary = {
  totalUsers?: number
  activeRides?: number
  ordersToday?: number
  revenueMonth?: number
  ridesByHour?: { hour: string; count: number }[]
  topRestaurants?: { name: string; orders: number }[]
  vehicleMix?: { type: string; value: number }[]
}

async function fetchDashboard(): Promise<DashboardSummary> {
  // Try the aggregated admin/dashboard endpoint first; fall back to individual
  // counts if not available so the page still renders without error.
  try {
    const { data } = await api.get('/admin/dashboard')
    return data?.data ?? data ?? {}
  } catch {
    // Best-effort fallback — individual endpoints may not all exist yet
    const safe = async <T,>(p: Promise<T>): Promise<T | null> =>
      p.catch(() => null)
    const [users, rides, orders] = await Promise.all([
      safe(api.get('/profiles?count=true')),
      safe(api.get('/rides?status=IN_PROGRESS&count=true')),
      safe(api.get('/orders?count=true&date=today')),
    ])
    return {
      totalUsers: (users as { data?: { total?: number } } | null)?.data?.total,
      activeRides: (rides as { data?: { total?: number } } | null)?.data?.total,
      ordersToday: (orders as { data?: { total?: number } } | null)?.data
        ?.total,
    }
  }
}

export default function Dashboard() {
  const { data, isLoading } = useQuery({
    queryKey: ['dashboard-summary'],
    queryFn: fetchDashboard,
    refetchInterval: 30_000,
  })

  const stats = [
    {
      title: 'Total Users',
      value: data?.totalUsers,
      description: 'Registered users',
      icon: Users,
    },
    {
      title: 'Active Rides',
      value: data?.activeRides,
      description: 'Rides in progress',
      icon: Car,
    },
    {
      title: 'Orders Today',
      value: data?.ordersToday,
      description: 'Food & delivery orders',
      icon: ShoppingBag,
    },
    {
      title: 'Revenue',
      value: data?.revenueMonth,
      description: 'Total this month (VND)',
      icon: DollarSign,
      isCurrency: true,
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Welcome back</h2>
        <p className="text-muted-foreground">
          Here's an overview of your platform.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map(({ title, value, description, icon: Icon, isCurrency }) => (
          <Card key={title}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{title}</CardTitle>
              <Icon
                className="h-4 w-4 text-muted-foreground"
                aria-hidden="true"
              />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {isLoading
                  ? '…'
                  : value == null
                    ? '—'
                    : isCurrency
                      ? Number(value).toLocaleString('vi-VN')
                      : Number(value).toLocaleString('en-US')}
              </div>
              <p className="text-xs text-muted-foreground">{description}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Rides per hour (24h)</CardTitle>
          </CardHeader>
          <CardContent className="h-[260px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data?.ridesByHour ?? sampleHours}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="hour" />
                <YAxis />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="count"
                  stroke="#00B14F"
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top restaurants by orders</CardTitle>
          </CardHeader>
          <CardContent className="h-[260px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data?.topRestaurants ?? sampleRestaurants}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis
                  dataKey="name"
                  tick={{ fontSize: 11 }}
                  interval={0}
                  angle={-15}
                  textAnchor="end"
                  height={60}
                />
                <YAxis />
                <Tooltip />
                <Bar dataKey="orders" fill="#0EA5E9" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Vehicle type distribution</CardTitle>
        </CardHeader>
        <CardContent className="h-[280px]">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={data?.vehicleMix ?? sampleVehicles}
                dataKey="value"
                nameKey="type"
                cx="50%"
                cy="50%"
                outerRadius={90}
                label
              >
                {(data?.vehicleMix ?? sampleVehicles).map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Legend />
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  )
}

// Demo fallbacks shown only when backend has no data yet (e.g. dev/empty DB).
const sampleHours = Array.from({ length: 24 }, (_, h) => ({
  hour: `${h}:00`,
  count: Math.max(0, Math.round(20 + 30 * Math.sin((h / 24) * Math.PI * 2))),
}))
const sampleRestaurants = [
  { name: 'Pho Hanoi', orders: 124 },
  { name: 'Bun Cha 24', orders: 98 },
  { name: 'Banh Mi Co', orders: 86 },
  { name: 'Com Tam', orders: 72 },
  { name: 'Sushi Sen', orders: 60 },
]
const sampleVehicles = [
  { type: 'Bike', value: 540 },
  { type: 'Car 4', value: 220 },
  { type: 'Car 7', value: 80 },
  { type: 'Premium', value: 35 },
]
