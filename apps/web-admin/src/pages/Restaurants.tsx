import { useEffect, useState } from 'react'
import api from '@/lib/axios'

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

  useEffect(() => {
    api
      .get('/restaurants/search')
      .then((r) => setList(r.data.data ?? r.data ?? []))
      .catch(() => setList([]))
      .finally(() => setLoading(false))
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
              <tr>
                <td colSpan={5} className="text-center py-8">
                  Loading...
                </td>
              </tr>
            ) : list.length === 0 ? (
              <tr>
                <td colSpan={5} className="text-center py-8 text-muted-foreground">
                  No restaurants
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
                    <span
                      className={`px-2 py-1 text-xs rounded ${
                        r.isOpen
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {r.isOpen ? 'Open' : 'Closed'}
                    </span>
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
