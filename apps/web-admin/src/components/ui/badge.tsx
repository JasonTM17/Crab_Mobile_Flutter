import * as React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const badgeVariants = cva(
  'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
  {
    variants: {
      variant: {
        default:
          'border-transparent bg-primary text-primary-foreground hover:bg-primary/80',
        secondary:
          'border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80',
        success:
          'border-transparent bg-emerald-100 text-emerald-800 hover:bg-emerald-100/80 dark:bg-emerald-500/20 dark:text-emerald-300',
        warning:
          'border-transparent bg-amber-100 text-amber-800 hover:bg-amber-100/80 dark:bg-amber-500/20 dark:text-amber-300',
        info: 'border-transparent bg-blue-100 text-blue-800 hover:bg-blue-100/80 dark:bg-blue-500/20 dark:text-blue-300',
        destructive:
          'border-transparent bg-rose-100 text-rose-800 hover:bg-rose-100/80 dark:bg-rose-500/20 dark:text-rose-300',
        outline: 'text-foreground',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  },
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  )
}

export { Badge, badgeVariants }
