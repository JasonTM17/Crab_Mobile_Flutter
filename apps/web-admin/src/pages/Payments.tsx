import { useQuery } from '@tanstack/react-query'
import { CreditCard } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'
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
  const { data: transactions = [], isLoading, isError, refetch } = useQuery({
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
            {isLoading ? (
              <Skeleton className="h-8 w-20" />
            ) : (
              <div className="text-2xl font-bold">{transactions.length}</div>
            )}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Completed</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <Skeleton className="h-8 w-20" />
            ) : (
              <div className="text-2xl font-bold">{completedCount}</div>
            )}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Total volume (VND)</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <Skeleton className="h-8 w-32" />
            ) : (
              <div className="text-2xl font-bold">
                {totalVolume.toLocaleString('vi-VN')}
              </div>
            )}
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
                  Array.from({ length: 5 }).map((_, i) => (
                    <tr key={`sk-${i}`} className="border-b last:border-0">
                      {Array.from({ length: 6 }).map((__, j) => (
                        <td key={j} className="py-2 pr-4">
                          <Skeleton className="h-4 w-20" />
                        </td>
                      ))}
                    </tr>
                  ))
                ) : isError ? (
                  <tr>
                    <td colSpan={6}>
                      <EmptyState
                        icon={<CreditCard className="h-5 w-5" />}
                        title="Could not load transactions"
                        description="Try refreshing in a moment."
                        action={
                          <Button variant="outline" onClick={() => refetch()}>
                            Retry
                          </Button>
                        }
                      />
                    </td>
                  </tr>
                ) : transactions.length === 0 ? (
                  <tr>
                    <td colSpan={6}>
                      <EmptyState
                        icon={<CreditCard className="h-5 w-5" />}
                        title="No transactions yet"
                        description="Wallet movements will be recorded here as users transact."
                      />
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
                        <Badge
                          variant={
                            t.status === 'COMPLETED'
                              ? 'success'
                              : t.status === 'PENDING'
                                ? 'warning'
                                : 'destructive'
                          }
                        >
                          {t.status}
                        </Badge>
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
