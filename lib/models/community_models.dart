class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String? authorEmail;
  final String? authorPhone;
  final String category;
  final List<String>? tags;
  final String? location;
  final String? cropType;
  final String urgencyLevel;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final String? userId;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorEmail,
    this.authorPhone,
    required this.category,
    this.tags,
    this.location,
    this.cropType,
    this.urgencyLevel = 'medium',
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.userId,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorName: map['author_name'] ?? '',
      authorEmail: map['author_email'],
      authorPhone: map['author_phone'],
      category: map['category'] ?? '',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      location: map['location'],
      cropType: map['crop_type'],
      urgencyLevel: map['urgency_level'] ?? 'medium',
      status: map['status'] ?? 'open',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      viewCount: map['view_count'] ?? 0,
      likeCount: map['like_count'] ?? 0,
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_name': authorName,
      'author_email': authorEmail,
      'author_phone': authorPhone,
      'category': category,
      'tags': tags,
      'location': location,
      'crop_type': cropType,
      'urgency_level': urgencyLevel,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'user_id': userId,
    };
  }
}

class CommunityResponse {
  final String id;
  final String postId;
  final String responderName;
  final String? responderEmail;
  final String responderType;
  final String responseContent;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final String? userId;

  CommunityResponse({
    required this.id,
    required this.postId,
    required this.responderName,
    this.responderEmail,
    this.responderType = 'user',
    required this.responseContent,
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.userId,
  });

  factory CommunityResponse.fromMap(Map<String, dynamic> map) {
    return CommunityResponse(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      responderName: map['responder_name'] ?? '',
      responderEmail: map['responder_email'],
      responderType: map['responder_type'] ?? 'user',
      responseContent: map['response_content'] ?? '',
      helpfulCount: map['helpful_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      isVerified: map['is_verified'] ?? false,
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'responder_name': responderName,
      'responder_email': responderEmail,
      'responder_type': responderType,
      'response_content': responseContent,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
      'user_id': userId,
    };
  }
}

class PostAttachment {
  final String id;
  final String postId;
  final String filePath;
  final String fileType;
  final int? fileSize;
  final String? description;
  final DateTime createdAt;

  PostAttachment({
    required this.id,
    required this.postId,
    required this.filePath,
    required this.fileType,
    this.fileSize,
    this.description,
    required this.createdAt,
  });

  factory PostAttachment.fromMap(Map<String, dynamic> map) {
    return PostAttachment(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      filePath: map['file_path'] ?? '',
      fileType: map['file_type'] ?? '',
      fileSize: map['file_size'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
