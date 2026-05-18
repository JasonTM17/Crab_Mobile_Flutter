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
import type {
  RideRequestPayload,
  RideLocationPayload,
  RideCancelledPayload,
} from '@crab/socket-events'

@WebSocketGateway({
  namespace: '/ride',
  cors: { origin: '*', credentials: true },
})
export class RideGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server

  handleConnection(client: Socket) {
    console.log(`[RideGateway] Client connected: ${client.id}`)
  }

  handleDisconnect(client: Socket) {
    console.log(`[RideGateway] Client disconnected: ${client.id}`)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('ride:request')
  handleRideRequest(
    @MessageBody() payload: RideRequestPayload,
    @ConnectedSocket() client: Socket,
  ) {
    const user = client.data['user']
    console.log(`[RideGateway] Ride request from ${user?.sub}`)
    // Broadcast to available drivers
    this.server.emit('ride:new_request', { ...payload, riderId: user?.sub })
    return { event: 'ride:request_received', data: { status: 'searching' } }
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('ride:location')
  handleLocationUpdate(
    @MessageBody() payload: RideLocationPayload,
    @ConnectedSocket() client: Socket,
  ) {
    // Broadcast location to ride room
    client.to(`ride:${payload.rideId}`).emit('ride:location', payload)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('ride:cancel')
  handleRideCancel(
    @MessageBody() payload: RideCancelledPayload,
    @ConnectedSocket() client: Socket,
  ) {
    const user = client.data['user']
    this.server.to(`ride:${payload.rideId}`).emit('ride:cancelled', {
      ...payload,
      cancelledBy: user?.sub,
    })
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('ride:join')
  handleJoinRide(
    @MessageBody() data: { rideId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`ride:${data.rideId}`)
    return { event: 'ride:joined', data: { rideId: data.rideId } }
  }
}
