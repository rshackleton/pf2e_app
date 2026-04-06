import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
import 'package:pf2e_app/features/profile/services/profile_service.dart';
import 'package:pf2e_app/locator.dart';

class ProfileManager extends ChangeNotifier {
  final _authManager = di<AuthManager>();
  final _profileService = di<ProfileService>();

  final _state = ValueNotifier<ProfileViewState>(
    const ProfileViewState.initial(),
  );

  ValueListenable<ProfileViewState> get state => _state;

  ProfileManager() {
    _authManager.credentials.addListener(_onCredentialsChanged);
  }

  void _onCredentialsChanged() {
    if (_authManager.credentials.value == null) {
      clearSession();
    }
  }

  void clearSession() {
    _profileService.clearCache();
    _state.value = const ProfileViewState.initial();
  }

  late final loadProfileCommand = Command.createAsyncNoParamNoResult(
    _loadProfile,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final updateProfileCommand =
      Command.createAsyncNoResult<ProfileUpdateInput>(
        _updateProfile,
        errorFilter: const GlobalIfNoLocalErrorFilter(),
      );

  void refresh() => _forceLoadProfile();

  void retryLoad() => loadProfileCommand.run();

  Future<void> _forceLoadProfile() async {
    await _doLoadProfile(force: true);
  }

  Future<void> _loadProfile() async {
    await _doLoadProfile(force: false);
  }

  Future<void> _doLoadProfile({required bool force}) async {
    if (!force &&
        _state.value.loadState == ProfileLoadState.loaded &&
        _state.value.profile != null) {
      return;
    }

    final userId = _authManager.credentials.value?.user.sub;
    if (userId == null || userId.isEmpty) {
      _state.value = _state.value.copyWith(
        loadState: ProfileLoadState.error,
        saveState: ProfileSaveState.idle,
        errorMessage: 'You must be logged in to view your profile.',
        missingLinkedProfile: false,
        clearProfile: true,
      );
      return;
    }

    _state.value = _state.value.copyWith(
      loadState: ProfileLoadState.loading,
      saveState: ProfileSaveState.idle,
      clearErrorMessage: true,
      missingLinkedProfile: false,
    );

    try {
      final profile = await _profileService.getProfile(userId);
      final signedUrl =
          await _profileService.getSignedAvatarUrl(profile.avatarPath);
      _state.value = _state.value.copyWith(
        loadState: ProfileLoadState.loaded,
        saveState: ProfileSaveState.idle,
        profile: profile,
        signedAvatarUrl: signedUrl,
        clearErrorMessage: true,
        missingLinkedProfile: false,
      );
    } on MissingLinkedProfileException {
      _state.value = _state.value.copyWith(
        loadState: ProfileLoadState.error,
        saveState: ProfileSaveState.idle,
        errorMessage:
            'We could not find your linked profile yet. Please retry in a moment or contact support.',
        missingLinkedProfile: true,
        clearProfile: true,
      );
    } catch (e) {
      _state.value = _state.value.copyWith(
        loadState: ProfileLoadState.error,
        saveState: ProfileSaveState.idle,
        errorMessage: 'Failed to load profile. Please try again.',
        missingLinkedProfile: false,
      );
      debugPrint('Failed to load profile: $e');
    }
  }

  Future<void> _updateProfile(ProfileUpdateInput input) async {
    final userId = _authManager.credentials.value?.user.sub;
    if (userId == null || userId.isEmpty) {
      _state.value = _state.value.copyWith(
        saveState: ProfileSaveState.error,
        errorMessage: 'You must be logged in to update your profile.',
      );
      return;
    }

    _state.value = _state.value.copyWith(
      saveState: ProfileSaveState.validating,
      clearErrorMessage: true,
    );

    final firstName = input.firstName?.trim();
    final lastName = input.lastName?.trim();

    if ((firstName?.length ?? 0) > 80 || (lastName?.length ?? 0) > 80) {
      _state.value = _state.value.copyWith(
        saveState: ProfileSaveState.error,
        errorMessage: 'First and last name must be 80 characters or fewer.',
      );
      return;
    }

    _state.value = _state.value.copyWith(saveState: ProfileSaveState.saving);

    try {
      final profile = await _profileService.updateProfile(
        userId,
        firstName: firstName,
        lastName: lastName,
        avatarBytes: input.avatarBytes,
        avatarFileExtension: input.avatarFileExtension,
      );
      final signedUrl =
          await _profileService.getSignedAvatarUrl(profile.avatarPath);

      _state.value = _state.value.copyWith(
        loadState: ProfileLoadState.loaded,
        saveState: ProfileSaveState.saved,
        profile: profile,
        signedAvatarUrl: signedUrl,
        clearErrorMessage: true,
        missingLinkedProfile: false,
      );
    } catch (e) {
      _state.value = _state.value.copyWith(
        saveState: ProfileSaveState.error,
        errorMessage: 'Failed to save profile changes. Please retry.',
      );
      debugPrint('Failed to save profile: $e');
    }
  }

  @override
  void dispose() {
    _authManager.credentials.removeListener(_onCredentialsChanged);
    _state.dispose();
    loadProfileCommand.dispose();
    updateProfileCommand.dispose();
    super.dispose();
  }
}

class ProfileUpdateInput {
  final String? firstName;
  final String? lastName;
  final Uint8List? avatarBytes;
  final String? avatarFileExtension;

  const ProfileUpdateInput({
    this.firstName,
    this.lastName,
    this.avatarBytes,
    this.avatarFileExtension,
  });
}
