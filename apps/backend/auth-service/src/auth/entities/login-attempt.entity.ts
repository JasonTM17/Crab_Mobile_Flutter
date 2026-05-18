import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm'

@Entity('login_attempts')
@Index(['identifier', 'createdAt'])
export class LoginAttemptEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  identifier!: string // email or phone

  @Column()
  ip!: string

  @Column({ default: false })
  success!: boolean

  @Column({ nullable: true })
  userAgent?: string

  @CreateDateColumn()
  createdAt!: Date
}
