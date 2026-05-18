import { useEffect, useState } from 'react'
import api from '@/lib/axios'

export default function Orders() {
  const [orders, setOrders] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [restaurantId, setRestaurantId] = useState('')

  async function load() {
    if (!restaurantId) return
    setLoading(true)
    try {
      const res = await api.get(`/orders/restaurant/${restaurantId}`)
      setOrders(res.data.data ?? res.data ?? [])
    } catch {
      setOrders([])
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    setLoading(false)
  }, [])

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Orders</h1>
        <div className="flex gap-2">
          <input
            value={restaurantId}
            onChange={(e) => setRestaurantId(e.target.value)}
            placeholder="Restaurant ID"
            className="px-3 py-2 border rounded bg-background w-72"
          />
          <button
            onClick={load}
            className="px-4 py-2 bg-primary text-primary-foreground rounded-lg"
          >
            Load
          </button>
        </div>
      </div>

      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <table className="w-full">
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
              <tr>
                <td colSpan={5} className="text-center py-8">
                  Loading...
                </td>
              </tr>
            ) : orders.length === 0 ? (
              <tr>
                <td colSpan={5} className="text-center py-8 text-muted-foreground">
                  No orders. Enter a restaurant ID to load.
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
                    <span className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                      {o.status}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    {o.total ?? o.total_amount ?? '-'} VND
                  </td>
                  <td className="px-6 py-4 text-sm">
                    {(o.created_at ?? o.createdAt)
                      ? new Date(o.created_at ?? o.createdAt).toLocaleString()
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
