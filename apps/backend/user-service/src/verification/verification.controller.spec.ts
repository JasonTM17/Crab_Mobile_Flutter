import { ForbiddenException, UnauthorizedException } from '@nestjs/common'
import { VerificationController } from './verification.controller'

type HeaderAwareVerificationController = {
  approveDriver(authRole: string | undefined, userId: string): unknown
  rejectDriver(
    authRole: string | undefined,
    userId: string,
    reason: string,
  ): unknown
  listPending(authRole: string | undefined, page?: string, limit?: string): unknown
  approveMerchant(authRole: string | undefined, userId: string): unknown
  rejectMerchant(
    authRole: string | undefined,
    userId: string,
    reason: string,
  ): unknown
  verifyDoc(
    authRole: string | undefined,
    adminId: string | undefined,
    docId: string,
  ): unknown
}

describe('VerificationController admin access', () => {
  const service = {
    registerDriver: jest.fn(),
    getDriverProfile: jest.fn(),
    approveDriver: jest.fn(),
    rejectDriver: jest.fn(),
    setDriverOnline: jest.fn(),
    listPendingDrivers: jest.fn(),
    registerMerchant: jest.fn(),
    getMerchantProfile: jest.fn(),
    approveMerchant: jest.fn(),
    rejectMerchant: jest.fn(),
    uploadDocument: jest.fn(),
    getUserDocuments: jest.fn(),
    verifyDocument: jest.fn(),
  }

  let controller: VerificationController
  let headerAwareController: HeaderAwareVerificationController

  beforeEach(() => {
    jest.clearAllMocks()
    controller = new VerificationController(service as never)
    headerAwareController = controller as unknown as HeaderAwareVerificationController
  })

  it('rejects driver approval without an admin role', () => {
    expect(() => headerAwareController.approveDriver(undefined, 'user-1')).toThrow(
      UnauthorizedException,
    )
    expect(service.approveDriver).not.toHaveBeenCalled()
  })

  it('rejects driver rejection for non-admin users', () => {
    expect(() => headerAwareController.rejectDriver('RIDER', 'user-1', 'bad')).toThrow(
      ForbiddenException,
    )
    expect(service.rejectDriver).not.toHaveBeenCalled()
  })

  it('rejects merchant approval for non-admin users', () => {
    expect(() => headerAwareController.approveMerchant('RIDER', 'user-2')).toThrow(
      ForbiddenException,
    )
    expect(service.approveMerchant).not.toHaveBeenCalled()
  })

  it('rejects merchant rejection without an admin role', () => {
    expect(() => headerAwareController.rejectMerchant(undefined, 'user-1', 'bad')).toThrow(
      UnauthorizedException,
    )
    expect(service.rejectMerchant).not.toHaveBeenCalled()
  })

  it('rejects pending-list access for non-admin users', () => {
    expect(() => headerAwareController.listPending('RIDER', '2', '25')).toThrow(
      ForbiddenException,
    )
    expect(service.listPendingDrivers).not.toHaveBeenCalled()
  })

  it('rejects document verification without an admin role', () => {
    expect(() => headerAwareController.verifyDoc(undefined, 'admin-1', 'doc-1')).toThrow(
      UnauthorizedException,
    )
    expect(service.verifyDocument).not.toHaveBeenCalled()
  })

  it('approves drivers with the user route identity', () => {
    headerAwareController.approveDriver('ADMIN', 'user-1')

    expect(service.approveDriver).toHaveBeenCalledWith('user-1')
  })

  it('approves merchants with the user route identity', () => {
    headerAwareController.approveMerchant('ADMIN', 'user-2')

    expect(service.approveMerchant).toHaveBeenCalledWith('user-2')
  })

  it('lists pending drivers only for admins', () => {
    headerAwareController.listPending('ADMIN', '2', '25')

    expect(service.listPendingDrivers).toHaveBeenCalledWith(2, 25)
  })

  it('uses the authenticated admin when verifying documents', () => {
    headerAwareController.verifyDoc('ADMIN', 'admin-1', 'doc-1')

    expect(service.verifyDocument).toHaveBeenCalledWith('doc-1', 'admin-1')
  })
})
