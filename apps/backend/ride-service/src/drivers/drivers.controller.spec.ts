import { BadRequestException } from '@nestjs/common'
import { DriversController } from './drivers.controller'
import { DriverStatus } from './schemas/driver-location.schema'

type HeaderAwareDriversController = {
  goOnline(authenticatedDriverId: string | undefined, body: { driverId?: string }): Promise<unknown>
  goOffline(authenticatedDriverId: string | undefined, body: { driverId?: string }): Promise<unknown>
  updateLocation(
    authenticatedDriverId: string | undefined,
    body: { driverId?: string; latitude?: number; longitude?: number },
  ): Promise<unknown>
}

describe('DriversController identity', () => {
  const service = {
    setDriverStatus: jest.fn(),
    updateLocation: jest.fn(),
  }

  let controller: DriversController
  let headerAwareController: HeaderAwareDriversController

  beforeEach(() => {
    jest.clearAllMocks()
    controller = new DriversController(service as never)
    headerAwareController = controller as unknown as HeaderAwareDriversController
  })

  it('rejects online requests without authenticated driver context', async () => {
    await expect(
      headerAwareController.goOnline(undefined, { driverId: 'drv-1' }),
    ).rejects.toThrow(BadRequestException)
    expect(service.setDriverStatus).not.toHaveBeenCalled()
  })

  it('rejects online requests for a different driver', async () => {
    await expect(
      headerAwareController.goOnline('drv-1', { driverId: 'drv-2' }),
    ).rejects.toThrow(BadRequestException)
    expect(service.setDriverStatus).not.toHaveBeenCalled()
  })

  it('uses the authenticated driver when going online', async () => {
    await headerAwareController.goOnline('drv-1', { driverId: 'drv-1' })

    expect(service.setDriverStatus).toHaveBeenCalledWith('drv-1', DriverStatus.ONLINE)
  })

  it('uses the authenticated driver when going offline', async () => {
    await headerAwareController.goOffline('drv-1', { driverId: 'drv-1' })

    expect(service.setDriverStatus).toHaveBeenCalledWith('drv-1', DriverStatus.OFFLINE)
  })

  it('uses the authenticated driver when updating location', async () => {
    await headerAwareController.updateLocation('drv-1', {
      driverId: 'drv-1',
      latitude: 10,
      longitude: 20,
    })

    expect(service.updateLocation).toHaveBeenCalledWith(
      'drv-1',
      10,
      20,
      DriverStatus.ONLINE,
    )
  })
})
