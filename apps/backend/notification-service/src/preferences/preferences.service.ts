import { Injectable } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import {
  NotificationPreferences,
  PreferencesDocument,
} from './schemas/preferences.schema'

@Injectable()
export class PreferencesService {
  constructor(
    @InjectModel(NotificationPreferences.name)
    private readonly model: Model<PreferencesDocument>,
  ) {}

  async getOrCreate(userId: string) {
    let p = await this.model.findOne({ userId })
    if (!p) p = await this.model.create({ userId })
    return p
  }

  async update(userId: string, updates: Partial<NotificationPreferences>) {
    return this.model.findOneAndUpdate({ userId }, updates, { new: true, upsert: true })
  }

  async addFcmToken(userId: string, token: string) {
    return this.model.findOneAndUpdate(
      { userId },
      { $addToSet: { fcmTokens: token } },
      { new: true, upsert: true },
    )
  }

  async removeFcmToken(userId: string, token: string) {
    return this.model.findOneAndUpdate(
      { userId },
      { $pull: { fcmTokens: token } },
      { new: true },
    )
  }
}
