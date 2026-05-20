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
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
        className={cn(dim.box, 'shrink-0')}
        aria-hidden="true"
      >
        {/* Body */}
        <ellipse cx="24" cy="28" rx="14" ry="10" />
        {/* Eyes */}
        <circle cx="19" cy="22" r="2.2" fill="white" />
        <circle cx="29" cy="22" r="2.2" fill="white" />
        <circle cx="19" cy="22" r="1" fill="currentColor" />
        <circle cx="29" cy="22" r="1" fill="currentColor" />
        {/* Left pincer */}
        <path d="M6 20 L12 26 L8 30 L4 26 Z" />
        <path d="M6 20 Q2 18 4 14 L8 17 Z" />
        {/* Right pincer */}
        <path d="M42 20 L36 26 L40 30 L44 26 Z" />
        <path d="M42 20 Q46 18 44 14 L40 17 Z" />
        {/* Legs */}
        <path
          d="M11 32 L7 38 M14 36 L11 42 M37 32 L41 38 M34 36 L37 42"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
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
