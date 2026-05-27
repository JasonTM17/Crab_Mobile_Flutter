import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Logo } from '@/components/ui/logo'
import { useAuth } from '@/hooks/useAuth'

export default function Login() {
  const navigate = useNavigate()
  const { loginMutation, isAuthenticated } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<{ email?: string; password?: string }>(
    {},
  )

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
    <div className="min-h-screen bg-slate-950 p-4 text-slate-950">
      <div className="mx-auto grid min-h-[calc(100vh-2rem)] w-full max-w-6xl overflow-hidden rounded-lg bg-white shadow-2xl shadow-slate-950/30 lg:grid-cols-[1.1fr_0.9fr]">
        <section className="hidden flex-col justify-between bg-emerald-700 p-10 text-white lg:flex">
          <div className="flex items-center gap-2">
            <Logo size="md" showText={false} className="text-white" />
            <span className="text-xl font-bold tracking-tight">Crab</span>
          </div>
          <div className="space-y-5">
            <div className="inline-flex rounded-full border border-white/20 bg-white/10 px-4 py-2 text-sm font-medium">
              Crab operations console
            </div>
            <div className="space-y-4">
              <h1 className="max-w-xl text-5xl font-bold tracking-tight">
                Control rides, food orders, and wallet activity from one desk.
              </h1>
              <p className="max-w-lg text-lg leading-8 text-emerald-50">
                Monitor live demand, approve drivers, review payments, and keep
                marketplace operations moving with a focused admin workspace.
              </p>
            </div>
          </div>
          <div className="grid grid-cols-3 gap-3 text-sm">
            {['Live metrics', 'Driver ops', 'Wallet audit'].map((item) => (
              <div
                key={item}
                className="rounded-lg border border-white/15 bg-white/10 p-4 font-semibold text-emerald-50"
              >
                {item}
              </div>
            ))}
          </div>
        </section>

        <div className="flex items-center justify-center bg-slate-50 p-5 sm:p-8">
          <Card className="w-full max-w-md border-slate-200 bg-white shadow-xl shadow-slate-950/10">
            <CardHeader className="space-y-1">
              <div className="mb-2 flex items-center justify-center">
                <Logo size="lg" />
              </div>
              <CardTitle className="text-center text-2xl">
                Admin Portal
              </CardTitle>
              <CardDescription className="text-center">
                Sign in to manage Crab operations
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4" noValidate>
                <div className="space-y-1">
                  <label
                    htmlFor="email"
                    className="text-sm font-medium leading-none"
                  >
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
                  <label
                    htmlFor="password"
                    className="text-sm font-medium leading-none"
                  >
                    Password
                  </label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="********"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    aria-describedby={
                      errors.password ? 'password-error' : undefined
                    }
                    aria-invalid={!!errors.password}
                    disabled={loginMutation.isPending}
                  />
                  {errors.password && (
                    <p
                      id="password-error"
                      className="text-sm text-destructive"
                    >
                      {errors.password}
                    </p>
                  )}
                </div>

                {loginMutation.isError && (
                  <p
                    className="text-center text-sm text-destructive"
                    role="alert"
                  >
                    Invalid email or password. Please try again.
                  </p>
                )}

                <Button
                  type="submit"
                  className="w-full"
                  disabled={loginMutation.isPending}
                >
                  {loginMutation.isPending ? 'Signing in...' : 'Sign in'}
                </Button>
              </form>
              <div className="mt-5 rounded-lg border border-primary/15 bg-primary/5 p-3 text-xs text-muted-foreground">
                Admin access is role-gated. Contact the platform owner if your
                account cannot sign in.
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
