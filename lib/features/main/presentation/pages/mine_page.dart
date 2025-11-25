import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/remote/supabase_auth_service.dart';
import '../../../account/data/local_profile_storage.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final _auth = SupabaseAuthService.instance;

  User? _user;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  /// Local avatar path
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);

    _user = _auth.currentUser;

    if (_user != null) {
      _profile = await _auth.getCurrentProfile();
      await _loadAvatarForEmail(_user!.email);
    } else {
      _profile = null;
      _avatarPath = null;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  /// Unified avatar path reading via LocalProfileStorage
  Future<void> _loadAvatarForEmail(String? email) async {
    if (email == null || email.isEmpty) {
      if (!mounted) return;
      setState(() {
        _avatarPath = null;
      });
      return;
    }

    final path = await LocalProfileStorage.getAvatarPath(email);
    if (!mounted) return;

    setState(() {
      _avatarPath = path;
    });
  }

  /// Logout/Switch Account
  Future<void> _onLogoutOrSwitch() async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Log out directly or switch accounts?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, 'logout'),
                  child: const Text('Log out'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, 'switch'),
                  child: const Text('Switch'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (action == null) return;

    await _auth.signOut();
    if (!mounted) return;

    if (action == 'logout') {
      // Exit only, stay in Mine
      await _loadUser();
    } else if (action == 'switch') {
      // Log out and open the login page
      Navigator.pushNamed(context, '/login').then((_) => _loadUser());
    }
  }

  /// Avatar component: Prioritizes displaying local avatars; otherwise, displays an empty frame.
  Widget _buildAvatarBox() {
    final hasAvatar = _avatarPath != null &&
        _avatarPath!.isNotEmpty &&
        File(_avatarPath!).existsSync();

    if (!hasAvatar) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 2),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        File(_avatarPath!),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _auth.isLoggedIn;
    final username = _profile?['username'] as String? ?? 'Guest';
    final email = _user?.email ?? 'Not logged in';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // Purple bar at the top
          Container(
            height: 80,
            color: const Color(0xFFB5A7FF),
          ),

          // ==== Clickable Profile row ====
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!_auth.isLoggedIn) {
                // Not logged in: Go to the login page first.
                Navigator.pushNamed(context, '/login')
                    .then((_) => _loadUser());
              } else {
                // Logged in: Open user profile page
                Navigator.pushNamed(context, '/userProfile')
                    .then((_) => _loadUser());
              }
            },
            child: Container(
              color: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildAvatarBox(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _loading
                        ? const SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:
                        CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email: $email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // The menu items below
          _buildItem(
            title: 'Documents',
            onTap: () {
              Navigator.pushNamed(context, '/documents');
            },
          ),
          _buildItem(
            title: 'Subscription',
            onTap: () {
              Navigator.pushNamed(context, '/subscription');
            },
          ),
          _buildItem(
            title: 'Login / Register',
            onTap: () {
              Navigator.pushNamed(context, '/login').then((_) => _loadUser());
            },
          ),
          _buildItem(
            title: 'Logout',
            enabled: isLoggedIn,
            onTap: isLoggedIn ? _onLogoutOrSwitch : null,
          ),
        ],
      ),

      // Bottom navigation bar (same as HomePage)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 0=Home, 1=Test Room, 2=Mine
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          } else if (i == 1) {
            Navigator.pushNamed(context, '/testRoom');
          } else if (i == 2) {
            // Already in Mine, no action taken.
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Test Room'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Mine'),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: enabled ? Colors.black : Colors.grey,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: enabled ? onTap : null,
        ),
        const Divider(height: 1),
      ],
    );
  }
}