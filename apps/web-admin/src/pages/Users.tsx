import { useEffect, useState } from 'react'
import api from '@/lib/axios'

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
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  useEffect(() => {
    loadUsers()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page])

  async function loadUsers() {
    setLoading(true)
    try {
      const res = await api.get(`/profiles?page=${page}&limit=20`)
      setUsers(res.data.data ?? res.data ?? [])
    } catch (e) {
      console.error(e)
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
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Users</h1>
        <input
          type="text"
          placeholder="Search by name, email, phone..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="px-4 py-2 border rounded-lg w-80 bg-background"
        />
      </div>

      <div className="bg-card rounded-lg shadow border overflow-hidden">
        <table className="w-full">
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
              <tr>
                <td colSpan={6} className="text-center py-8">
                  Loading...
                </td>
              </tr>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan={6} className="text-center py-8 text-muted-foreground">
                  No users found
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
                    <span className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                      {u.role}
                    </span>
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

      <div className="flex justify-center gap-2">
        <button
          disabled={page <= 1}
          onClick={() => setPage((p) => p - 1)}
          className="px-4 py-2 border rounded-lg disabled:opacity-50"
        >
          Previous
        </button>
        <span className="px-4 py-2">Page {page}</span>
        <button
          onClick={() => setPage((p) => p + 1)}
          className="px-4 py-2 border rounded-lg"
        >
          Next
        </button>
      </div>
    </div>
  )
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    ACTIVE: 'bg-green-100 text-green-800',
    SUSPENDED: 'bg-red-100 text-red-800',
    INACTIVE: 'bg-gray-100 text-gray-800',
    PENDING_VERIFICATION: 'bg-yellow-100 text-yellow-800',
  }
  return (
    <span className={`px-2 py-1 text-xs rounded ${colors[status] ?? 'bg-gray-100'}`}>
      {status}
    </span>
  )
}
