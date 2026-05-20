import { Test, TestingModule } from '@nestjs/testing'
import { INestApplication, ValidationPipe } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
// eslint-disable-next-line @typescript-eslint/no-require-imports
const request = require('supertest')

import { WalletEntity } from '../../src/wallet/entities/wallet.entity'
import {
  TransactionEntity,
  TransactionStatus,
  TransactionType,
} from '../../src/transactions/entities/transaction.entity'
import {
  PromoEntity,
  PromoUsageEntity,
} from '../../src/promo/entities/promo.entity'
import { WalletModule } from '../../src/wallet/wallet.module'

/**
 * End-to-end happy + race-condition coverage for wallet operations.
 *
 * Stack:
 *   - sqlite in-memory via better-sqlite3 (no external Postgres needed)
 *   - real WalletService + TransactionsService with their TypeORM repos
 *   - supertest HTTP probe of the controller
 *
 * What we cover:
 *   1. Top-up increases balance, writes a COMPLETED transaction
 *   2. Transfer between two users moves funds atomically
 *   3. Insufficient balance is rejected with 400
 *   4. Self-transfer is rejected
 *   5. Concurrent transfers in opposite directions don't deadlock and
 *      end with a consistent total balance (no double-spend)
 */
describe('Wallet E2E', () => {
  let app: INestApplication
  let userA: string
  let userB: string

  beforeAll(async () => {
    userA = '11111111-1111-1111-1111-111111111111'
    userB = '22222222-2222-2222-2222-222222222222'

    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'better-sqlite3',
          database: ':memory:',
          dropSchema: true,
          synchronize: true,
          entities: [
            WalletEntity,
            TransactionEntity,
            PromoEntity,
            PromoUsageEntity,
          ],
        }),
        WalletModule,
      ],
    }).compile()

    app = moduleRef.createNestApplication()
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    )
    await app.init()
  })

  afterAll(async () => {
    await app?.close()
  })

  it('GET /wallet/:userId auto-creates a zero balance wallet', async () => {
    const res = await request(app.getHttpServer())
      .get(`/wallet/${userA}`)
      .expect(200)
    expect(res.body).toMatchObject({
      userId: userA,
      balance: 0,
      pendingBalance: 0,
      currency: 'VND',
      frozen: false,
    })
  })

  it('POST /wallet/:userId/top-up credits balance and writes a tx', async () => {
    const res = await request(app.getHttpServer())
      .post(`/wallet/${userA}/top-up`)
      .send({ amount: 200000, paymentMethod: 'bank_transfer' })
      .expect(201)

    expect(res.body).toMatchObject({
      userId: userA,
      type: TransactionType.TOP_UP,
      status: TransactionStatus.COMPLETED,
      amount: 200000,
    })

    const balRes = await request(app.getHttpServer())
      .get(`/wallet/${userA}`)
      .expect(200)
    expect(balRes.body.balance).toBe(200000)
  })

  it('POST /wallet/:fromUserId/transfer moves funds atomically', async () => {
    // Top up B too so we have known starting state
    await request(app.getHttpServer())
      .post(`/wallet/${userB}/top-up`)
      .send({ amount: 50000, paymentMethod: 'bank_transfer' })
      .expect(201)

    const res = await request(app.getHttpServer())
      .post(`/wallet/${userA}/transfer`)
      .send({ toUserId: userB, amount: 30000, note: 'test' })
      .expect(201)

    expect(res.body).toMatchObject({
      userId: userA,
      type: TransactionType.TRANSFER_OUT,
      amount: -30000,
    })

    const a = await request(app.getHttpServer()).get(`/wallet/${userA}`)
    const b = await request(app.getHttpServer()).get(`/wallet/${userB}`)
    expect(a.body.balance).toBe(170000)
    expect(b.body.balance).toBe(80000)
  })

  it('rejects transfer when balance is insufficient', async () => {
    await request(app.getHttpServer())
      .post(`/wallet/${userA}/transfer`)
      .send({ toUserId: userB, amount: 999999999 })
      .expect(400)
  })

  it('rejects self-transfer', async () => {
    await request(app.getHttpServer())
      .post(`/wallet/${userA}/transfer`)
      .send({ toUserId: userA, amount: 1000 })
      .expect(400)
  })

  it('preserves total balance under concurrent opposite transfers', async () => {
    // Snapshot the pair total. After 10 concurrent transfers in mixed
    // directions of equal amount, total must be unchanged and no balance
    // can dip below 0.
    const a0 = (await request(app.getHttpServer()).get(`/wallet/${userA}`))
      .body.balance
    const b0 = (await request(app.getHttpServer()).get(`/wallet/${userB}`))
      .body.balance
    const total0 = a0 + b0

    const moves = Array.from({ length: 10 }, (_, i) =>
      i % 2 === 0
        ? request(app.getHttpServer())
            .post(`/wallet/${userA}/transfer`)
            .send({ toUserId: userB, amount: 5000 })
        : request(app.getHttpServer())
            .post(`/wallet/${userB}/transfer`)
            .send({ toUserId: userA, amount: 5000 }),
    )
    const results = await Promise.all(moves)
    for (const r of results) {
      expect([201, 400]).toContain(r.status)
    }

    const a1 = (await request(app.getHttpServer()).get(`/wallet/${userA}`))
      .body.balance
    const b1 = (await request(app.getHttpServer()).get(`/wallet/${userB}`))
      .body.balance
    expect(a1 + b1).toBe(total0)
    expect(a1).toBeGreaterThanOrEqual(0)
    expect(b1).toBeGreaterThanOrEqual(0)
  })
})
