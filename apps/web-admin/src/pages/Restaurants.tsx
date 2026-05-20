import { useEffect, useState } from 'react'
import { Store } from 'lucide-react'
import api from '@/lib/axios'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'

interface Restaurant {
  id: string
  name: string
  address: string
  rating: number
  isOpen: boolean
  cuisineType?: string
  phone?: string
}

export default function Restaurants() {
  const [list, setList] = useState<Restaurant[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  function load() {
    setLoading(true)
    setError(null)
    api
      .get('/restaurants/search')
      .then((r) => setList(r.data.data ?? r.data ?? []))
      .catch(() => {
        setError('Failed to load restaurants.')
        setList([])
      })
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    load()
  }, [])

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold tracking-tight">Restaurants</h1>
      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <table className="w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Name</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Address</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Cuisine</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Rating</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <tr key={`sk-${i}`}>
                  {Array.from({ length: 5 }).map((__, j) => (
                    <td key={j} className="px-6 py-4">
                      <Skeleton className="h-4 w-24" />
                    </td>
                  ))}
                </tr>
              ))
            ) : error ? (
              <tr>
                <td colSpan={5}>
                  <EmptyState
                    icon={<Store className="h-5 w-5" />}
                    title="Could not load restaurants"
                    description={error}
                    action={
                      <Button variant="outline" onClick={load}>
                        Retry
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : list.length === 0 ? (
              <tr>
                <td colSpan={5}>
                  <EmptyState
                    icon={<Store className="h-5 w-5" />}
                    title="No restaurants yet"
                    description="Once partner restaurants onboard, they'll appear here."
                  />
                </td>
              </tr>
            ) : (
              list.map((r) => (
                <tr key={r.id} className="hover:bg-muted/30">
                  <td className="px-6 py-4 font-medium">{r.name}</td>
                  <td className="px-6 py-4 text-muted-foreground">{r.address}</td>
                  <td className="px-6 py-4 text-sm">{r.cuisineType ?? '-'}</td>
                  <td className="px-6 py-4">★ {r.rating?.toFixed?.(1) ?? '-'}</td>
                  <td className="px-6 py-4">
                    <Badge variant={r.isOpen ? 'success' : 'secondary'}>
                      {r.isOpen ? 'Open' : 'Closed'}
                    </Badge>
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
