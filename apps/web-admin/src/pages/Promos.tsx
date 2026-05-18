import { useEffect, useState } from 'react'
import api from '@/lib/axios'

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

export default function Promos() {
  const [promos, setPromos] = useState<Promo[]>([])
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({
    code: '',
    name: '',
    description: '',
    type: 'PERCENTAGE',
    value: 10,
    minOrderValue: 0,
    validFrom: new Date().toISOString().slice(0, 10),
    validUntil: new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10),
  })

  useEffect(() => {
    load()
  }, [])

  async function load() {
    try {
      const res = await api.get('/promo')
      setPromos(res.data.data ?? res.data ?? [])
    } catch (e) {
      console.error(e)
      setPromos([])
    }
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault()
    try {
      await api.post('/promo', form)
      setShowForm(false)
      setForm({ ...form, code: '', name: '' })
      load()
    } catch (err: any) {
      alert(err.response?.data?.message ?? 'Failed')
    }
  }

  async function deactivate(id: string) {
    if (!confirm('Deactivate this promo?')) return
    try {
      await api.put(`/promo/${id}/deactivate`)
      load()
    } catch (e: any) {
      alert(e.response?.data?.message ?? 'Failed')
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Promo Codes</h1>
        <button
          onClick={() => setShowForm(!showForm)}
          className="px-4 py-2 bg-primary text-primary-foreground rounded-lg"
        >
          {showForm ? 'Cancel' : '+ New Promo'}
        </button>
      </div>

      {showForm && (
        <form
          onSubmit={submit}
          className="bg-card p-6 rounded-lg shadow border grid grid-cols-2 gap-4"
        >
          <input
            className="px-3 py-2 border rounded bg-background"
            placeholder="Code (e.g. WELCOME50)"
            value={form.code}
            onChange={(e) => setForm({ ...form, code: e.target.value })}
            required
          />
          <input
            className="px-3 py-2 border rounded bg-background"
            placeholder="Name"
            value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            required
          />
          <select
            className="px-3 py-2 border rounded bg-background"
            value={form.type}
            onChange={(e) => setForm({ ...form, type: e.target.value })}
          >
            <option value="PERCENTAGE">Percentage</option>
            <option value="FIXED">Fixed amount</option>
            <option value="FREE_RIDE">Free ride</option>
          </select>
          <input
            type="number"
            className="px-3 py-2 border rounded bg-background"
            placeholder="Value"
            value={form.value}
            onChange={(e) => setForm({ ...form, value: +e.target.value })}
            required
          />
          <input
            type="number"
            className="px-3 py-2 border rounded bg-background"
            placeholder="Min order value"
            value={form.minOrderValue}
            onChange={(e) => setForm({ ...form, minOrderValue: +e.target.value })}
          />
          <input
            type="date"
            className="px-3 py-2 border rounded bg-background"
            value={form.validFrom}
            onChange={(e) => setForm({ ...form, validFrom: e.target.value })}
            required
          />
          <input
            type="date"
            className="px-3 py-2 border rounded bg-background"
            value={form.validUntil}
            onChange={(e) => setForm({ ...form, validUntil: e.target.value })}
            required
          />
          <button
            type="submit"
            className="col-span-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg"
          >
            Create Promo
          </button>
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
            {promos.length === 0 ? (
              <tr>
                <td colSpan={7} className="text-center py-8 text-muted-foreground">
                  No promos
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
                    {p.validUntil ? new Date(p.validUntil).toLocaleDateString() : '-'}
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`px-2 py-1 text-xs rounded ${
                        p.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100'
                      }`}
                    >
                      {p.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    {p.isActive && (
                      <button
                        onClick={() => deactivate(p.id)}
                        className="text-red-600 hover:underline"
                      >
                        Deactivate
                      </button>
                    )}
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
