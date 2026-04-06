import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAvatarView extends StatefulWidget {
  final String? avatarPath;
  final String? firstName;
  final String? lastName;
  final double radius;

  const ProfileAvatarView({
    super.key,
    required this.avatarPath,
    required this.firstName,
    required this.lastName,
    this.radius = 64,
  });

  @override
  State<ProfileAvatarView> createState() => _ProfileAvatarViewState();
}

class _ProfileAvatarViewState extends State<ProfileAvatarView> {
  Future<String?>? _avatarUrlFuture;

  @override
  void initState() {
    super.initState();
    _avatarUrlFuture = _resolveAvatarUrl(widget.avatarPath);
  }

  @override
  void didUpdateWidget(ProfileAvatarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarPath != widget.avatarPath) {
      _avatarUrlFuture = _resolveAvatarUrl(widget.avatarPath);
    }
  }

  Future<String?> _resolveAvatarUrl(String? pathOrUrl) async {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) {
      return null;
    }

    final value = pathOrUrl.trim();
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return value;
    }

    final normalizedPath = value.startsWith('/') ? value.substring(1) : value;
    try {
      return await Supabase.instance.client.storage
          .from('avatars')
          .createSignedUrl(normalizedPath, 3600);
    } catch (_) {
      return null;
    }
  }

  String? _computeInitials() {
    final first = widget.firstName?.trim() ?? '';
    final last = widget.lastName?.trim() ?? '';

    if (first.isNotEmpty || last.isNotEmpty) {
      final a = first.isNotEmpty ? first.characters.first : '';
      final b = last.isNotEmpty ? last.characters.first : '';
      return (a + b).toUpperCase();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _computeInitials();

    return FutureBuilder<String?>(
      future: _avatarUrlFuture,
      builder: (context, snapshot) {
        final resolvedUrl = snapshot.data;

        return CircleAvatar(
          backgroundImage: resolvedUrl != null
              ? NetworkImage(resolvedUrl)
              : null,
          radius: widget.radius,
          child: resolvedUrl == null
              ? (initials != null
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: widget.radius * 0.44,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Icon(Icons.person, size: widget.radius * 0.75))
              : null,
        );
      },
    );
  }
}
