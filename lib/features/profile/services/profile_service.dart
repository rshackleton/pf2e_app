import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
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
}

class SupabaseProfileService implements ProfileService {
  static const _profilesTable = 'profiles';
  static const _avatarsBucket = 'avatars';

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

    if (firstName != null) {
      updates['first_name'] = firstName;
    }
    if (lastName != null) {
      updates['last_name'] = lastName;
    }

    if (avatarBytes != null) {
      final extension = (avatarFileExtension?.trim().isNotEmpty ?? false)
          ? avatarFileExtension!.trim().toLowerCase()
          : 'png';
      final avatarPath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await Supabase.instance.client.storage
          .from(_avatarsBucket)
          .uploadBinary(
            avatarPath,
            avatarBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      updates['avatar_path'] = avatarPath;
    }

    if (updates.isNotEmpty) {
      await Supabase.instance.client
          .from(_profilesTable)
          .update(updates)
          .eq('user_id', userId);
    }

    return getProfile(userId);
  }
}
