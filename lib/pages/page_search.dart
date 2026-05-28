import 'package:flutter/material.dart';
import '../helper/color.dart';
import '../models/profile_model.dart';
import '../controllers/friend_search_controller.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({super.key});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  final TextEditingController _searchTextController = TextEditingController();
  final FriendSearchController _searchController = FriendSearchController();

  bool _isLoading = false;
  List<ProfileModel> _searchResults = [];
  bool _hasSearched = false;

  void _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await _searchController.searchUsers(keyword.trim());

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  // ==============================================================
  // HÀM HIỂN THỊ PROFILE (Dành riêng cho trang Tìm Kiếm)
  // ==============================================================
  void _showSearchProfileBottomSheet(BuildContext context, ProfileModel user) {
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
              // 1. Ảnh đại diện và thông tin
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

              // 2. Khối trạng thái
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isFriend
                      ? Colors.green.withOpacity(0.1)
                      : (isPending ? Colors.orange.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFriend
                      ? 'Trạng thái: Đã là bạn bè'
                      : (isPending ? 'Trạng thái: Đang chờ xác nhận' : 'Trạng thái: Chưa kết bạn'),
                  style: TextStyle(
                    color: isFriend ? Colors.green : (isPending ? Colors.orange : AppColors.primaryDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Nút Xem trang cá nhân
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Gọi lệnh điều hướng sang trang Profile của Nhã
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đang mở trang cá nhân của ${user.displayName}...')),
                  );
                },
                icon: const Icon(Icons.account_box_outlined, color: AppColors.primaryDark),
                label: const Text(
                  'Xem trang cá nhân',
                  style: TextStyle(color: AppColors.primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              // 3. Nút chức năng thay đổi theo trạng thái
              if (isFriend)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đang mở khung chat với ${user.displayName}...')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Nhắn tin ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else if (isPending)
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang hủy lời mời...'), duration: Duration(milliseconds: 500)),
                    );
                    bool success = await _searchController.cancelFriendRequest(user.id);
                    if (mounted && success) {
                      setState(() {
                        user.friendStatus = null; // Trả về Chưa kết bạn
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã hủy lời mời kết bạn'), backgroundColor: Colors.blueGrey),
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
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang gửi lời mời...'), duration: Duration(milliseconds: 500)),
                    );
                    bool success = await _searchController.sendFriendRequest(user.id);
                    if (mounted && success) {
                      setState(() {
                        user.friendStatus = 'pending'; // Đổi sang Chờ xác nhận
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã gửi lời mời đến ${user.displayName}'), backgroundColor: AppColors.primaryDark),
                      );
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
        title: const Text(
          'Tìm kiếm bạn bè',
          style: TextStyle(color: AppColors.textDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchTextController,
              decoration: InputDecoration(
                hintText: 'Nhập email hoặc số điện thoại...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryDark),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
    }

    if (!_hasSearched) {
      return const Center(
        child: Text(
          'Nhập thông tin để tìm kiếm người dùng',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy người dùng nào khớp',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            // GẮN SỰ KIỆN: Bấm vào dòng để mở bảng Profile
            onTap: () => _showSearchProfileBottomSheet(context, user),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, color: AppColors.primaryDark)
                  : null,
            ),
            title: Text(
              user.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Text(user.email ?? user.phone ?? '', style: const TextStyle(color: AppColors.textMuted)),
            trailing: _buildActionButton(user, context),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(ProfileModel user, BuildContext context) {
    // 1. Trạng thái: Đã là bạn bè
    if (user.friendStatus == 'accepted') {
      return GestureDetector(
        onTap: () => _showSearchProfileBottomSheet(context, user), // Mở Profile
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.primaryDark, size: 20),
              SizedBox(width: 6),
              Text(
                  'Bạn bè',
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold
                  )
              ),
            ],
          ),
        ),
      );
    }

    // 2. Trạng thái: Đang chờ xác nhận (Đã gửi lời mời)
    if (user.friendStatus == 'pending') {
      return OutlinedButton(
        // THAY ĐỔI LỚN: Xóa logic gọi API, giờ nút này chỉ làm nhiệm vụ mở Profile
        onPressed: () => _showSearchProfileBottomSheet(context, user),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.textMuted, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Đã gửi', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    // 3. Trạng thái mặc định: Chưa kết bạn
    return ElevatedButton(
      // THAY ĐỔI LỚN: Xóa logic gọi API, giờ nút này chỉ làm nhiệm vụ mở Profile
      onPressed: () => _showSearchProfileBottomSheet(context, user),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: const Text('Kết bạn', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}