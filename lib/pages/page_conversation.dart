import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class PageConversations extends StatelessWidget {
  const PageConversations({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuộc trò chuyện'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.person_add_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Tìm kiếm cuộc trò chuyện...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          // Danh sách
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('conversations')
                  .stream(primaryKey: ['id'])
                  .order('last_message_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Lọc chỉ hiện conversation có userId trong member_ids
                final conversations = snapshot.data!.where((c) {
                  final members = List<String>.from(c['member_ids'] ?? []);
                  return members.contains(userId);
                }).toList();

                if (conversations.isEmpty) {
                  return const Center(
                    child: Text('Chưa có cuộc trò chuyện nào'),
                  );
                }

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return _ConversationTile(conv: conv, currentUserId: userId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conv, required this.currentUserId});

  final Map<String, dynamic> conv;
  final String currentUserId;

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays == 1) return 'Hôm qua';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = conv['is_group'] == true;
    final name = conv['name'] ?? 'Cuộc trò chuyện';
    final lastMsg = conv['last_message'] ?? '';
    final time = _formatTime(conv['last_message_at']);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFa2d2ff),
        child: isGroup
            ? const Icon(Icons.group, color: Colors.white)
            : Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMsg,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => PageChat(conversationId: conv['id'], title: name),
        //   ),
        // );
      },
    );
  }
}