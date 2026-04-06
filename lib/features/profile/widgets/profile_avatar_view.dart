import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAvatarView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final initials = _computeInitials();
    final resolvedAvatarUrl = _resolveAvatarUrl(avatarPath);

    return CircleAvatar(
      backgroundImage: resolvedAvatarUrl != null
          ? NetworkImage(resolvedAvatarUrl)
          : null,
      radius: radius,
      child: resolvedAvatarUrl == null
          ? (initials != null
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: radius * 0.44,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Icon(Icons.person, size: radius * 0.75))
          : null,
    );
  }

  String? _resolveAvatarUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) {
      return null;
    }

    final value = pathOrUrl.trim();
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return value;
    }

    final normalizedPath = value.startsWith('/') ? value.substring(1) : value;
    return Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(normalizedPath);
  }

  String? _computeInitials() {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';

    if (first.isNotEmpty || last.isNotEmpty) {
      final a = first.isNotEmpty ? first.characters.first : '';
      final b = last.isNotEmpty ? last.characters.first : '';
      return (a + b).toUpperCase();
    }

    return null;
  }
}
