class ProfileRecord {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? avatarPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileRecord({
    required this.userId,
    this.firstName,
    this.lastName,
    this.avatarPath,
    this.createdAt,
    this.updatedAt,
  });

  String get displayFirstName => firstName?.trim().isNotEmpty == true
      ? firstName!.trim()
      : 'First name not set';

  String get displayLastName => lastName?.trim().isNotEmpty == true
      ? lastName!.trim()
      : 'Last name not set';

  String get displayName {
    final first = firstName?.trim();
    final last = lastName?.trim();
    if ((first ?? '').isEmpty && (last ?? '').isEmpty) {
      return 'Adventurer';
    }

    return [
      if ((first ?? '').isNotEmpty) first,
      if ((last ?? '').isNotEmpty) last,
    ].join(' ');
  }

  ProfileRecord copyWith({
    String? firstName,
    String? lastName,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return ProfileRecord(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProfileRecord.fromJson(Map<String, dynamic> json) {
    return ProfileRecord(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarPath: json['avatar_path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

enum ProfileLoadState { idle, loading, loaded, error }

enum ProfileSaveState { idle, validating, saving, saved, error }

class ProfileViewState {
  final ProfileLoadState loadState;
  final ProfileSaveState saveState;
  final String? errorMessage;
  final bool missingLinkedProfile;
  final ProfileRecord? profile;
  final String? signedAvatarUrl;

  const ProfileViewState({
    required this.loadState,
    required this.saveState,
    this.errorMessage,
    this.missingLinkedProfile = false,
    this.profile,
    this.signedAvatarUrl,
  });

  const ProfileViewState.initial()
    : loadState = ProfileLoadState.idle,
      saveState = ProfileSaveState.idle,
      errorMessage = null,
      missingLinkedProfile = false,
      profile = null,
      signedAvatarUrl = null;

  ProfileViewState copyWith({
    ProfileLoadState? loadState,
    ProfileSaveState? saveState,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? missingLinkedProfile,
    ProfileRecord? profile,
    bool clearProfile = false,
    String? signedAvatarUrl,
    bool clearSignedAvatarUrl = false,
  }) {
    return ProfileViewState(
      loadState: loadState ?? this.loadState,
      saveState: saveState ?? this.saveState,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      missingLinkedProfile: missingLinkedProfile ?? this.missingLinkedProfile,
      profile: clearProfile ? null : (profile ?? this.profile),
      signedAvatarUrl: clearSignedAvatarUrl
          ? null
          : (signedAvatarUrl ?? this.signedAvatarUrl),
    );
  }
}
