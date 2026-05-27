import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import {
  Activity,
  Car,
  DollarSign,
  RefreshCw,
  ShoppingBag,
  Store,
  Users,
} from 'lucide-react'
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { getGreeting, formatTime } from '@/lib/utils'
import { useAuth } from '@/hooks/useAuth'
import api from '@/lib/axios'

const VEHICLE_COLORS = ['#00a84f', '#168fce', '#f59e0b', '#ef4444', '#64748b']
const chartTooltipStyle = {
  border: '1px solid hsl(var(--border))',
  borderRadius: 12,
  boxShadow: '0 18px 45px rgb(15 23 42 / 0.14)',
  fontSize: 12,
}

type DashboardSummary = {
  totalUsers?: number
  activeRides?: number
  ordersToday?: number
  revenueMonth?: number
  ridesByHour?: { hour: string; count: number }[]
  topRestaurants?: { name: string; orders: number }[]
  vehicleMix?: { type: string; value: number }[]
}

type VehicleDatum = {
  type: string
  label: string
  value: number
  color: string
  share: number
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

function formatVehicleType(type: string) {
  const key = type.toUpperCase()
  const labels: Record<string, string> = {
    BIKE: 'Bike',
    MOTORBIKE: 'Bike',
    CAR_4: '4-seat car',
    CAR4: '4-seat car',
    CAR_7: '7-seat car',
    CAR7: '7-seat car',
    PREMIUM: 'Premium',
  }

  if (labels[key]) return labels[key]

  return key
    .replace(/[_-]+/g, ' ')
    .toLowerCase()
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function formatStatValue(value: number | undefined, isCurrency?: boolean) {
  if (value == null) return '-'
  return Number(value).toLocaleString(isCurrency ? 'vi-VN' : 'en-US')
}

function formatTooltipNumber(value: unknown) {
  return Number(value).toLocaleString('en-US')
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
      title: 'Total users',
      value: data?.totalUsers,
      description: 'Registered customer and operator accounts',
      icon: Users,
    },
    {
      title: 'Active rides',
      value: data?.activeRides,
      description: 'Trips currently in progress',
      icon: Car,
    },
    {
      title: 'Orders today',
      value: data?.ordersToday,
      description: 'Food and delivery orders',
      icon: ShoppingBag,
    },
    {
      title: 'Monthly revenue',
      value: data?.revenueMonth,
      description: 'Gross demo GMV in VND',
      icon: DollarSign,
      isCurrency: true,
    },
  ]

  const vehicleMix = useMemo<VehicleDatum[]>(() => {
    const source = data?.vehicleMix ?? []
    const total = source.reduce((sum, item) => sum + Number(item.value), 0)

    return source.map((item, index) => {
      const value = Number(item.value)
      return {
        type: item.type,
        label: formatVehicleType(item.type),
        value,
        color: VEHICLE_COLORS[index % VEHICLE_COLORS.length],
        share: total > 0 ? Math.round((value / total) * 100) : 0,
      }
    })
  }, [data?.vehicleMix])

  const vehicleTotal = vehicleMix.reduce((sum, item) => sum + item.value, 0)

  return (
    <div className="mx-auto flex w-full max-w-7xl flex-col gap-6">
      <section className="rounded-lg bg-gradient-to-br from-emerald-600 via-primary to-emerald-800 p-5 text-primary-foreground shadow-sm sm:p-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="max-w-2xl">
            <p className="text-sm font-medium text-primary-foreground/80">
              Live operations snapshot
            </p>
            <h2 className="mt-1 text-2xl font-bold tracking-tight sm:text-3xl">
              {getGreeting()}, {firstName}
            </h2>
            <p className="mt-2 text-sm text-primary-foreground/85 sm:text-base">
              Monitor marketplace demand, fulfillment quality, and driver
              supply from one command center.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <span className="rounded-full bg-white/10 px-3 py-1.5 text-xs text-primary-foreground/85">
              Last refreshed at {formatTime(lastRefresh)}
            </span>
            <Button
              variant="secondary"
              size="sm"
              onClick={() => refetch()}
              disabled={isFetching}
            >
              <RefreshCw
                className={`mr-2 h-4 w-4 ${isFetching ? 'animate-spin' : ''}`}
              />
              Refresh
            </Button>
          </div>
        </div>
      </section>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {stats.map(({ title, value, description, icon: Icon, isCurrency }) => (
          <Card key={title} className="overflow-hidden">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
              <CardTitle className="text-sm font-semibold">{title}</CardTitle>
              <span className="rounded-full bg-emerald-50 p-2 text-primary">
                <Icon className="h-4 w-4" aria-hidden="true" />
              </span>
            </CardHeader>
            <CardContent>
              {isLoading ? (
                <Skeleton className="h-8 w-28" />
              ) : (
                <div className="font-mono text-2xl font-bold tabular-nums">
                  {formatStatValue(value, isCurrency)}
                </div>
              )}
              <p className="mt-1 text-xs leading-5 text-muted-foreground">
                {description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid min-w-0 gap-4 xl:grid-cols-3">
        <Card className="min-w-0">
          <CardHeader>
            <CardTitle className="text-xl">Rides per hour</CardTitle>
            <CardDescription>
              Completed and active ride demand across the last 24 hours.
            </CardDescription>
          </CardHeader>
          <CardContent className="h-[280px]">
            {isLoading ? (
              <Skeleton className="h-full w-full" />
            ) : !data?.ridesByHour || data.ridesByHour.length === 0 ? (
              <EmptyState
                icon={<Activity className="h-5 w-5" />}
                title="No ride activity yet"
                description="Once rides come in, the hourly distribution will appear here."
                action={
                  <Button asChild variant="outline" size="sm">
                    <Link to="/dashboard/rides">Review rides</Link>
                  </Button>
                }
              />
            ) : (
              <div
                className="h-full"
                role="img"
                aria-label="Hourly ride demand line chart"
              >
                <ResponsiveContainer
                  width="100%"
                  height="100%"
                  minWidth={240}
                  minHeight={240}
                >
                  <LineChart
                    data={data.ridesByHour}
                    margin={{ top: 8, right: 18, left: 0, bottom: 0 }}
                  >
                    <CartesianGrid stroke="hsl(var(--border))" strokeDasharray="4 4" />
                    <XAxis
                      dataKey="hour"
                      tickLine={false}
                      axisLine={false}
                      tickMargin={10}
                    />
                    <YAxis
                      width={44}
                      tickLine={false}
                      axisLine={false}
                      tickFormatter={formatTooltipNumber}
                    />
                    <Tooltip
                      contentStyle={chartTooltipStyle}
                      formatter={(value) => [
                        formatTooltipNumber(value),
                        'Rides',
                      ]}
                      labelFormatter={(label) => `Hour ${label}`}
                    />
                    <Line
                      type="linear"
                      dataKey="count"
                      stroke="hsl(var(--primary))"
                      strokeWidth={3}
                      dot={{ r: 3, strokeWidth: 2 }}
                      activeDot={{ r: 5 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>

        <Card className="min-w-0">
          <CardHeader>
            <CardTitle className="text-xl">Top restaurants by orders</CardTitle>
            <CardDescription>
              Ranked by today's completed and in-progress food demand.
            </CardDescription>
          </CardHeader>
          <CardContent className="h-[280px]">
            {isLoading ? (
              <Skeleton className="h-full w-full" />
            ) : !data?.topRestaurants || data.topRestaurants.length === 0 ? (
              <EmptyState
                icon={<Store className="h-5 w-5" />}
                title="No orders yet"
                description="Top performing restaurants will be ranked here."
                action={
                  <Button asChild variant="outline" size="sm">
                    <Link to="/dashboard/restaurants">Review restaurants</Link>
                  </Button>
                }
              />
            ) : (
              <div
                className="h-full"
                role="img"
                aria-label="Top restaurants by order count bar chart"
              >
                <ResponsiveContainer
                  width="100%"
                  height="100%"
                  minWidth={240}
                  minHeight={240}
                >
                  <BarChart
                    data={data.topRestaurants}
                    margin={{ top: 8, right: 12, left: 0, bottom: 18 }}
                  >
                    <CartesianGrid
                      stroke="hsl(var(--border))"
                      strokeDasharray="4 4"
                      vertical={false}
                    />
                    <XAxis
                      dataKey="name"
                      tick={{ fontSize: 11 }}
                      tickLine={false}
                      axisLine={false}
                      interval={0}
                      angle={-10}
                      textAnchor="end"
                      height={54}
                    />
                    <YAxis
                      width={44}
                      tickLine={false}
                      axisLine={false}
                      tickFormatter={formatTooltipNumber}
                    />
                    <Tooltip
                      contentStyle={chartTooltipStyle}
                      cursor={{ fill: 'hsl(var(--muted))' }}
                      formatter={(value) => [
                        formatTooltipNumber(value),
                        'Orders',
                      ]}
                    />
                    <Bar
                      dataKey="orders"
                      fill="#168fce"
                      radius={[8, 8, 0, 0]}
                      maxBarSize={72}
                    />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>

        <Card className="min-w-0">
          <CardHeader>
            <CardTitle className="text-xl">Vehicle type distribution</CardTitle>
            <CardDescription>
              Active driver supply mix for dispatch planning.
            </CardDescription>
          </CardHeader>
          <CardContent className="h-[280px]">
          {isLoading ? (
            <Skeleton className="h-full w-full" />
          ) : vehicleMix.length === 0 ? (
            <EmptyState
              icon={<Car className="h-5 w-5" />}
              title="No vehicle data"
              description="Vehicle type distribution will appear once drivers register."
              action={
                <Button asChild variant="outline" size="sm">
                  <Link to="/dashboard/drivers">Review drivers</Link>
                </Button>
              }
            />
          ) : (
            <div className="grid h-full min-h-0 grid-rows-[1fr_auto] gap-3">
              <div
                className="relative min-h-0 min-w-0"
                role="img"
                aria-label="Vehicle supply mix donut chart"
              >
                <ResponsiveContainer
                  width="100%"
                  height="100%"
                  minWidth={180}
                  minHeight={160}
                >
                  <PieChart>
                    <Pie
                      data={vehicleMix}
                      dataKey="value"
                      nameKey="label"
                      cx="50%"
                      cy="50%"
                      innerRadius={54}
                      outerRadius={78}
                      paddingAngle={3}
                      stroke="hsl(var(--card))"
                      strokeWidth={4}
                    >
                      {vehicleMix.map((item) => (
                        <Cell key={item.type} fill={item.color} />
                      ))}
                    </Pie>
                    <Tooltip
                      contentStyle={chartTooltipStyle}
                      formatter={(value, name) => [
                        `${formatTooltipNumber(value)} drivers`,
                        name,
                      ]}
                    />
                  </PieChart>
                </ResponsiveContainer>
                <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                  <div className="text-center">
                    <div className="font-mono text-2xl font-bold tabular-nums">
                      {formatTooltipNumber(vehicleTotal)}
                    </div>
                    <div className="text-xs font-medium text-muted-foreground">
                      active drivers
                    </div>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                {vehicleMix.map((item) => (
                  <div
                    key={item.type}
                    className="flex items-center justify-between gap-2 rounded-lg border bg-muted/30 px-3 py-2"
                  >
                    <div className="flex min-w-0 items-center gap-2">
                      <span
                        className="h-3 w-3 rounded-full"
                        style={{ backgroundColor: item.color }}
                      />
                      <div className="min-w-0">
                        <p className="truncate text-xs font-semibold">
                          {item.label}
                        </p>
                        <p className="text-[11px] text-muted-foreground">
                          {item.share}% of supply
                        </p>
                      </div>
                    </div>
                    <span className="font-mono text-xs font-semibold tabular-nums">
                      {formatTooltipNumber(item.value)}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
