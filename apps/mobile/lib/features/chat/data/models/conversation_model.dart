class ConversationModel {
  final String id;
  final String type;
  final String? rideId;
  final String? orderId;
  final List<ParticipantModel> participants;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.type,
    this.rideId,
    this.orderId,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'direct',
      rideId: json['rideId'] as String?,
      orderId: json['orderId'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get otherParticipantName {
    final other =
        participants.length > 1 ? participants[1] : participants.first;
    return other.name;
  }

  String? get otherParticipantAvatar {
    final other =
        participants.length > 1 ? participants[1] : participants.first;
    return other.avatarUrl;
  }
}

class ParticipantModel {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String role;

  const ParticipantModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.role,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json['userId'] as String,
      name: json['name'] as String? ?? 'User',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? json['_id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
