import 'package:flutter/material.dart';
import '../helper/color.dart';
import '../models/profile_model.dart';
import '../controllers/friend_manage_controller.dart';

class PageFriendRequests extends StatefulWidget {
  const PageFriendRequests({super.key});

  @override
  State<PageFriendRequests> createState() => _PageFriendRequestsState();
}

class _PageFriendRequestsState extends State<PageFriendRequests> {
  final FriendManageController _manageController = FriendManageController();
  bool _isLoading = true;
  int _activeTab = 0; // 0: Đã nhận, 1: Đã gửi

  List<ProfileModel> _requests = [];
  List<ProfileModel> _sent = [];

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
        _requests = data['requests']!;
        _sent = data['sent']!;
        _isLoading = false;
      });
    }
  }

  void _acceptFriend(ProfileModel user) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang xử lý...'), duration: Duration(milliseconds: 500)),
    );

    bool success = await _manageController.acceptRequest(user.id);

    if (mounted && success) {
      _loadData();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Column(
              children: [
                Icon(Icons.handshake, color: Colors.green, size: 50),
                SizedBox(height: 10),
                Text('Kết bạn thành công!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Bạn và ${user.displayName} đã trở thành bạn bè. Hãy bắt đầu trò chuyện ngay nào!',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Chuyển sang giao diện Chat...'),
                        backgroundColor: AppColors.primaryDark
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Nhắn tin ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  void _showRequestProfileBottomSheet(BuildContext context, ProfileModel user) {
    bool isIncoming = _activeTab == 0;

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
                  color: isIncoming ? Colors.orange.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isIncoming ? 'Trạng thái: Chờ bạn xác nhận' : 'Trạng thái: Đang chờ xác nhận',
                  style: TextStyle(
                    color: isIncoming ? Colors.orange : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đang mở trang cá nhân của ${user.displayName}...')),
                  );
                },
                icon: const Icon(Icons.account_box_outlined, color: AppColors.primaryDark),
                label: const Text('Xem trang cá nhân', style: TextStyle(color: AppColors.primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 15),
              if (isIncoming)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        bool success = await _manageController.removeRelation(user.id);
                        if (mounted && success) {
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã từ chối lời mời kết bạn.'), backgroundColor: Colors.blueGrey),
                          );
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                      label: const Text('Từ chối', style: TextStyle(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _acceptFriend(user);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Đồng ý'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    bool success = await _manageController.removeRelation(user.id);
                    if (mounted && success) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã hủy lời mời kết bạn.'), backgroundColor: Colors.blueGrey),
                      );
                    }
                  },
                  icon: const Icon(Icons.person_add_disabled, color: Colors.redAccent),
                  label: const Text('Hủy lời mời kết bạn', style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
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
        title: const Text('Lời mời kết bạn', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabToggle("Đã nhận ${_requests.length}", 0),
                _buildTabToggle("Đã gửi ${_sent.length}", 1),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
                : _buildListContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle(String label, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.primaryDark : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: isActive ? AppColors.primaryDark : AppColors.textMuted, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildListContent() {
    List<ProfileModel> currentList = _activeTab == 0 ? _requests : _sent;

    if (currentList.isEmpty) {
      return Center(
          child: Text(_activeTab == 0 ? 'Không có lời mời nào' : 'Bạn chưa gửi lời mời nào',
              style: const TextStyle(color: AppColors.textMuted))
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final user = currentList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _showRequestProfileBottomSheet(context, user),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primaryDark) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        Text(user.email ?? user.phone ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (_activeTab == 0) ...[
                    IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 35),
                        onPressed: () => _acceptFriend(user)
                    ),
                    IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 35),
                        onPressed: () async {
                          await _manageController.removeRelation(user.id);
                          _loadData();
                        }
                    ),
                  ] else ...[
                    OutlinedButton(
                      onPressed: () async {
                        await _manageController.removeRelation(user.id);
                        _loadData();
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text('Hủy', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}