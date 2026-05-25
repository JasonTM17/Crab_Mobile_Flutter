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
    void load()
  }, [])

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold tracking-tight">Restaurants</h1>
      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <div className="space-y-3 p-3 md:hidden">
          {loading ? (
            Array.from({ length: 4 }).map((_, i) => (
              <RestaurantCardSkeleton key={i} />
            ))
          ) : error ? (
            <EmptyState
              icon={<Store className="h-5 w-5" />}
              title="Could not load restaurants"
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
          ) : list.length === 0 ? (
            <EmptyState
              icon={<Store className="h-5 w-5" />}
              title="No restaurants yet"
              description="Once partner restaurants onboard, they'll appear here."
            />
          ) : (
            list.map((r) => <RestaurantCard key={r.id} restaurant={r} />)
          )}
        </div>
        <div className="hidden overflow-x-auto md:block">
        <table className="w-full min-w-[760px]">
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
    </div>
  )
}

function RestaurantCard({ restaurant }: { restaurant: Restaurant }) {
  return (
    <div className="rounded-xl border bg-background p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="truncate font-semibold">{restaurant.name}</p>
          <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">
            {restaurant.address}
          </p>
        </div>
        <Badge variant={restaurant.isOpen ? 'success' : 'secondary'}>
          {restaurant.isOpen ? 'Open' : 'Closed'}
        </Badge>
      </div>
      <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
        <div>
          <p className="text-xs text-muted-foreground">Cuisine</p>
          <p className="font-medium">{restaurant.cuisineType ?? '-'}</p>
        </div>
        <div>
          <p className="text-xs text-muted-foreground">Rating</p>
          <p className="font-medium">★ {restaurant.rating?.toFixed?.(1) ?? '-'}</p>
        </div>
      </div>
    </div>
  )
}

function RestaurantCardSkeleton() {
  return (
    <div className="rounded-xl border bg-background p-4 shadow-sm">
      <Skeleton className="h-5 w-40" />
      <Skeleton className="mt-2 h-4 w-full" />
      <Skeleton className="mt-2 h-4 w-52" />
      <div className="mt-4 grid grid-cols-2 gap-3">
        <Skeleton className="h-10 w-full" />
        <Skeleton className="h-10 w-full" />
      </div>
    </div>
  )
}
