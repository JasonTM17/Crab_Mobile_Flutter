jest.mock('bcrypt', () => ({
  hash: jest.fn(async (value: string) => `hashed:${value}`),
  compare: jest.fn(async (value: string, hash: string) => hash === `hashed:${value}`),
}))

import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { JwtService } from '@nestjs/jwt'
import { ConfigService } from '@nestjs/config'
import {
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common'
import * as bcrypt from 'bcrypt'
import { AuthService } from './auth.service'
import { UserEntity } from './entities/user.entity'
import { RefreshTokenEntity } from './entities/refresh-token.entity'
import { LoginAttemptEntity } from './entities/login-attempt.entity'
import { OtpService } from './services/otp.service'
import { SessionService } from './services/session.service'

describe('AuthService', () => {
  let service: AuthService

  const mockUserRepo = {
    findOne: jest.fn(),
    create: jest.fn((x) => x),
    save: jest.fn(async (x) => x),
    update: jest.fn(),
  }
  const mockRefreshTokenRepo = {
    findOne: jest.fn(),
    create: jest.fn((x) => x),
    save: jest.fn(async (x) => x),
    update: jest.fn(),
  }
  const mockLoginAttemptRepo = {
    create: jest.fn((x) => x),
    save: jest.fn(async (x) => x),
  }
  const mockJwt = { sign: jest.fn().mockReturnValue('signed-token') }
  const mockConfig = {
    get: jest.fn((key: string) => {
      if (key === 'NODE_ENV') return 'test'
      if (key === 'JWT_REFRESH_SECRET') return 'test-refresh-secret'
      return undefined
    }),
  }
  const mockOtp = { generate: jest.fn(), verify: jest.fn() }
  const mockSession = {
    resetLoginAttempts: jest.fn(),
    deleteAllUserSessions: jest.fn(),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(UserEntity), useValue: mockUserRepo },
        {
          provide: getRepositoryToken(RefreshTokenEntity),
          useValue: mockRefreshTokenRepo,
        },
        {
          provide: getRepositoryToken(LoginAttemptEntity),
          useValue: mockLoginAttemptRepo,
        },
        { provide: JwtService, useValue: mockJwt },
        { provide: ConfigService, useValue: mockConfig },
        { provide: OtpService, useValue: mockOtp },
        { provide: SessionService, useValue: mockSession },
      ],
    }).compile()

    service = module.get<AuthService>(AuthService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('register', () => {
    it('throws ConflictException when email or phone already exists', async () => {
      mockUserRepo.findOne.mockResolvedValueOnce({ id: 'existing' })
      await expect(
        service.register({
          email: 'a@b.co',
          phone: '+10000000000',
          password: 'secret123',
          firstName: 'A',
          lastName: 'B',
        } as never),
      ).rejects.toThrow(ConflictException)
    })

    it('stores a hashed password and returns token bundle', async () => {
      mockUserRepo.findOne.mockResolvedValueOnce(null)

      const result = await service.register({
        email: 'new@b.co',
        phone: '+10000000001',
        password: 'secret123',
        firstName: 'A',
        lastName: 'B',
      } as never)

      expect(mockUserRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'new@b.co',
          phone: '+10000000001',
          passwordHash: expect.any(String),
          firstName: 'A',
          lastName: 'B',
        }),
      )
      expect(mockUserRepo.create.mock.calls[0][0].passwordHash).not.toBe('secret123')
      expect(bcrypt.hash).toHaveBeenCalledWith('secret123', 12)
      expect(result).toEqual(
        expect.objectContaining({
          requiresPhoneVerification: true,
          user: expect.objectContaining({
            email: 'new@b.co',
            phone: '+10000000001',
            firstName: 'A',
            lastName: 'B',
            role: 'RIDER',
            status: 'PENDING_VERIFICATION',
          }),
          tokens: expect.objectContaining({
            access_token: 'signed-token',
            refresh_token: 'signed-token',
          }),
        }),
      )
    })
  })

  describe('changePassword', () => {
    it('accepts the current password and stores a new hash', async () => {
      const originalHash = 'hashed:old-pass'
      mockUserRepo.findOne.mockResolvedValueOnce({
        id: 'user-1',
        passwordHash: originalHash,
      })

      await expect(
        service.changePassword('user-1', {
          currentPassword: 'old-pass',
          newPassword: 'new-pass',
        } as never),
      ).resolves.toEqual({ success: true })

      expect(bcrypt.compare).toHaveBeenCalledWith('old-pass', originalHash)
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        'user-1',
        expect.objectContaining({ passwordHash: expect.any(String) }),
      )
      expect(mockUserRepo.update.mock.calls[0][1].passwordHash).toBe('hashed:new-pass')
    })
  })

  describe('login', () => {
    it('throws UnauthorizedException when user not found', async () => {
      // checkAccountLock then findOne both return null
      mockUserRepo.findOne.mockResolvedValueOnce(null)
      mockUserRepo.findOne.mockResolvedValueOnce(null)
      await expect(
        service.login({ email: 'missing@b.co', password: 'x' } as never),
      ).rejects.toThrow(UnauthorizedException)
    })
  })

  describe('refresh', () => {
    it('throws UnauthorizedException when refresh token is unknown', async () => {
      mockRefreshTokenRepo.findOne.mockResolvedValueOnce(null)
      await expect(service.refresh('unknown-token')).rejects.toThrow(
        UnauthorizedException,
      )
    })
  })

  describe('logoutAll', () => {
    it('revokes all refresh tokens and deletes all sessions', async () => {
      await service.logoutAll('user-1')
      expect(mockRefreshTokenRepo.update).toHaveBeenCalledWith(
        { userId: 'user-1' },
        { revoked: true },
      )
      expect(mockSession.deleteAllUserSessions).toHaveBeenCalledWith('user-1')
    })
  })
})
