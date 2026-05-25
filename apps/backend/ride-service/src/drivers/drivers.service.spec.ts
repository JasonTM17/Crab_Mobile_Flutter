import { DriversService } from './drivers.service'
import { DriverStatus } from './schemas/driver-location.schema'

describe('DriversService driver id selectors', () => {
  const exec = jest.fn().mockResolvedValue(undefined)
  const findOneAndUpdate = jest.fn().mockReturnValue({ exec })
  const model = { findOneAndUpdate }
  let service: DriversService

  beforeEach(() => {
    jest.clearAllMocks()
    service = new DriversService(model as never)
  })

  it('wraps driver id in an equality selector when changing status', async () => {
    await service.setDriverStatus('drv-1', DriverStatus.ONLINE)

    expect(findOneAndUpdate).toHaveBeenCalledWith(
      { driver_id: { $eq: 'drv-1' } },
      expect.any(Object),
      { upsert: true },
    )
  })

  it('wraps driver id in an equality selector when updating location', async () => {
    await service.updateLocation('drv-1', 10, 20, DriverStatus.ONLINE)

    expect(findOneAndUpdate).toHaveBeenCalledWith(
      { driver_id: { $eq: 'drv-1' } },
      expect.any(Object),
      { upsert: true },
    )
  })
})
