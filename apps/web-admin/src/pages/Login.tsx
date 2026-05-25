import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Logo } from '@/components/ui/logo'
import { useAuth } from '@/hooks/useAuth'

export default function Login() {
  const navigate = useNavigate()
  const { loginMutation, isAuthenticated } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<{ email?: string; password?: string }>({})

  if (isAuthenticated) {
    navigate('/dashboard', { replace: true })
    return null
  }

  const validate = () => {
    const newErrors: { email?: string; password?: string } = {}
    if (!email) {
      newErrors.email = 'Email is required'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = 'Enter a valid email address'
    }
    if (!password) {
      newErrors.password = 'Password is required'
    } else if (password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters'
    }
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return
    loginMutation.mutate(
      { email, password },
      {
        onError: (err: Error) => {
          if (err.message?.includes('admin')) {
            toast.error('Access denied', {
              description: 'This account does not have admin privileges.',
            })
          } else {
            toast.error('Login failed', {
              description: 'Invalid email or password. Please try again.',
            })
          }
        },
      },
    )
  }

  return (
    <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-emerald-50 via-white to-green-100 p-4">
      <div className="pointer-events-none absolute -right-24 -top-24 h-80 w-80 rounded-full bg-primary/15 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-24 left-8 h-72 w-72 rounded-full bg-emerald-300/20 blur-3xl" />

      <div className="relative mx-auto flex min-h-screen w-full max-w-6xl items-center justify-center gap-10 lg:justify-between">
        <section className="hidden max-w-xl space-y-6 lg:block">
          <div className="inline-flex rounded-full border border-primary/20 bg-white/70 px-4 py-2 text-sm font-medium text-primary shadow-sm backdrop-blur">
            Crab Super App Operations
          </div>
          <div className="space-y-4">
            <h1 className="text-5xl font-bold tracking-tight text-slate-950">
              Control rides, food orders and payments from one command center.
            </h1>
            <p className="text-lg text-slate-600">
              Monitor live demand, approve drivers and broadcast updates with a polished admin experience.
            </p>
          </div>
          <div className="grid grid-cols-3 gap-3 text-sm">
            {['Live metrics', 'Driver ops', 'Wallet audit'].map((item) => (
              <div key={item} className="rounded-2xl border bg-white/75 p-4 font-semibold text-slate-700 shadow-sm backdrop-blur">
                {item}
              </div>
            ))}
          </div>
        </section>

        <Card className="w-full max-w-md border-white/70 bg-white/85 shadow-2xl shadow-emerald-950/10 backdrop-blur-xl">
          <CardHeader className="space-y-1">
            <div className="flex items-center justify-center mb-2">
              <Logo size="lg" />
            </div>
            <CardTitle className="text-2xl text-center">Admin Portal</CardTitle>
            <CardDescription className="text-center">
              Sign in to manage Crab operations
            </CardDescription>
          </CardHeader>
          <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4" noValidate>
            <div className="space-y-1">
              <label htmlFor="email" className="text-sm font-medium leading-none">
                Email
              </label>
              <Input
                id="email"
                type="email"
                placeholder="admin@crab.app"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                aria-describedby={errors.email ? 'email-error' : undefined}
                aria-invalid={!!errors.email}
                disabled={loginMutation.isPending}
              />
              {errors.email && (
                <p id="email-error" className="text-sm text-destructive">
                  {errors.email}
                </p>
              )}
            </div>

            <div className="space-y-1">
              <label htmlFor="password" className="text-sm font-medium leading-none">
                Password
              </label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                aria-describedby={errors.password ? 'password-error' : undefined}
                aria-invalid={!!errors.password}
                disabled={loginMutation.isPending}
              />
              {errors.password && (
                <p id="password-error" className="text-sm text-destructive">
                  {errors.password}
                </p>
              )}
            </div>

            {loginMutation.isError && (
              <p className="text-sm text-destructive text-center" role="alert">
                Invalid email or password. Please try again.
              </p>
            )}

            <Button type="submit" className="w-full" disabled={loginMutation.isPending}>
              {loginMutation.isPending ? 'Signing in…' : 'Sign in'}
            </Button>
          </form>
          <div className="mt-5 rounded-xl border border-primary/15 bg-primary/5 p-3 text-xs text-muted-foreground">
            Admin access is role-gated. Contact the platform owner if your account cannot sign in.
          </div>
          {import.meta.env.DEV && (
            <p className="mt-3 text-center text-xs text-muted-foreground">
              Dev hint: use a seeded ADMIN or SUPER_ADMIN account.
            </p>
          )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
