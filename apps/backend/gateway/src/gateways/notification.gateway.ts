import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
  UseGuards,
} from '@nestjs/websockets'
import { Server, Socket } from 'socket.io'
import { WsJwtGuard } from '../common/guards/ws-jwt.guard'
import type { NotificationPayload, NotificationReadPayload } from '@crab/socket-events'

@WebSocketGateway({
  namespace: '/notification',
  cors: { origin: '*', credentials: true },
})
export class NotificationGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server

  handleConnection(client: Socket) {
    console.log(`[NotificationGateway] Client connected: ${client.id}`)
  }

  handleDisconnect(client: Socket) {
    console.log(`[NotificationGateway] Client disconnected: ${client.id}`)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('notification:subscribe')
  handleSubscribe(
    @ConnectedSocket() client: Socket,
  ) {
    const user = client.data['user']
    if (user?.sub) {
      client.join(`user:${user.sub}`)
    }
    return { event: 'notification:subscribed', data: { userId: user?.sub } }
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('notification:read')
  handleRead(
    @MessageBody() payload: NotificationReadPayload,
  ) {
    // Acknowledge read — persistence handled by notification service
    return { event: 'notification:read_ack', data: payload }
  }

  /**
   * Push a notification to a specific user (called internally by other services).
   */
  pushToUser(userId: string, notification: NotificationPayload) {
    this.server.to(`user:${userId}`).emit('notification:new', notification)
  }
}
