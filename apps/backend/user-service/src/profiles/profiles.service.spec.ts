import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { NotFoundException } from '@nestjs/common'
import { ProfilesService } from './profiles.service'
import { ProfileEntity } from './entities/profile.entity'

describe('ProfilesService', () => {
  let service: ProfilesService

  const mockRepo = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    findAndCount: jest.fn(),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfilesService,
        { provide: getRepositoryToken(ProfileEntity), useValue: mockRepo },
      ],
    }).compile()

    service = module.get<ProfilesService>(ProfilesService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('findById', () => {
    it('returns a profile when it exists', async () => {
      const profile = { userId: 'u1', firstName: 'Son' } as ProfileEntity
      mockRepo.findOne.mockResolvedValueOnce(profile)
      const result = await service.findById('u1')
      expect(result).toBe(profile)
      expect(mockRepo.findOne).toHaveBeenCalledWith({ where: { userId: 'u1' } })
    })

    it('throws NotFoundException when profile is missing', async () => {
      mockRepo.findOne.mockResolvedValueOnce(null)
      await expect(service.findById('missing')).rejects.toThrow(NotFoundException)
    })
  })

  describe('list', () => {
    it('returns paginated payload with totalPages computed correctly', async () => {
      mockRepo.findAndCount.mockResolvedValueOnce([[{}, {}, {}], 25])
      const result = await service.list(2, 10)
      expect(result.data).toHaveLength(3)
      expect(result.total).toBe(25)
      expect(result.page).toBe(2)
      expect(result.limit).toBe(10)
      expect(result.totalPages).toBe(3)
      expect(mockRepo.findAndCount).toHaveBeenCalledWith({
        skip: 10,
        take: 10,
        order: { createdAt: 'DESC' },
      })
    })
  })

  describe('create', () => {
    it('persists a new profile via the repo', async () => {
      const dto = { userId: 'u2', firstName: 'A', lastName: 'B' } as never
      const created = { ...(dto as object) } as ProfileEntity
      mockRepo.create.mockReturnValueOnce(created)
      mockRepo.save.mockResolvedValueOnce(created)
      const result = await service.create(dto)
      expect(mockRepo.create).toHaveBeenCalledWith(dto)
      expect(mockRepo.save).toHaveBeenCalledWith(created)
      expect(result).toBe(created)
    })
  })
})
