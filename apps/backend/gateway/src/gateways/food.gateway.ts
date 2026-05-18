import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets'
import { UseGuards } from '@nestjs/common'
import { Server, Socket } from 'socket.io'
import { WsJwtGuard } from '../common/guards/ws-jwt.guard'
import type { OrderPlacedPayload, OrderStatusPayload } from '@crab/socket-events'

@WebSocketGateway({
  namespace: '/food',
  cors: { origin: '*', credentials: true },
})
export class FoodGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server

  handleConnection(client: Socket) {
    console.log(`[FoodGateway] Client connected: ${client.id}`)
  }

  handleDisconnect(client: Socket) {
    console.log(`[FoodGateway] Client disconnected: ${client.id}`)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('order:placed')
  handleOrderPlaced(
    @MessageBody() payload: OrderPlacedPayload,
    @ConnectedSocket() client: Socket,
  ) {
    const user = client.data['user']
    console.log(`[FoodGateway] Order placed by ${user?.sub}`)
    // Notify merchant
    this.server
      .to(`merchant:${payload.merchantId}`)
      .emit('order:new', payload)
    return { event: 'order:confirmed', data: { orderId: payload.orderId } }
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('order:status')
  handleOrderStatus(
    @MessageBody() payload: OrderStatusPayload,
  ) {
    this.server
      .to(`order:${payload.orderId}`)
      .emit('order:status', payload)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('order:join')
  handleJoinOrder(
    @MessageBody() data: { orderId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`order:${data.orderId}`)
    return { event: 'order:joined', data: { orderId: data.orderId } }
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('merchant:join')
  handleJoinMerchant(
    @MessageBody() data: { merchantId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`merchant:${data.merchantId}`)
    return { event: 'merchant:joined', data: { merchantId: data.merchantId } }
  }
}
