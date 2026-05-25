import { getQueueToken } from '@nestjs/bull'
import { Test } from '@nestjs/testing'

import { NotificationProcessor } from './notification.processor'
import { NOTIFICATION_FANOUT_QUEUE } from './notification-queue.constants'
import { NotificationQueueService } from './notification-queue.service'

describe('notification queue wiring', () => {
  it('injects the named fanout queue into NotificationQueueService', async () => {
    const module = await Test.createTestingModule({
      providers: [
        NotificationQueueService,
        {
          provide: getQueueToken(NOTIFICATION_FANOUT_QUEUE),
          useValue: { add: jest.fn(), addBulk: jest.fn() },
        },
      ],
    }).compile()

    expect(module.get(NotificationQueueService)).toBeInstanceOf(NotificationQueueService)
  })

  it('binds NotificationProcessor to the named fanout queue', () => {
    expect(Reflect.getMetadata('bull:module_queue', NotificationProcessor)).toEqual({
      name: NOTIFICATION_FANOUT_QUEUE,
    })
  })
})
