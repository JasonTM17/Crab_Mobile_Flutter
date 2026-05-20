import { Test, TestingModule } from '@nestjs/testing'
import { ConfigService } from '@nestjs/config'
import { UnauthorizedException } from '@nestjs/common'
import { getRepositoryToken } from '@nestjs/typeorm'
import { JwtStrategy } from './jwt.strategy'
import { UserEntity } from '../entities/user.entity'

describe('JwtStrategy', () => {
  let strategy: JwtStrategy

  const mockUserRepo = {
    findOne: jest.fn(),
  }

  const mockConfig = {
    get: jest.fn().mockReturnValue('test-secret'),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        JwtStrategy,
        { provide: ConfigService, useValue: mockConfig },
        { provide: getRepositoryToken(UserEntity), useValue: mockUserRepo },
      ],
    }).compile()

    strategy = module.get<JwtStrategy>(JwtStrategy)
  })

  it('should be defined', () => {
    expect(strategy).toBeDefined()
  })

  describe('validate', () => {
    it('returns the user when found', async () => {
      const user = { id: 'u-1', email: 'a@b.co' } as UserEntity
      mockUserRepo.findOne.mockResolvedValueOnce(user)

      const result = await strategy.validate({
        sub: 'u-1',
        email: 'a@b.co',
        role: 'RIDER' as never,
      })

      expect(result).toBe(user)
      expect(mockUserRepo.findOne).toHaveBeenCalledWith({ where: { id: 'u-1' } })
    })

    it('throws UnauthorizedException when user does not exist', async () => {
      mockUserRepo.findOne.mockResolvedValueOnce(null)

      await expect(
        strategy.validate({
          sub: 'missing',
          email: 'x@y.co',
          role: 'RIDER' as never,
        }),
      ).rejects.toThrow(UnauthorizedException)
    })
  })
})
