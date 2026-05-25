import { useEffect, useState } from 'react'
import { Users as UsersIcon } from 'lucide-react'
import api from '@/lib/axios'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState } from '@/components/ui/empty-state'

interface User {
  userId: string
  email: string
  phone: string
  firstName: string
  lastName: string
  role: string
  status: string
  createdAt: string
}

export default function Users() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  useEffect(() => {
    loadUsers()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page])

  async function loadUsers() {
    setLoading(true)
    setError(null)
    try {
      const res = await api.get(`/profiles?page=${page}&limit=20`)
      setUsers(res.data.data ?? res.data ?? [])
    } catch (e) {
      console.error(e)
      setError('Failed to load users.')
      setUsers([])
    } finally {
      setLoading(false)
    }
  }

  const filtered = users.filter(
    (u) =>
      !search ||
      u.email?.toLowerCase().includes(search.toLowerCase()) ||
      u.phone?.includes(search) ||
      `${u.firstName ?? ''} ${u.lastName ?? ''}`
        .toLowerCase()
        .includes(search.toLowerCase()),
  )

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">
            Users
          </p>
          <p className="text-sm text-muted-foreground">
            Search accounts by name, email, or phone and page through recent signups.
          </p>
        </div>
        <Input
          type="text"
          placeholder="Search by name, email, phone..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full md:w-80"
        />
      </div>

      <div className="rounded-2xl border bg-card shadow-sm overflow-hidden">
        <div className="flex flex-col gap-1 border-b bg-muted/30 px-3 py-3 text-sm text-muted-foreground sm:flex-row sm:items-center sm:justify-between md:px-6">
          <span>{filtered.length} visible users</span>
          <span>20 records per page</span>
        </div>
        <div className="space-y-3 p-3 md:hidden">
          {loading ? (
            Array.from({ length: 4 }).map((_, i) => <UserCardSkeleton key={i} />)
          ) : error ? (
            <EmptyState
              icon={<UsersIcon className="h-5 w-5" />}
              title="Could not load users"
              description={error}
              action={
                <Button variant="outline" onClick={loadUsers}>
                  Retry
                </Button>
              }
            />
          ) : filtered.length === 0 ? (
            <EmptyState
              icon={<UsersIcon className="h-5 w-5" />}
              title={search ? 'No users match your search' : 'No users yet'}
              description={
                search
                  ? 'Try adjusting the search term.'
                  : 'New users will appear here once they sign up.'
              }
            />
          ) : (
            filtered.map((u) => <UserCard key={u.userId} user={u} />)
          )}
        </div>
        <div className="hidden overflow-x-auto md:block">
          <table className="w-full min-w-[760px]">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Name
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Email
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Phone
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Role
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Status
              </th>
              <th className="text-left px-6 py-3 text-xs font-medium text-muted-foreground uppercase">
                Joined
              </th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <tr key={`sk-${i}`}>
                  {Array.from({ length: 6 }).map((__, j) => (
                    <td key={j} className="px-6 py-4">
                      <Skeleton className="h-4 w-24" />
                    </td>
                  ))}
                </tr>
              ))
            ) : error ? (
              <tr>
                <td colSpan={6}>
                  <EmptyState
                    icon={<UsersIcon className="h-5 w-5" />}
                    title="Could not load users"
                    description={error}
                    action={
                      <Button variant="outline" onClick={loadUsers}>
                        Retry
                      </Button>
                    }
                  />
                </td>
              </tr>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan={6}>
                  <EmptyState
                    icon={<UsersIcon className="h-5 w-5" />}
                    title={search ? 'No users match your search' : 'No users yet'}
                    description={
                      search
                        ? 'Try adjusting the search term.'
                        : 'New users will appear here once they sign up.'
                    }
                  />
                </td>
              </tr>
            ) : (
              filtered.map((u) => (
                <tr key={u.userId} className="hover:bg-muted/30">
                  <td className="px-6 py-4">
                    {u.firstName} {u.lastName}
                  </td>
                  <td className="px-6 py-4 text-muted-foreground">{u.email}</td>
                  <td className="px-6 py-4 text-muted-foreground">{u.phone}</td>
                  <td className="px-6 py-4">
                    <Badge variant="info">{u.role}</Badge>
                  </td>
                  <td className="px-6 py-4">
                    <StatusBadge status={u.status} />
                  </td>
                  <td className="px-6 py-4 text-muted-foreground text-sm">
                    {u.createdAt ? new Date(u.createdAt).toLocaleDateString() : '-'}
                  </td>
                </tr>
              ))
            )}
          </tbody>
          </table>
        </div>
      </div>

      <div className="flex justify-center gap-2">
        <Button
          variant="outline"
          disabled={page <= 1}
          onClick={() => setPage((p) => p - 1)}
        >
          Previous
        </Button>
        <span className="px-4 py-2 text-sm">Page {page}</span>
        <Button variant="outline" onClick={() => setPage((p) => p + 1)}>
          Next
        </Button>
      </div>
    </div>
  )
}

function UserCard({ user }: { user: User }) {
  return (
    <div className="rounded-xl border bg-background p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="truncate font-semibold">
            {user.firstName} {user.lastName}
          </p>
          <p className="truncate text-sm text-muted-foreground">{user.email}</p>
        </div>
        <StatusBadge status={user.status} />
      </div>
      <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
        <div>
          <p className="text-xs text-muted-foreground">Phone</p>
          <p className="font-medium">{user.phone}</p>
        </div>
        <div>
          <p className="text-xs text-muted-foreground">Role</p>
          <Badge variant="info" className="mt-1">
            {user.role}
          </Badge>
        </div>
        <div className="col-span-2">
          <p className="text-xs text-muted-foreground">Joined</p>
          <p className="font-medium">
            {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : '-'}
          </p>
        </div>
      </div>
    </div>
  )
}

function UserCardSkeleton() {
  return (
    <div className="rounded-xl border bg-background p-4 shadow-sm">
      <Skeleton className="h-5 w-32" />
      <Skeleton className="mt-2 h-4 w-48" />
      <div className="mt-4 grid grid-cols-2 gap-3">
        <Skeleton className="h-10 w-full" />
        <Skeleton className="h-10 w-full" />
      </div>
    </div>
  )
}

function StatusBadge({ status }: { status: string }) {
  const variant: Record<string, 'success' | 'destructive' | 'secondary' | 'warning'> = {
    ACTIVE: 'success',
    SUSPENDED: 'destructive',
    INACTIVE: 'secondary',
    PENDING_VERIFICATION: 'warning',
  }
  return <Badge variant={variant[status] ?? 'secondary'}>{status}</Badge>
}
