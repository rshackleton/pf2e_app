import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
import 'package:pf2e_app/features/profile/services/image_cache_manager.dart';
import 'package:pf2e_app/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MissingLinkedProfileException implements Exception {
  const MissingLinkedProfileException();

  @override
  String toString() => 'Missing linked profile for authenticated user.';
}

abstract class ProfileService {
  Future<ProfileRecord> getProfile(String userId);

  Future<ProfileRecord> updateProfile(
    String userId, {
    String? firstName,
    String? lastName,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  });

  Future<String?> getSignedAvatarUrl(String? storagePath);

  void clearCache();
}

class _SignedUrlEntry {
  final String url;
  final DateTime expiresAt;

  const _SignedUrlEntry({required this.url, required this.expiresAt});

  bool get isStale =>
      expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 5)));
}

class SupabaseProfileService implements ProfileService {
  static const _profilesTable = 'profiles';
  static const _avatarsBucket = 'avatars';

  static final _unsafeFolderChars = RegExp(r'[^A-Za-z0-9._-]');

  final _signedUrlCache = <String, _SignedUrlEntry>{};

  @override
  Future<ProfileRecord> getProfile(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from(_profilesTable)
          .select()
          .eq('user_id', userId)
          .single()
          .withConverter(ProfileRecord.fromJson);

      return profile;
    } on PostgrestException catch (e, s) {
      debugPrint('Error loading profile: $e $s');
      if (e.code == 'PGRST116') {
        throw const MissingLinkedProfileException();
      }
      rethrow;
    }
  }

  @override
  Future<ProfileRecord> updateProfile(
    String userId, {
    String? firstName,
    String? lastName,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) async {
    final updates = <String, dynamic>{};
    String? oldAvatarPath;
    String? newAvatarPath;

    if (firstName != null) {
      updates['first_name'] = firstName;
    }
    if (lastName != null) {
      updates['last_name'] = lastName;
    }

    if (avatarBytes != null) {
      final currentProfile = await getProfile(userId);
      oldAvatarPath = currentProfile.avatarPath;

      final extension = (avatarFileExtension?.trim().isNotEmpty ?? false)
          ? avatarFileExtension!.trim().toLowerCase()
          : 'png';
      final avatarFolder = _toStorageSafeFolder(userId);
      newAvatarPath =
          '$avatarFolder/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await Supabase.instance.client.storage
          .from(_avatarsBucket)
          .uploadBinary(
            newAvatarPath,
            avatarBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      updates['avatar_path'] = newAvatarPath;
    }

    try {
      if (updates.isNotEmpty) {
        await Supabase.instance.client
            .from(_profilesTable)
            .update(updates)
            .eq('user_id', userId);
      }
    } catch (e, s) {
      if (newAvatarPath != null) {
        await _deleteAvatarBestEffort(
          newAvatarPath,
          context: 'rollback after profile update failure',
        );
      }

      debugPrint('Failed to update profile: $e $s');
      rethrow;
    }

    if (oldAvatarPath != null &&
        newAvatarPath != null &&
        oldAvatarPath != newAvatarPath) {
      await _deleteAvatarBestEffort(
        oldAvatarPath,
        context: 'cleanup previous avatar after successful replacement',
      );
      final normalizedOld = oldAvatarPath.startsWith('/')
          ? oldAvatarPath.substring(1)
          : oldAvatarPath;
      _signedUrlCache.remove(normalizedOld);
      await di<ImageCacheManager>().removeFile(normalizedOld);
    }

    return getProfile(userId);
  }

  @override
  Future<String?> getSignedAvatarUrl(String? storagePath) async {
    if (storagePath == null || storagePath.trim().isEmpty) {
      return null;
    }

    final path = storagePath.trim().startsWith('/')
        ? storagePath.trim().substring(1)
        : storagePath.trim();

    final cached = _signedUrlCache[path];
    if (cached != null && !cached.isStale) {
      return cached.url;
    }

    try {
      final url = await Supabase.instance.client.storage
          .from(_avatarsBucket)
          .createSignedUrl(path, 3600);
      _signedUrlCache[path] = _SignedUrlEntry(
        url: url,
        expiresAt: DateTime.now().add(const Duration(seconds: 3600)),
      );
      return url;
    } catch (e, s) {
      debugPrint('Failed to get signed avatar URL: $e $s');
      return null;
    }
  }

  @override
  void clearCache() {
    _signedUrlCache.clear();
  }

  String _toStorageSafeFolder(String userId) {
    return userId.replaceAll(_unsafeFolderChars, '_');
  }

  Future<void> _deleteAvatarBestEffort(
    String path, {
    required String context,
  }) async {
    try {
      await Supabase.instance.client.storage.from(_avatarsBucket).remove([
        path,
      ]);
    } catch (e, s) {
      debugPrint('Failed to delete avatar ($context): $e $s');
    }
  }
}
