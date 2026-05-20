import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Users, Car, ShoppingBag, DollarSign, RefreshCw, Activity, Store } from 'lucide-react'
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
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { getGreeting, formatTime } from '@/lib/utils'
import { useAuth } from '@/hooks/useAuth'
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
  try {
    const { data } = await api.get('/admin/dashboard')
    return data?.data ?? data ?? {}
  } catch {
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
  const { currentUser } = useAuth()
  const [lastRefresh, setLastRefresh] = useState<Date>(new Date())
  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ['dashboard-summary'],
    queryFn: async () => {
      const result = await fetchDashboard()
      setLastRefresh(new Date())
      return result
    },
    refetchInterval: 30_000,
  })

  const firstName =
    currentUser?.firstName ??
    currentUser?.name?.split(' ')?.[0] ??
    'admin'

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
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">
            {getGreeting()}, {firstName}
          </h2>
          <p className="text-muted-foreground">
            Here's an overview of your platform.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs text-muted-foreground">
            Last refreshed at {formatTime(lastRefresh)}
          </span>
          <Button
            variant="outline"
            size="sm"
            onClick={() => refetch()}
            disabled={isFetching}
          >
            <RefreshCw
              className={`h-4 w-4 mr-2 ${isFetching ? 'animate-spin' : ''}`}
            />
            Refresh
          </Button>
        </div>
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
              {isLoading ? (
                <Skeleton className="h-8 w-24" />
              ) : (
                <div className="text-2xl font-bold">
                  {value == null
                    ? '—'
                    : isCurrency
                      ? Number(value).toLocaleString('vi-VN')
                      : Number(value).toLocaleString('en-US')}
                </div>
              )}
              <p className="text-xs text-muted-foreground mt-1">
                {description}
              </p>
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
            {isLoading ? (
              <Skeleton className="h-full w-full" />
            ) : !data?.ridesByHour || data.ridesByHour.length === 0 ? (
              <EmptyState
                icon={<Activity className="h-5 w-5" />}
                title="No ride activity yet"
                description="Once rides come in, the hourly distribution will appear here."
              />
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={data.ridesByHour}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="hour" />
                  <YAxis />
                  <Tooltip />
                  <Line
                    type="monotone"
                    dataKey="count"
                    stroke="hsl(var(--primary))"
                    strokeWidth={2}
                    dot={false}
                  />
                </LineChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top restaurants by orders</CardTitle>
          </CardHeader>
          <CardContent className="h-[260px]">
            {isLoading ? (
              <Skeleton className="h-full w-full" />
            ) : !data?.topRestaurants || data.topRestaurants.length === 0 ? (
              <EmptyState
                icon={<Store className="h-5 w-5" />}
                title="No orders yet"
                description="Top performing restaurants will be ranked here."
              />
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data.topRestaurants}>
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
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Vehicle type distribution</CardTitle>
        </CardHeader>
        <CardContent className="h-[280px]">
          {isLoading ? (
            <Skeleton className="h-full w-full" />
          ) : !data?.vehicleMix || data.vehicleMix.length === 0 ? (
            <EmptyState
              icon={<Car className="h-5 w-5" />}
              title="No vehicle data"
              description="Vehicle type distribution will appear once drivers register."
            />
          ) : (
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={data.vehicleMix}
                  dataKey="value"
                  nameKey="type"
                  cx="50%"
                  cy="50%"
                  outerRadius={90}
                  label
                >
                  {data.vehicleMix.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Legend />
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
