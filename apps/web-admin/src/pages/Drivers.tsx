import { useEffect, useState } from 'react'
import { toast } from 'sonner'
import api from '@/lib/axios'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { Car } from 'lucide-react'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'

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
  const [error, setError] = useState<string | null>(null)
  const [pendingApproveId, setPendingApproveId] = useState<string | null>(null)
  const [pendingRejectId, setPendingRejectId] = useState<string | null>(null)
  const [rejectionReason, setRejectionReason] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    loadPending()
  }, [])

  async function loadPending() {
    setLoading(true)
    setError(null)
    try {
      const res = await api.get('/verification/drivers/admin/pending')
      setDrivers(res.data.data ?? res.data ?? [])
    } catch (e) {
      console.error(e)
      setError('Failed to load pending verifications.')
      setDrivers([])
    } finally {
      setLoading(false)
    }
  }

  async function approve(userId: string) {
    setSubmitting(true)
    try {
      await api.put(`/verification/drivers/${userId}/approve`)
      toast.success('Driver approved')
      setPendingApproveId(null)
      loadPending()
    } catch (e: any) {
      toast.error(e.response?.data?.message ?? 'Failed to approve')
    } finally {
      setSubmitting(false)
    }
  }

  async function reject(userId: string, reason: string) {
    if (!reason.trim()) {
      toast.error('Rejection reason is required')
      return
    }
    setSubmitting(true)
    try {
      await api.put(`/verification/drivers/${userId}/reject`, { reason })
      toast.success('Driver rejected')
      setPendingRejectId(null)
      setRejectionReason('')
      loadPending()
    } catch (e: any) {
      toast.error(e.response?.data?.message ?? 'Failed to reject')
    } finally {
      setSubmitting(false)
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
              Array.from({ length: 5 }).map((_, i) => (
                <tr key={`sk-${i}`}>
                  <td className="px-6 py-4">
                    <Skeleton className="h-4 w-24" />
                  </td>
                  <td className="px-6 py-4">
                    <Skeleton className="h-4 w-40" />
                  </td>
                  <td className="px-6 py-4">
                    <Skeleton className="h-4 w-20" />
                  </td>
                  <td className="px-6 py-4">
                    <Skeleton className="h-5 w-16 rounded-full" />
                  </td>
                  <td className="px-6 py-4 text-right">
                    <Skeleton className="h-4 w-32 ml-auto" />
                  </td>
                </tr>
              ))
            ) : error ? (
              <tr>
                <td colSpan={5}>
                  <EmptyState
                    icon={<Car className="h-5 w-5" />}
                    title="Could not load verifications"
                    description={error}
                    action={
                      <Button onClick={loadPending} variant="outline">
                        Retry
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : drivers.length === 0 ? (
              <tr>
                <td colSpan={5}>
                  <EmptyState
                    icon={<Car className="h-5 w-5" />}
                    title="No pending verifications"
                    description="All driver applications have been processed."
                  />
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
                    <Badge variant="warning">{d.verificationStatus}</Badge>
                  </td>
                  <td className="px-6 py-4 text-right space-x-2">
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setPendingApproveId(d.userId)}
                    >
                      Approve
                    </Button>
                    <Button
                      size="sm"
                      variant="destructive"
                      onClick={() => setPendingRejectId(d.userId)}
                    >
                      Reject
                    </Button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Approve confirm */}
      <AlertDialog
        open={!!pendingApproveId}
        onOpenChange={(open) => !open && setPendingApproveId(null)}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Approve driver?</AlertDialogTitle>
            <AlertDialogDescription>
              The driver will be able to start accepting rides immediately.
              This action can be reversed by suspending the account later.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={submitting}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              disabled={submitting}
              onClick={(e) => {
                e.preventDefault()
                if (pendingApproveId) approve(pendingApproveId)
              }}
            >
              {submitting ? 'Approving…' : 'Approve'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Reject dialog with reason */}
      <Dialog
        open={!!pendingRejectId}
        onOpenChange={(open) => {
          if (!open) {
            setPendingRejectId(null)
            setRejectionReason('')
          }
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject driver application</DialogTitle>
            <DialogDescription>
              Provide a clear reason. The driver will see this message.
            </DialogDescription>
          </DialogHeader>
          <Input
            value={rejectionReason}
            onChange={(e) => setRejectionReason(e.target.value)}
            placeholder="e.g. License expired"
            autoFocus
          />
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setPendingRejectId(null)
                setRejectionReason('')
              }}
              disabled={submitting}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              disabled={submitting || !rejectionReason.trim()}
              onClick={() => {
                if (pendingRejectId) reject(pendingRejectId, rejectionReason)
              }}
            >
              {submitting ? 'Rejecting…' : 'Reject driver'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
