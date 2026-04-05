import 'package:flutter/material.dart';

class ProfileAvatarView extends StatelessWidget {
  final String? avatarUrl;
  final String? firstName;
  final String? lastName;
  final double radius;

  const ProfileAvatarView({
    super.key,
    required this.avatarUrl,
    required this.firstName,
    required this.lastName,
    this.radius = 64,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _computeInitials();

    return CircleAvatar(
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      radius: radius,
      child: avatarUrl == null
          ? (initials != null
                ? Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : const Icon(Icons.person, size: 48))
          : null,
    );
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
