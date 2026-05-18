class RatingModel {
  final String id;
  final String targetType;
  final String targetId;
  final double score;
  final String? comment;
  final List<String> tags;
  final List<String> imageUrls;
  final String? replyContent;
  final DateTime? replyAt;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.score,
    this.comment,
    this.tags = const [],
    this.imageUrls = const [],
    this.replyContent,
    this.replyAt,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String? ?? json['_id'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      replyContent: json['replyContent'] as String?,
      replyAt: json['replyAt'] != null
          ? DateTime.parse(json['replyAt'] as String)
          : null,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class RatingStatsModel {
  final double average;
  final int count;
  final Map<int, int> distribution;

  const RatingStatsModel({
    required this.average,
    required this.count,
    required this.distribution,
  });

  factory RatingStatsModel.fromJson(Map<String, dynamic> json) {
    final dist = json['distribution'] as Map<String, dynamic>? ?? {};
    return RatingStatsModel(
      average: (json['average'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      distribution: dist.map((k, v) => MapEntry(int.parse(k), (v as num).toInt())),
    );
  }
}
