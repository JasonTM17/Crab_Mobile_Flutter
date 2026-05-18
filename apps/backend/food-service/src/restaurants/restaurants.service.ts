import { Injectable } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { Restaurant, RestaurantDocument, RestaurantCategory } from './schemas/restaurant.schema'

@Injectable()
export class RestaurantsService {
  constructor(
    @InjectModel(Restaurant.name)
    private readonly restaurantModel: Model<RestaurantDocument>,
  ) {}

  async findNearby(lat: number, lng: number, radiusKm = 5, category?: RestaurantCategory) {
    const filter: any = {
      location: {
        $nearSphere: {
          $geometry: { type: 'Point', coordinates: [lng, lat] },
          $maxDistance: radiusKm * 1000,
        },
      },
    }
    if (category) filter.category = category
    return this.restaurantModel.find(filter).limit(50).exec()
  }

  async findById(id: string) {
    return this.restaurantModel.findById(id).exec()
  }

  async create(data: Partial<Restaurant>) {
    return this.restaurantModel.create(data)
  }

  async search(query: string, lat?: number, lng?: number) {
    const filter: any = {
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
      ],
    }
    if (lat && lng) {
      filter.location = {
        $nearSphere: {
          $geometry: { type: 'Point', coordinates: [lng, lat] },
          $maxDistance: 10000,
        },
      }
    }
    return this.restaurantModel.find(filter).limit(30).exec()
  }
}
