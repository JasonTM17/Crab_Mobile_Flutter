// Tooltip primitive — minimal CSS-only implementation since
// @radix-ui/react-tooltip is not installed in this project.
// Uses group-hover/focus to show a label without runtime JS.

import * as React from 'react'
import { cn } from '@/lib/utils'

interface TooltipProviderProps {
  children: React.ReactNode
  delayDuration?: number
}

export function TooltipProvider({ children }: TooltipProviderProps) {
  return <>{children}</>
}

interface TooltipProps {
  children: React.ReactNode
}

export function Tooltip({ children }: TooltipProps) {
  return <span className="relative group/tooltip inline-flex">{children}</span>
}

interface TooltipTriggerProps
  extends React.HTMLAttributes<HTMLSpanElement> {
  asChild?: boolean
}

export const TooltipTrigger = React.forwardRef<
  HTMLSpanElement,
  TooltipTriggerProps
>(({ children, className, ...props }, ref) => (
  <span ref={ref} className={cn('inline-flex', className)} {...props}>
    {children}
  </span>
))
TooltipTrigger.displayName = 'TooltipTrigger'

interface TooltipContentProps extends React.HTMLAttributes<HTMLSpanElement> {
  side?: 'top' | 'right' | 'bottom' | 'left'
  sideOffset?: number
}

export const TooltipContent = React.forwardRef<
  HTMLSpanElement,
  TooltipContentProps
>(({ side = 'right', className, children, ...props }, ref) => {
  const positions: Record<NonNullable<TooltipContentProps['side']>, string> = {
    top: 'bottom-full left-1/2 -translate-x-1/2 mb-2',
    right: 'left-full top-1/2 -translate-y-1/2 ml-2',
    bottom: 'top-full left-1/2 -translate-x-1/2 mt-2',
    left: 'right-full top-1/2 -translate-y-1/2 mr-2',
  }
  return (
    <span
      ref={ref}
      role="tooltip"
      className={cn(
        'pointer-events-none absolute z-50 whitespace-nowrap rounded-md border bg-popover px-2.5 py-1.5 text-xs text-popover-foreground shadow-md',
        'opacity-0 group-hover/tooltip:opacity-100 group-focus-within/tooltip:opacity-100',
        'transition-opacity duration-150',
        positions[side],
        className,
      )}
      {...props}
    >
      {children}
    </span>
  )
})
TooltipContent.displayName = 'TooltipContent'
