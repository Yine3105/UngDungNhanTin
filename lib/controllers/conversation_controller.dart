import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ConversationController {
  // Lấy userId của người dùng hiện tại
  String get currentUserId =>
      Supabase.instance.client.auth.currentUser!.id;

  // Stream danh sách conversations, sắp xếp theo tin nhắn mới nhất
  Stream<List<Map<String, dynamic>>> conversationsStream() {
    return Supabase.instance.client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false);
  }

  // Lọc chỉ lấy conversations có userId trong member_ids
  List<Map<String, dynamic>> filterConversations(
      List<Map<String, dynamic>> all, String userId) {
    return all.where((c) {
      final members = List<String>.from(c['member_ids'] ?? []);
      return members.contains(userId);
    }).toList();
  }

  // Format thời gian tin nhắn cuối
  String formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays == 1) return 'Hôm qua';
    return '${dt.day}/${dt.month}';
  }
}