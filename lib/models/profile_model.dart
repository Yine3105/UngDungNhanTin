class ProfileModel {
  final String id;
  final String displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  String? friendStatus;

  ProfileModel({
    required this.id,
    required this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.isOnline,
    this.lastSeen,
    this.createdAt,
    this.friendStatus,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? 'Người dùng mới',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null ? DateTime.tryParse(json['last_seen']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}