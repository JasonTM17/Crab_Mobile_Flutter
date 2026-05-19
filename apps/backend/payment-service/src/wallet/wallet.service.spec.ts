import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { DataSource } from 'typeorm'
import { WalletService } from './wallet.service'
import { WalletEntity } from './entities/wallet.entity'
import { TransactionEntity } from '../transactions/entities/transaction.entity'

/**
 * Verifies the wallet transfer lock-ordering fix in P1.6.
 * Two transfers in opposite directions on the same wallet pair must NOT
 * deadlock; instead they should serialize because both lock the lower userId
 * first.
 */
describe('WalletService — transfer concurrency', () => {
  let service: WalletService
  const mockDataSource: Partial<DataSource> = {
    transaction: jest.fn(async (cb: any) => {
      const manager = {
        findOne: jest.fn().mockResolvedValue({
          userId: 'u1',
          balance: 1000,
          frozen: false,
          pendingBalance: 0,
        }),
        save: jest.fn(async (x: unknown) => x),
        create: jest.fn((_: unknown, dto: unknown) => dto),
      }
      return cb(manager)
    }),
  }

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WalletService,
        {
          provide: getRepositoryToken(WalletEntity),
          useValue: { findOne: jest.fn(), create: jest.fn(), save: jest.fn(), update: jest.fn() },
        },
        {
          provide: getRepositoryToken(TransactionEntity),
          useValue: { create: jest.fn(), save: jest.fn() },
        },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile()
    service = module.get<WalletService>(WalletService)
  })

  it('rejects self-transfer', async () => {
    await expect(
      service.transfer('u1', { toUserId: 'u1', amount: 100, note: '' } as never),
    ).rejects.toThrow('Cannot transfer to yourself')
  })

  it('locks wallets in deterministic order regardless of direction', async () => {
    // The implementation sorts userIds and locks the lower one first. Whether
    // we transfer u1→u2 or u2→u1, the first findOne lock should be for u1.
    const calls: string[] = []
    const ds: Partial<DataSource> = {
      transaction: jest.fn(async (cb: any) => {
        const manager = {
          findOne: jest.fn(async (_: unknown, opts: { where: { userId: string } }) => {
            calls.push(opts.where.userId)
            return {
              userId: opts.where.userId,
              balance: 1000,
              frozen: false,
              pendingBalance: 0,
            }
          }),
          save: jest.fn(async (x: unknown) => x),
          create: jest.fn((_: unknown, dto: unknown) => dto),
        }
        return cb(manager)
      }),
    }
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WalletService,
        {
          provide: getRepositoryToken(WalletEntity),
          useValue: { findOne: jest.fn(), create: jest.fn(), save: jest.fn(), update: jest.fn() },
        },
        {
          provide: getRepositoryToken(TransactionEntity),
          useValue: { create: jest.fn(), save: jest.fn() },
        },
        { provide: DataSource, useValue: ds },
      ],
    }).compile()
    const svc = module.get<WalletService>(WalletService)

    await svc.transfer('user-b', { toUserId: 'user-a', amount: 50 } as never)
    expect(calls[0]).toBe('user-a')
    expect(calls[1]).toBe('user-b')

    calls.length = 0
    await svc.transfer('user-a', { toUserId: 'user-b', amount: 50 } as never)
    expect(calls[0]).toBe('user-a')
    expect(calls[1]).toBe('user-b')
  })
})
