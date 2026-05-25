import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:ung_dung_nhan_tin_nhom3/pages/page_conversation.dart';

import '../helper/color.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  int _currentIndex = 0;

  String get displayName {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['display_name'] ?? 'Người dùng';
  }

  String? get avatarUrl {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['avatar_url'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const Center(child: Text('Tìm kiếm'));
      case 2:
        return const Center(child: Text('Cá nhân'));
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        // Header: ảnh đại diện + tên
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 100, bottom: 50),
          color: AppColors.primary,
          child: Column(
            children: [
              // Avatar
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: avatarUrl != null
                    ? ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.person_rounded,
                  size: 75,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 45,),
        // Nội dung chính
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _menuCard(
                        icon: Icons.person_outline_rounded,
                        label: 'Cá nhân',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _menuCard(
                        icon: Icons.people_outline_rounded,
                        label: 'Bạn bè',
                        onTap: () {

                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _menuCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Cuộc trò chuyện',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PageConversations()),
                    );
                  },
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: fullWidth ? 28 : 28,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment:
          fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 36),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      backgroundColor: AppColors.primaryLight,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textMuted,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search),
          label: 'Tìm kiếm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}