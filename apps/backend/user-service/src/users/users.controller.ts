import {
  Controller,
  Get,
  Patch,
  Post,
  Param,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseUUIDPipe,
  BadRequestException,
} from '@nestjs/common'
import { FileInterceptor } from '@nestjs/platform-express'
import { AuthGuard } from '@nestjs/passport'
import { UsersService } from './users.service'
import { UpdateProfileDto } from './dto/update-profile.dto'
import { CurrentUser } from './decorators/current-user.decorator'
import { UserEntity } from './entities/user.entity'

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp']
const MAX_FILE_SIZE = 5 * 1024 * 1024

@Controller('users')
@UseGuards(AuthGuard('jwt'))
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  getProfile(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.getProfile(id)
  }

  @Patch(':id')
  updateProfile(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProfileDto,
    @CurrentUser() user: UserEntity,
  ) {
    return this.usersService.updateProfile(id, user.id, dto)
  }

  @Post(':id/avatar')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: MAX_FILE_SIZE },
      fileFilter: (_req, file, cb) => {
        if (ALLOWED_MIME_TYPES.includes(file.mimetype)) {
          cb(null, true)
        } else {
          cb(new BadRequestException('Only JPEG, PNG, and WebP images are allowed'), false)
        }
      },
    }),
  )
  uploadAvatar(
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: UserEntity,
  ) {
    if (!file) {
      throw new BadRequestException('No file uploaded')
    }
    return this.usersService.uploadAvatar(id, user.id, file.buffer, file.mimetype)
  }
}
