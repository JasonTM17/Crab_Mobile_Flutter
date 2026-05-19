import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type RestaurantDocument = Restaurant & Document

export enum RestaurantCategory {
  VIETNAMESE = 'vietnamese',
  JAPANESE = 'japanese',
  KOREAN = 'korean',
  WESTERN = 'western',
  CHINESE = 'chinese',
  DESSERT = 'dessert',
  DRINKS = 'drinks',
}

@Schema({ timestamps: true, collection: 'restaurants' })
export class Restaurant {
  @Prop({ required: true })
  name!: string

  @Prop()
  description?: string

  @Prop({ required: true })
  address!: string

  @Prop({
    type: {
      type: String,
      enum: ['Point'],
      required: true,
    },
    coordinates: {
      type: [Number],
      required: true,
    },
  })
  location!: {
    type: 'Point'
    coordinates: [number, number]
  }

  @Prop({ type: String, enum: RestaurantCategory, required: true })
  category!: RestaurantCategory

  @Prop({ type: Number, default: 4.5, min: 1.0, max: 5.0 })
  rating!: number

  @Prop()
  image_url?: string

  @Prop({ type: Boolean, default: true })
  is_open!: boolean

  @Prop()
  opening_hours?: string

  @Prop({ required: true })
  owner_id!: string
}

export const RestaurantSchema = SchemaFactory.createForClass(Restaurant)
RestaurantSchema.index({ location: '2dsphere' })
RestaurantSchema.index({ category: 1 })
RestaurantSchema.index({ owner_id: 1 })
