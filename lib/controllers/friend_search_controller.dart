import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class FriendSearchController {
  final _supabase = Supabase.instance.client;

  Future<List<ProfileModel>> searchUsers(String keyword) async {
    if (keyword.trim().isEmpty) return [];

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return [];

      final response = await _supabase
          .from('profiles')
          .select()
          .or('email.eq.$keyword,phone.eq.$keyword');

      List<ProfileModel> results = (response as List<dynamic>)
          .map((e) => ProfileModel.fromJson(e))
          .where((profile) => profile.id != currentUserId)
          .toList();

      if (results.isEmpty) return [];

      try {
        final friendResponse = await _supabase
            .from('friendships')
            .select()
            .or('requester_id.eq.$currentUserId,addressee_id.eq.$currentUserId');

        final friendList = friendResponse as List<dynamic>;

        for (var profile in results) {
          final matches = friendList.where((f) =>
          (f['requester_id'] == currentUserId && f['addressee_id'] == profile.id) ||
              (f['requester_id'] == profile.id && f['addressee_id'] == currentUserId)
          );

          if (matches.isNotEmpty) {
            profile.friendStatus = matches.first['status'];
          }
        }
      } catch (error) {
        print("Cảnh báo - Lỗi lấy trạng thái bạn bè: $error");
      }

      return results;

    } catch (e) {
      print("Lỗi khi tìm kiếm hồ sơ: $e");
      return [];
    }
  }

  Future<bool> sendFriendRequest(String targetUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      await _supabase.from('friendships').insert({
        'requester_id': currentUserId,
        'addressee_id': targetUserId,
      });
      return true;
    } catch (e) {
      print("Lỗi khi kết bạn: $e");
      return false;
    }
  }

  Future<bool> cancelFriendRequest(String targetUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      await _supabase.from('friendships')
          .delete()
          .match({
        'requester_id': currentUserId,
        'addressee_id': targetUserId,
      });
      return true;
    } catch (e) {
      print("Lỗi khi hủy lời mời: $e");
      return false;
    }
  }
}