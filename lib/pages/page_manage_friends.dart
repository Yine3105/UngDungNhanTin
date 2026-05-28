import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../helper/color.dart';
import '../models/profile_model.dart';
import '../controllers/friend_manage_controller.dart';
import '../controllers/friend_search_controller.dart';
import 'page_friend_requests.dart';

class PageManageFriends extends StatefulWidget {
  const PageManageFriends({super.key});

  @override
  State<PageManageFriends> createState() => _PageManageFriendsState();
}

class _PageManageFriendsState extends State<PageManageFriends> {
  final FriendManageController _manageController = FriendManageController();
  final FriendSearchController _searchController = FriendSearchController();

  bool _isLoading = true;
  List<ProfileModel> _friends = [];
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _manageController.fetchFriendsData();
    if (mounted) {
      setState(() {
        _friends = data['friends']!;
        _requestCount = data['requests']!.length;
        _isLoading = false;
      });
    }
  }

  void _removeFriend(ProfileModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
          content: Text('Bạn có chắc chắn muốn xóa ${user.displayName} khỏi danh sách bạn bè không?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang xóa ${user.displayName}...'), duration: const Duration(seconds: 1)),
                );
                bool success = await _manageController.removeRelation(user.id);
                if (mounted && success) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa khỏi danh sách bạn bè.'), backgroundColor: Colors.blueGrey),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xóa bạn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showUserProfileBottomSheet(BuildContext context, ProfileModel user) {
    bool isFriend = user.friendStatus == 'accepted';
    bool isPending = user.friendStatus == 'pending';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null ? const Icon(Icons.person, size: 50, color: AppColors.primaryDark) : null,
              ),
              const SizedBox(height: 15),
              Text(user.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 5),
              Text(user.email ?? user.phone ?? '', style: const TextStyle(fontSize: 16, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isFriend ? Colors.green.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFriend ? 'Trạng thái: Bạn bè' : (isPending ? 'Trạng thái: Đang chờ xác nhận' : 'Trạng thái: Chưa kết bạn'),
                  style: TextStyle(
                    color: isFriend ? Colors.green : AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Gọi lệnh điều hướng sang trang Profile của Nhã tại đây
                  // Ví dụ: Navigator.push(context, MaterialPageRoute(builder: (_) => PageUserProfile(user: user)));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đang mở trang cá nhân của ${user.displayName}...')),
                  );
                },
                icon: const Icon(Icons.account_box_outlined, color: AppColors.primaryDark),
                label: const Text(
                  'Xem trang cá nhân',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),
              if (isFriend)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeFriend(user);
                      },
                      icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                      label: const Text('Xóa bạn bè', style: TextStyle(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đang mở khung chat với ${user.displayName}...')),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Nhắn tin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                )
              else if (isPending)
              // Đã gửi lời mời -> Hiển thị nút xám
                ElevatedButton.icon(
                  onPressed: null, // Disable nút
                  icon: const Icon(Icons.access_time),
                  label: const Text('Đã gửi lời mời'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang gửi lời mời...'), duration: Duration(milliseconds: 500)),
                    );
                    bool success = await _searchController.sendFriendRequest(user.id);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã gửi lời mời đến ${user.displayName}'), backgroundColor: AppColors.primaryDark),
                        );
                        _loadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lỗi gửi lời mời!'), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Gửi lời mời kết bạn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý bạn bè', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : Column(
        children: [
          Container(
            color: Colors.white,
            child: ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PageFriendRequests()),
                );
                _loadData();
              },
              leading: const CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.person_add_alt_1, color: Colors.white),
              ),
              title: const Text('Lời mời kết bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: _requestCount > 0
                  ? Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: Text('$_requestCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              )
                  : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Bạn bè (${_friends.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            ),
          ),
          Expanded(
            child: _friends.isEmpty
                ? const Center(child: Text('Bạn chưa có bạn bè nào', style: TextStyle(color: AppColors.textMuted)))
                : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final user = _friends[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Slidable(
                    key: ValueKey(user.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.45,
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _showUserProfileBottomSheet(context, user);
                          },
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          icon: Icons.more_horiz,
                          label: 'Thêm',
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                        ),
                        SlidableAction(
                          onPressed: (context) => _removeFriend(user),
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outline,
                          label: 'Xóa',
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primaryDark) : null,
                        ),
                        title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.email ?? user.phone ?? ''),
                        trailing: SizedBox(
                          width: 96,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryDark),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đang mở khung chat với ${user.displayName}...')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}