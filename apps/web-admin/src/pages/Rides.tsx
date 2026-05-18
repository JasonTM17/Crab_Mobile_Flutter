import { useEffect, useState } from 'react'
import api from '@/lib/axios'

export default function Rides() {
  const [rides, setRides] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api
      .get('/rides')
      .then((r) => setRides(r.data.data ?? r.data ?? []))
      .catch(() => setRides([]))
      .finally(() => setLoading(false))
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
              <tr>
                <td colSpan={7} className="text-center py-8">
                  Loading...
                </td>
              </tr>
            ) : rides.length === 0 ? (
              <tr>
                <td colSpan={7} className="text-center py-8 text-muted-foreground">
                  No rides
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
                    <span className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                      {r.status}
                    </span>
                  </td>
                  <td className="px-6 py-4">{r.fare ?? '-'} VND</td>
                  <td className="px-6 py-4">{r.distance_km ?? r.distanceKm ?? '-'} km</td>
                  <td className="px-6 py-4 text-sm">
                    {(r.created_at ?? r.createdAt)
                      ? new Date(r.created_at ?? r.createdAt).toLocaleString()
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
