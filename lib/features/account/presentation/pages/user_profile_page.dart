import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/remote/supabase_auth_service.dart';
import '../../data/local_profile_storage.dart';
import 'change_name_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _auth = SupabaseAuthService.instance;

  String _email = '';
  String _username = '';
  String? _avatarPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _email = '';
        _username = 'Guest';
        _avatarPath = null;
        _loading = false;
      });
      return;
    }

    final email = user.email ?? '';
    // Retrieve username from profile
    final profile = await _auth.getCurrentProfile();
    final username =
    (profile?['username'] as String?)?.trim().isNotEmpty == true
        ? profile!['username'] as String
        : (user.userMetadata?['username'] as String? ?? 'Guest');

    final avatarPath = await LocalProfileStorage.getAvatarPath(email);

    setState(() {
      _email = email;
      _username = username;
      _avatarPath = avatarPath;
      _loading = false;
    });
  }

  Future<void> _changeName() async {
    final newName = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ChangeNamePage(initialName: _username),
      ),
    );

    if (newName == null || newName.trim().isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      await _auth.updateUsername(newName.trim());
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User name updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name: $e')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _changeAvatar() async {
    final user = _auth.currentUser;
    if (user == null || _email.isEmpty) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);

    try {
      final savedPath =
      await LocalProfileStorage.saveAvatarFile(_email, file);
      await LocalProfileStorage.setAvatarPath(_email, savedPath);

      setState(() {
        _avatarPath = savedPath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $e')),
      );
    }
  }

  Widget _buildAvatar() {
    final double size = 50;
    Widget child;
    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(_avatarPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // A square border is displayed when there is no profile picture.
      child = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFFB9A6FF); // Keep the color consistent with the top of MinePage

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Avatar
          ListTile(
            title: const Text(
              'Avatar',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _changeAvatar,
          ),
          const Divider(height: 1),

          // User name
          ListTile(
            title: const Text(
              'User Name',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            subtitle: Text(
              _username,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeName,
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}