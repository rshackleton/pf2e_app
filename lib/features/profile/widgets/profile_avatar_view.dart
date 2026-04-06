import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/profile/services/image_cache_manager.dart';
import 'package:pf2e_app/locator.dart';

class ProfileAvatarView extends StatelessWidget {
  final String? avatarPath;
  final String? signedAvatarUrl;
  final String? firstName;
  final String? lastName;
  final double radius;

  const ProfileAvatarView({
    super.key,
    required this.avatarPath,
    required this.signedAvatarUrl,
    required this.firstName,
    required this.lastName,
    this.radius = 64,
  });

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

  @override
  Widget build(BuildContext context) {
    final initials = _computeInitials();
    final url = signedAvatarUrl;

    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        cacheManager: di<ImageCacheManager>(),
        cacheKey: avatarPath ?? url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
          radius: radius,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          child: Icon(Icons.person, size: radius * 0.75),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          child: initials != null
              ? Text(
                  initials,
                  style: TextStyle(
                    fontSize: radius * 0.44,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(Icons.person, size: radius * 0.75),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      child: initials != null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.44,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(Icons.person, size: radius * 0.75),
    );
  }
}

