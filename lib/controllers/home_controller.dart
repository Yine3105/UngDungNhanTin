import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class HomeController {
  String get displayName {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['display_name'] ?? 'Người dùng';
  }

  String? get avatarUrl {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['avatar_url'];
  }
}