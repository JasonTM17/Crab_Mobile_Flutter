import { useEffect, useState } from 'react'
import { toast } from 'sonner'
import { Ticket } from 'lucide-react'
import api from '@/lib/axios'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'
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

interface Promo {
  id: string
  code: string
  name: string
  type: string
  value: number
  validFrom: string
  validUntil: string
  isActive: boolean
  totalUsed: number
  totalUsageLimit?: number
}

const initialForm = {
  code: '',
  name: '',
  description: '',
  type: 'PERCENTAGE',
  value: 10,
  minOrderValue: 0,
  validFrom: new Date().toISOString().slice(0, 10),
  validUntil: new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10),
}

export default function Promos() {
  const [promos, setPromos] = useState<Promo[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [pendingDeactivate, setPendingDeactivate] = useState<Promo | null>(null)
  const [form, setForm] = useState(initialForm)

  useEffect(() => {
    load()
  }, [])

  async function load() {
    setLoading(true)
    setError(null)
    try {
      const res = await api.get('/promo')
      setPromos(res.data.data ?? res.data ?? [])
    } catch (e) {
      console.error(e)
      setError('Could not load promos.')
      setPromos([])
    } finally {
      setLoading(false)
    }
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault()
    setSubmitting(true)
    try {
      await api.post('/promo', form)
      toast.success(`Promo ${form.code} created`)
      setShowForm(false)
      setForm(initialForm)
      load()
    } catch (err: any) {
      toast.error(err.response?.data?.message ?? 'Failed to create promo')
    } finally {
      setSubmitting(false)
    }
  }

  async function deactivate(promo: Promo) {
    setSubmitting(true)
    try {
      await api.put(`/promo/${promo.id}/deactivate`)
      toast.success(`Promo ${promo.code} deactivated`)
      setPendingDeactivate(null)
      load()
    } catch (e: any) {
      toast.error(e.response?.data?.message ?? 'Failed to deactivate')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Promo Codes</h1>
        <Button onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancel' : '+ New Promo'}
        </Button>
      </div>

      {showForm && (
        <form
          onSubmit={submit}
          className="bg-card p-6 rounded-lg shadow border grid grid-cols-2 gap-4"
        >
          <Input
            placeholder="Code (e.g. WELCOME50)"
            value={form.code}
            onChange={(e) => setForm({ ...form, code: e.target.value })}
            required
          />
          <Input
            placeholder="Name"
            value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            required
          />
          <select
            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
            value={form.type}
            onChange={(e) => setForm({ ...form, type: e.target.value })}
          >
            <option value="PERCENTAGE">Percentage</option>
            <option value="FIXED">Fixed amount</option>
            <option value="FREE_RIDE">Free ride</option>
          </select>
          <Input
            type="number"
            placeholder="Value"
            value={form.value}
            onChange={(e) => setForm({ ...form, value: +e.target.value })}
            required
          />
          <Input
            type="number"
            placeholder="Min order value"
            value={form.minOrderValue}
            onChange={(e) =>
              setForm({ ...form, minOrderValue: +e.target.value })
            }
          />
          <Input
            type="date"
            value={form.validFrom}
            onChange={(e) => setForm({ ...form, validFrom: e.target.value })}
            required
          />
          <Input
            type="date"
            value={form.validUntil}
            onChange={(e) => setForm({ ...form, validUntil: e.target.value })}
            required
          />
          <div className="col-span-2 flex justify-end">
            <Button type="submit" disabled={submitting}>
              {submitting ? 'Creating…' : 'Create Promo'}
            </Button>
          </div>
        </form>
      )}

      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <table className="w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Code</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Type</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Value</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Used</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Valid</th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Status</th>
              <th className="text-right px-6 py-3 text-xs font-medium text-muted-foreground uppercase">Actions</th>
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
                    icon={<Ticket className="h-5 w-5" />}
                    title="Could not load promos"
                    description={error}
                    action={
                      <Button onClick={load} variant="outline">
                        Retry
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : promos.length === 0 ? (
              <tr>
                <td colSpan={7}>
                  <EmptyState
                    icon={<Ticket className="h-5 w-5" />}
                    title="No promos yet"
                    description="Create your first promo code to incentivise riders and customers."
                    action={
                      <Button onClick={() => setShowForm(true)}>
                        + New Promo
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : (
              promos.map((p) => (
                <tr key={p.id} className="hover:bg-muted/30">
                  <td className="px-6 py-4 font-mono font-bold">{p.code}</td>
                  <td className="px-6 py-4">{p.type}</td>
                  <td className="px-6 py-4">
                    {p.value}
                    {p.type === 'PERCENTAGE' ? '%' : ' VND'}
                  </td>
                  <td className="px-6 py-4">
                    {p.totalUsed}
                    {p.totalUsageLimit ? ` / ${p.totalUsageLimit}` : ''}
                  </td>
                  <td className="px-6 py-4 text-sm">
                    {p.validUntil
                      ? new Date(p.validUntil).toLocaleDateString()
                      : '-'}
                  </td>
                  <td className="px-6 py-4">
                    <Badge variant={p.isActive ? 'success' : 'secondary'}>
                      {p.isActive ? 'Active' : 'Inactive'}
                    </Badge>
                  </td>
                  <td className="px-6 py-4 text-right">
                    {p.isActive && (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setPendingDeactivate(p)}
                      >
                        Deactivate
                      </Button>
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <AlertDialog
        open={!!pendingDeactivate}
        onOpenChange={(open) => !open && setPendingDeactivate(null)}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Deactivate promo?</AlertDialogTitle>
            <AlertDialogDescription>
              {pendingDeactivate?.code} will no longer apply to new orders. You
              can reactivate it later from the API.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={submitting}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              disabled={submitting}
              onClick={(e) => {
                e.preventDefault()
                if (pendingDeactivate) deactivate(pendingDeactivate)
              }}
            >
              {submitting ? 'Deactivating…' : 'Deactivate'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
