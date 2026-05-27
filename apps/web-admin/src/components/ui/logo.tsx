import { cn } from '@/lib/utils'

interface LogoProps {
  className?: string
  showText?: boolean
  size?: 'sm' | 'md' | 'lg'
}

const sizeMap = {
  sm: { box: 'h-6 w-6', text: 'text-base' },
  md: { box: 'h-8 w-8', text: 'text-xl' },
  lg: { box: 'h-12 w-12', text: 'text-3xl' },
}

export function Logo({ className, showText = true, size = 'md' }: LogoProps) {
  const dim = sizeMap[size]
  return (
    <span
      className={cn('inline-flex items-center gap-2 text-primary', className)}
    >
      <svg
        viewBox="0 0 48 48"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className={cn(dim.box, 'shrink-0')}
        aria-hidden="true"
      >
        <path
          d="M32 13.5C29.4 11.4 25.9 10.4 22.2 11.1C15.9 12.5 11.2 17.8 11.2 24.2C11.2 30.8 16.2 36.3 22.9 37C27 37.4 31 36.1 34 33.4"
          stroke="currentColor"
          strokeWidth="5.4"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M21.5 24H37"
          stroke="currentColor"
          strokeWidth="5.4"
          strokeLinecap="round"
        />
        <circle cx="38" cy="24" r="2.6" fill="currentColor" />
        <path
          d="M16.2 17L12.4 13.2M16.2 31.4L12.4 35.2M30.7 17L34.5 13.2M30.7 31.4L34.5 35.2"
          stroke="currentColor"
          strokeWidth="2.4"
          strokeLinecap="round"
          opacity="0.72"
        />
      </svg>
      {showText && (
        <span
          className={cn(
            'font-bold tracking-tight text-foreground',
            dim.text,
          )}
        >
          Crab
        </span>
      )}
    </span>
  )
}
