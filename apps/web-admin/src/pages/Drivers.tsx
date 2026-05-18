import { useEffect, useState } from 'react'
import api from '@/lib/axios'

interface Driver {
  userId: string
  licenseNumber: string
  vehicleType: string
  vehiclePlate: string
  vehicleBrand: string
  vehicleModel: string
  verificationStatus: string
  rating: number
  totalRides: number
  isOnline: boolean
}

export default function Drivers() {
  const [drivers, setDrivers] = useState<Driver[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadPending()
  }, [])

  async function loadPending() {
    setLoading(true)
    try {
      const res = await api.get('/verification/drivers/admin/pending')
      setDrivers(res.data.data ?? res.data ?? [])
    } catch (e) {
      console.error(e)
      setDrivers([])
    } finally {
      setLoading(false)
    }
  }

  async function approve(userId: string) {
    if (!confirm(`Approve driver ${userId}?`)) return
    try {
      await api.put(`/verification/drivers/${userId}/approve`)
      loadPending()
    } catch (e: any) {
      alert(e.response?.data?.message ?? 'Failed to approve')
    }
  }

  async function reject(userId: string) {
    const reason = prompt('Rejection reason:')
    if (!reason) return
    try {
      await api.put(`/verification/drivers/${userId}/reject`, { reason })
      loadPending()
    } catch (e: any) {
      alert(e.response?.data?.message ?? 'Failed to reject')
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold tracking-tight">
        Driver Verifications (Pending)
      </h1>
      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <table className="w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                License
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Vehicle
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Plate
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Status
              </th>
              <th className="text-right px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {loading ? (
              <tr>
                <td colSpan={5} className="text-center py-8">
                  Loading...
                </td>
              </tr>
            ) : drivers.length === 0 ? (
              <tr>
                <td colSpan={5} className="text-center py-8 text-muted-foreground">
                  No pending verifications
                </td>
              </tr>
            ) : (
              drivers.map((d) => (
                <tr key={d.userId} className="hover:bg-muted/30">
                  <td className="px-6 py-4">{d.licenseNumber}</td>
                  <td className="px-6 py-4">
                    {d.vehicleType} - {d.vehicleBrand} {d.vehicleModel}
                  </td>
                  <td className="px-6 py-4 font-mono">{d.vehiclePlate}</td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 text-xs bg-yellow-100 text-yellow-800 rounded">
                      {d.verificationStatus}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => approve(d.userId)}
                      className="text-green-600 hover:underline mr-3"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => reject(d.userId)}
                      className="text-red-600 hover:underline"
                    >
                      Reject
                    </button>
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
