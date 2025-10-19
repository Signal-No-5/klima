class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorType; // lgu, ngp, barangay, citizen
  final DateTime timestamp;
  final String? imageUrl;
  final List<String>? tags;
  final bool isPinned;
  final int views;
  final String? contactInfo;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorType,
    required this.timestamp,
    this.imageUrl,
    this.tags,
    this.isPinned = false,
    this.views = 0,
    this.contactInfo,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? '',
      authorType: json['author_type'] ?? 'citizen',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      imageUrl: json['image_url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isPinned: json['is_pinned'] ?? false,
      views: json['views'] ?? 0,
      contactInfo: json['contact_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_name': authorName,
      'author_type': authorType,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'tags': tags,
      'is_pinned': isPinned,
      'views': views,
      'contact_info': contactInfo,
    };
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
