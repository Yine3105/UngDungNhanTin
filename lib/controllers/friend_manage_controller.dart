import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class FriendManageController {
  final _supabase = Supabase.instance.client;

  // Lấy dữ liệu và phân loại danh sách bạn bè
  Future<Map<String, List<ProfileModel>>> fetchFriendsData() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return {'friends': [], 'requests': [], 'sent': []};
    }

    try {
      final friendResponse = await _supabase
          .from('friendships')
          .select()
          .or('requester_id.eq.$currentUserId,addressee_id.eq.$currentUserId')
          .order('created_at', ascending: false);

      final relations = friendResponse as List<dynamic>;

      if (relations.isEmpty) {
        return {'friends': [], 'requests': [], 'sent': []};
      }

      List<String> targetUserIds = [];
      for (var rel in relations) {
        targetUserIds.add(rel['requester_id'] == currentUserId
            ? rel['addressee_id']
            : rel['requester_id']);
      }

      if (targetUserIds.isEmpty) return {'friends': [], 'requests': [], 'sent': []};

      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .inFilter('id', targetUserIds);

      final profilesData = profileResponse as List<dynamic>;

      List<ProfileModel> friends = [];
      List<ProfileModel> requests = [];
      List<ProfileModel> sent = [];

      for (var p in profilesData) {
        var profile = ProfileModel.fromJson(p);

        // Dùng orElse trả về Map rỗng để tránh lỗi nếu không tìm thấy
        var rel = relations.firstWhere(
              (r) => (r['requester_id'] == currentUserId && r['addressee_id'] == profile.id) ||
              (r['requester_id'] == profile.id && r['addressee_id'] == currentUserId),
          orElse: () => <String, dynamic>{},
        );

        if (rel.isNotEmpty) {
          profile.friendStatus = rel['status'];

          if (rel['status'] == 'accepted') {
            friends.add(profile);
          } else if (rel['status'] == 'pending') {
            if (rel['addressee_id'] == currentUserId) {
              requests.add(profile); // Người khác gửi mình
            } else {
              sent.add(profile); // Mình gửi người khác
            }
          }
        }
      }

      return {'friends': friends, 'requests': requests, 'sent': sent};

    } catch (e) {
      print('Lỗi fetchFriendsData: $e');
      return {'friends': [], 'requests': [], 'sent': []};
    }
  }

  // Chấp nhận lời mời kết bạn
  Future<bool> acceptRequest(String targetUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      await _supabase.from('friendships')
          .update({'status': 'accepted'})
          .match({'requester_id': targetUserId, 'addressee_id': currentUserId});

      return true;
    } catch (e) {
      print('Lỗi acceptRequest: $e');
      return false;
    }
  }

  // Từ chối, hủy lời mời hoặc xóa bạn
  Future<bool> removeRelation(String targetUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      await _supabase.from('friendships')
          .delete()
          .match({'requester_id': currentUserId, 'addressee_id': targetUserId});

      await _supabase.from('friendships')
          .delete()
          .match({'requester_id': targetUserId, 'addressee_id': currentUserId});

      return true;
    } catch (e) {
      print('Lỗi removeRelation: $e');
      return false;
    }
  }
}