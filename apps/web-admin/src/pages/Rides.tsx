import { useEffect, useState } from 'react'
import { MapPin } from 'lucide-react'
import api from '@/lib/axios'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'

interface Ride {
  id: string
  rider_id?: string
  riderId?: string
  driver_id?: string
  driverId?: string
  status: string
  fare?: number
  distance_km?: number
  distanceKm?: number
  created_at?: string
  createdAt?: string
}

export default function Rides() {
  const [rides, setRides] = useState<Ride[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  function load() {
    api
      .get('/rides')
      .then((r) => setRides(r.data.data ?? r.data ?? []))
      .catch(() => {
        setError('Failed to load rides.')
        setRides([])
      })
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    void load()
  }, [])

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">
          Rides
        </p>
        <p className="text-sm text-muted-foreground">
          Monitor live and historical rides, including assignment status, fare totals, and distance.
        </p>
      </div>
      <div className="rounded-2xl border bg-card shadow-sm overflow-hidden">
        <div className="flex flex-col gap-1 border-b bg-muted/30 px-3 py-3 text-sm text-muted-foreground sm:flex-row sm:items-center sm:justify-between md:px-6">
          <span>{rides.length} rides loaded</span>
          <span>Assignment, fare, and distance snapshot</span>
        </div>
        <div className="space-y-3 p-3 md:hidden">
          {loading ? (
            Array.from({ length: 4 }).map((_, i) => <RideCardSkeleton key={i} />)
          ) : error ? (
            <EmptyState
              icon={<MapPin className="h-5 w-5" />}
              title="Could not load rides"
              description={error}
              action={
                <Button
                  variant="outline"
                  onClick={() => {
                    setLoading(true)
                    setError(null)
                    void load()
                  }}
                >
                  Retry
                </Button>
              }
            />
          ) : rides.length === 0 ? (
            <EmptyState
              icon={<MapPin className="h-5 w-5" />}
              title="No rides yet"
              description="Once riders book trips they'll show up here."
            />
          ) : (
            rides.map((r) => <RideCard key={r.id} ride={r} />)
          )}
        </div>
        <div className="hidden overflow-x-auto md:block">
          <table className="w-full min-w-[900px]">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">ID</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Rider</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Driver</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Status</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Fare</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Distance</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Created</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <tr key={`sk-${i}`}>
                  {Array.from({ length: 7 }).map((__, j) => (
                    <td key={j} className="px-6 py-4">
                      <Skeleton className="h-4 w-20" />
                    </td>
                  ))}
                </tr>
              ))
            ) : error ? (
              <tr>
                <td colSpan={7}>
                  <EmptyState
                    icon={<MapPin className="h-5 w-5" />}
                    title="Could not load rides"
                    description={error}
                    action={
                      <Button
                        variant="outline"
                        onClick={() => {
                          setLoading(true)
                          setError(null)
                          void load()
                        }}
                      >
                        Retry
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : rides.length === 0 ? (
              <tr>
                <td colSpan={7}>
                  <EmptyState
                    icon={<MapPin className="h-5 w-5" />}
                    title="No rides yet"
                    description="Once riders book trips they'll show up here."
                  />
                </td>
              </tr>
            ) : (
              rides.map((r) => (
                <tr key={r.id} className="hover:bg-muted/30">
                  <td className="px-6 py-4 font-mono text-xs">
                    {r.id?.slice(0, 8)}
                  </td>
                  <td className="px-6 py-4 font-mono text-xs">
                    {(r.rider_id ?? r.riderId)?.slice(0, 8)}
                  </td>
                  <td className="px-6 py-4 font-mono text-xs">
                    {(r.driver_id ?? r.driverId)?.slice(0, 8) ?? '-'}
                  </td>
                  <td className="px-6 py-4">
                    <RideStatusBadge status={r.status} />
                  </td>
                  <td className="px-6 py-4">{r.fare ?? '-'} VND</td>
                  <td className="px-6 py-4">
                    {r.distance_km ?? r.distanceKm ?? '-'} km
                  </td>
                  <td className="px-6 py-4 text-sm">
                    {(r.created_at ?? r.createdAt)
                      ? new Date(r.created_at ?? r.createdAt!).toLocaleString()
                      : '-'}
                  </td>
                </tr>
              ))
            )}
          </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

function RideCard({ ride }: { ride: Ride }) {
  const created = ride.created_at ?? ride.createdAt
  return (
    <div className="rounded-xl border bg-background p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="font-mono text-sm font-semibold">{ride.id?.slice(0, 8)}</p>
          <p className="text-sm text-muted-foreground">
            {(ride.rider_id ?? ride.riderId)?.slice(0, 8)} {'->'}{' '}
            {(ride.driver_id ?? ride.driverId)?.slice(0, 8) ?? 'unassigned'}
          </p>
        </div>
        <RideStatusBadge status={ride.status} />
      </div>
      <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
        <div>
          <p className="text-xs text-muted-foreground">Fare</p>
          <p className="font-medium">{ride.fare ?? '-'} VND</p>
        </div>
        <div>
          <p className="text-xs text-muted-foreground">Distance</p>
          <p className="font-medium">{ride.distance_km ?? ride.distanceKm ?? '-'} km</p>
        </div>
        <div className="col-span-2">
          <p className="text-xs text-muted-foreground">Created</p>
          <p className="font-medium">
            {created ? new Date(created).toLocaleString() : '-'}
          </p>
        </div>
      </div>
    </div>
  )
}

function RideCardSkeleton() {
  return (
    <div className="rounded-xl border bg-background p-4 shadow-sm">
      <Skeleton className="h-5 w-28" />
      <Skeleton className="mt-2 h-4 w-44" />
      <div className="mt-4 grid grid-cols-2 gap-3">
        <Skeleton className="h-10 w-full" />
        <Skeleton className="h-10 w-full" />
      </div>
    </div>
  )
}

function RideStatusBadge({ status }: { status: string }) {
  const variant: Record<
    string,
    'success' | 'destructive' | 'secondary' | 'warning' | 'info'
  > = {
    COMPLETED: 'success',
    IN_PROGRESS: 'info',
    PICKUP: 'info',
    MATCHED: 'info',
    REQUESTED: 'warning',
    CANCELLED: 'destructive',
  }
  return <Badge variant={variant[status] ?? 'secondary'}>{status}</Badge>
}
