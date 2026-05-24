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
      <h1 className="text-2xl font-bold tracking-tight">Rides</h1>
      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <table className="w-full">
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
