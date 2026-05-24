import { useState } from 'react'
import { ShoppingBag } from 'lucide-react'
import api from '@/lib/axios'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'

interface Order {
  id: string
  customer_id?: string
  customerId?: string
  status: string
  total?: number
  total_amount?: number
  created_at?: string
  createdAt?: string
}

export default function Orders() {
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [restaurantId, setRestaurantId] = useState('')
  const [hasSearched, setHasSearched] = useState(false)

  async function load() {
    if (!restaurantId) return
    setLoading(true)
    setError(null)
    setHasSearched(true)
    try {
      const res = await api.get(`/orders/restaurant/${restaurantId}`)
      setOrders(res.data.data ?? res.data ?? [])
    } catch {
      setError('Failed to load orders for this restaurant.')
      setOrders([])
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between gap-4">
        <div className="space-y-1">
          <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">
            Orders
          </p>
          <p className="text-sm text-muted-foreground">
            Load recent orders for a restaurant and inspect customer, status, and payment totals.
          </p>
        </div>
        <div className="flex gap-2">
          <Input
            value={restaurantId}
            onChange={(e) => setRestaurantId(e.target.value)}
            placeholder="Restaurant ID"
            className="w-72"
          />
          <Button onClick={load} disabled={!restaurantId}>
            Load
          </Button>
        </div>
      </div>

      <div className="rounded-2xl border bg-card shadow-sm overflow-hidden">
        <div className="flex items-center justify-between border-b bg-muted/30 px-6 py-3 text-sm text-muted-foreground">
          <span>{orders.length} orders loaded</span>
          <span>Lookup by restaurant ID</span>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">ID</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Customer</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Status</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Total</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Created</th>
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
                    icon={<ShoppingBag className="h-5 w-5" />}
                    title="Could not load orders"
                    description={error}
                    action={
                      <Button variant="outline" onClick={load}>
                        Retry
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : orders.length === 0 ? (
              <tr>
                <td colSpan={5}>
                  <EmptyState
                    icon={<ShoppingBag className="h-5 w-5" />}
                    title={
                      hasSearched
                        ? 'No orders for this restaurant'
                        : 'Search by restaurant'
                    }
                    description={
                      hasSearched
                        ? 'Try a different restaurant ID.'
                        : 'Enter a restaurant ID to load its recent orders.'
                    }
                  />
                </td>
              </tr>
            ) : (
              orders.map((o) => (
                <tr key={o.id} className="hover:bg-muted/30">
                  <td className="px-6 py-4 font-mono text-xs">
                    {o.id?.slice(0, 8)}
                  </td>
                  <td className="px-6 py-4 font-mono text-xs">
                    {(o.customer_id ?? o.customerId)?.slice(0, 8)}
                  </td>
                  <td className="px-6 py-4">
                    <OrderStatusBadge status={o.status} />
                  </td>
                  <td className="px-6 py-4">
                    {o.total ?? o.total_amount ?? '-'} VND
                  </td>
                  <td className="px-6 py-4 text-sm">
                    {(o.created_at ?? o.createdAt)
                      ? new Date(o.created_at ?? o.createdAt!).toLocaleString()
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

function OrderStatusBadge({ status }: { status: string }) {
  const variant: Record<
    string,
    'success' | 'destructive' | 'secondary' | 'warning' | 'info'
  > = {
    DELIVERED: 'success',
    PICKED_UP: 'info',
    PREPARING: 'info',
    READY: 'info',
    CONFIRMED: 'info',
    PLACED: 'warning',
    CANCELLED: 'destructive',
  }
  return <Badge variant={variant[status] ?? 'secondary'}>{status}</Badge>
}
