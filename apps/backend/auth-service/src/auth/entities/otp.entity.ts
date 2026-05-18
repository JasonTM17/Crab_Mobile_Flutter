import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm'

export enum OtpPurpose {
  PHONE_VERIFY = 'PHONE_VERIFY',
  LOGIN = 'LOGIN',
  PASSWORD_RESET = 'PASSWORD_RESET',
}

@Entity('otps')
@Index(['phone', 'purpose'])
export class OtpEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  phone!: string

  @Column()
  code!: string

  @Column({ type: 'enum', enum: OtpPurpose })
  purpose!: OtpPurpose

  @Column({ default: 0 })
  attempts!: number

  @Column({ default: false })
  verified!: boolean

  @Column()
  expiresAt!: Date

  @CreateDateColumn()
  createdAt!: Date
}
