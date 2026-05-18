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
import type { ChatMessagePayload, ChatTypingPayload, ChatReadPayload } from '@crab/socket-events'

@WebSocketGateway({
  namespace: '/chat',
  cors: { origin: '*', credentials: true },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server

  handleConnection(client: Socket) {
    console.log(`[ChatGateway] Client connected: ${client.id}`)
  }

  handleDisconnect(client: Socket) {
    console.log(`[ChatGateway] Client disconnected: ${client.id}`)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('chat:join')
  handleJoinRoom(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`chat:${data.roomId}`)
    return { event: 'chat:joined', data: { roomId: data.roomId } }
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('chat:leave')
  handleLeaveRoom(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.leave(`chat:${data.roomId}`)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('chat:message')
  handleMessage(
    @MessageBody() payload: ChatMessagePayload,
    @ConnectedSocket() client: Socket,
  ) {
    const user = client.data['user']
    const message: ChatMessagePayload = {
      ...payload,
      senderId: user?.sub ?? payload.senderId,
      timestamp: new Date().toISOString(),
    }
    // Broadcast to room (excluding sender)
    client.to(`chat:${payload.roomId}`).emit('chat:message', message)
    return { event: 'chat:message_sent', data: { messageId: payload.messageId } }
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('chat:typing')
  handleTyping(
    @MessageBody() payload: ChatTypingPayload,
    @ConnectedSocket() client: Socket,
  ) {
    client.to(`chat:${payload.roomId}`).emit('chat:typing', payload)
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('chat:read')
  handleRead(
    @MessageBody() payload: ChatReadPayload,
    @ConnectedSocket() client: Socket,
  ) {
    client.to(`chat:${payload.roomId}`).emit('chat:read', payload)
  }
}
