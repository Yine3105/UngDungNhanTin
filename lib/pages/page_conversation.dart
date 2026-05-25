import 'package:flutter/material.dart';
import '../controllers/conversation_controller.dart';

class PageConversations extends StatelessWidget {
  const PageConversations({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ConversationController(); // ← dùng controller

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
                  Text(
                    'Tìm kiếm cuộc trò chuyện...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.conversationsStream(), // ← dùng controller
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ← dùng controller
                final conversations = controller.filterConversations(
                  snapshot.data!,
                  controller.currentUserId,
                );

                if (conversations.isEmpty) {
                  return const Center(
                    child: Text('Chưa có cuộc trò chuyện nào'),
                  );
                }

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return _ConversationTile(
                      conv: conv,
                      controller: controller, // ← truyền controller xuống
                    );
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
  const _ConversationTile({
    required this.conv,
    required this.controller,
  });

  final Map<String, dynamic> conv;
  final ConversationController controller;

  @override
  Widget build(BuildContext context) {
    final isGroup = conv['is_group'] == true;
    final name = conv['name'] ?? 'Cuộc trò chuyện';
    final lastMsg = conv['last_message'] ?? '';
    final time = controller.formatTime(conv['last_message_at']); // ← dùng controller

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
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      onTap: () {},
    );
  }
}