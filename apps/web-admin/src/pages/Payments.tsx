import { useQuery } from '@tanstack/react-query'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import api from '@/lib/axios'

type Transaction = {
  id: string
  userId: string
  type: string
  amount: number
  status: string
  description?: string
  createdAt: string
}

async function fetchTransactions(): Promise<Transaction[]> {
  try {
    const { data } = await api.get('/transactions?limit=100')
    return (data?.data ?? data ?? []) as Transaction[]
  } catch {
    return []
  }
}

export default function Payments() {
  const { data: transactions = [], isLoading } = useQuery({
    queryKey: ['admin-transactions'],
    queryFn: fetchTransactions,
    refetchInterval: 30_000,
  })

  const totalVolume = transactions.reduce(
    (s, t) => s + Math.abs(Number(t.amount) || 0),
    0,
  )
  const completedCount = transactions.filter(
    (t) => t.status === 'COMPLETED',
  ).length

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Payments</h2>
        <p className="text-muted-foreground">
          Wallet transactions, settlements and refunds.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Total transactions</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {isLoading ? '…' : transactions.length}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Completed</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {isLoading ? '…' : completedCount}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Total volume (VND)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {isLoading ? '…' : totalVolume.toLocaleString('vi-VN')}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Recent transactions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-muted-foreground border-b">
                  <th className="py-2 pr-4">Time</th>
                  <th className="py-2 pr-4">User</th>
                  <th className="py-2 pr-4">Type</th>
                  <th className="py-2 pr-4">Amount</th>
                  <th className="py-2 pr-4">Status</th>
                  <th className="py-2 pr-4">Description</th>
                </tr>
              </thead>
              <tbody>
                {isLoading ? (
                  <tr>
                    <td className="py-3 text-muted-foreground" colSpan={6}>
                      Loading…
                    </td>
                  </tr>
                ) : transactions.length === 0 ? (
                  <tr>
                    <td className="py-6 text-muted-foreground text-center" colSpan={6}>
                      No transactions yet.
                    </td>
                  </tr>
                ) : (
                  transactions.slice(0, 50).map((t) => (
                    <tr key={t.id} className="border-b last:border-0">
                      <td className="py-2 pr-4 whitespace-nowrap">
                        {new Date(t.createdAt).toLocaleString('vi-VN')}
                      </td>
                      <td className="py-2 pr-4 font-mono text-xs">
                        {t.userId?.slice(0, 8)}…
                      </td>
                      <td className="py-2 pr-4">{t.type}</td>
                      <td
                        className={`py-2 pr-4 font-medium ${Number(t.amount) < 0 ? 'text-destructive' : 'text-emerald-600'}`}
                      >
                        {Number(t.amount).toLocaleString('vi-VN')}
                      </td>
                      <td className="py-2 pr-4">
                        <span
                          className={`px-2 py-0.5 rounded text-xs font-medium ${
                            t.status === 'COMPLETED'
                              ? 'bg-emerald-100 text-emerald-700'
                              : t.status === 'PENDING'
                                ? 'bg-amber-100 text-amber-700'
                                : 'bg-rose-100 text-rose-700'
                          }`}
                        >
                          {t.status}
                        </span>
                      </td>
                      <td className="py-2 pr-4 text-muted-foreground">
                        {t.description ?? ''}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
