import 'reflect-metadata'

describe('MatchingQueueService queue token wiring', () => {
  it('keeps the named queue token when the module loads first', () => {
    jest.resetModules()

    jest.isolateModules(() => {
      const { getQueueToken } = require('@nestjs/bull')
      const { SELF_DECLARED_DEPS_METADATA } = require('@nestjs/common/constants')

      require('./matching-queue.module')
      const { MatchingQueueService } = require('./matching-queue.service')

      const deps = Reflect.getMetadata(SELF_DECLARED_DEPS_METADATA, MatchingQueueService) ?? []

      expect(deps[0]?.param).toBe(getQueueToken('ride-matching'))
    })
  })
})
