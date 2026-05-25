import 'reflect-metadata'
import { AccessLogMiddleware } from './access-log.middleware'

describe('AccessLogMiddleware dependency metadata', () => {
  it('does not advertise constructor dependencies to Nest', () => {
    const params =
      Reflect.getMetadata('design:paramtypes', AccessLogMiddleware) ?? []

    expect(params).toHaveLength(0)
  })
})
