import { useState } from 'react'
import api from '@/lib/axios'

export default function NotificationBroadcast() {
  const [form, setForm] = useState({
    title: '',
    body: '',
    type: 'PROMO',
    userIds: '',
  })
  const [sending, setSending] = useState(false)
  const [result, setResult] = useState<string>('')

  async function send(e: React.FormEvent) {
    e.preventDefault()
    setSending(true)
    setResult('')
    try {
      const userIds = form.userIds
        .split(/[\n,]/)
        .map((s) => s.trim())
        .filter(Boolean)
      const res = await api.post('/notifications/broadcast', {
        title: form.title,
        body: form.body,
        type: form.type.toLowerCase(),
        userIds,
      })
      setResult(`Sent to ${res.data.sent ?? userIds.length} users`)
    } catch (err: any) {
      setResult(err.response?.data?.message ?? 'Failed to send')
    } finally {
      setSending(false)
    }
  }

  return (
    <div className="max-w-2xl space-y-6">
      <h1 className="text-2xl font-bold tracking-tight">Broadcast Notification</h1>
      <form
        onSubmit={send}
        className="bg-card p-6 rounded-lg shadow border space-y-4"
      >
        <div>
          <label className="block text-sm font-medium mb-1">Title</label>
          <input
            className="w-full px-3 py-2 border rounded bg-background"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            required
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Body</label>
          <textarea
            className="w-full px-3 py-2 border rounded bg-background"
            rows={4}
            value={form.body}
            onChange={(e) => setForm({ ...form, body: e.target.value })}
            required
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Type</label>
          <select
            className="w-full px-3 py-2 border rounded bg-background"
            value={form.type}
            onChange={(e) => setForm({ ...form, type: e.target.value })}
          >
            <option value="PROMO">Promo</option>
            <option value="SYSTEM">System</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">
            User IDs (one per line or comma-separated)
          </label>
          <textarea
            className="w-full px-3 py-2 border rounded font-mono text-sm bg-background"
            rows={6}
            value={form.userIds}
            onChange={(e) => setForm({ ...form, userIds: e.target.value })}
            required
          />
        </div>
        <button
          type="submit"
          disabled={sending}
          className="px-6 py-2 bg-primary text-primary-foreground rounded-lg disabled:opacity-50"
        >
          {sending ? 'Sending...' : 'Send Notification'}
        </button>
        {result && <div className="p-3 bg-muted rounded text-sm">{result}</div>}
      </form>
    </div>
  )
}
