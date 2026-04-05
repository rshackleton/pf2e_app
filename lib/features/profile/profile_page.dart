import 'dart:typed_data';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/auth/widgets/logout_widget.dart';
import 'package:pf2e_app/features/profile/manager/profile_manager.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
import 'package:pf2e_app/features/profile/widgets/profile_avatar_view.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class ProfilePage extends WatchingWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileManager = di<ProfileManager>();
    final credentials = watchValue((AuthManager m) => m.credentials);
    final UserProfile? user = credentials?.user;
    final viewState = watchValue((ProfileManager m) => m.state);
    final isSaving = watchValue(
      (ProfileManager m) => m.updateProfileCommand.isRunning,
    );

    callOnce((_) {
      profileManager.refresh();
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [LogoutWidget()],
            centerTitle: true,
            pinned: true,
            title: Text('Some App Name'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _ProfileContent(
                user: user,
                viewState: viewState,
                isSaving: isSaving,
                onRetry: profileManager.retryLoad,
                onSave:
                    (firstName, lastName, avatarBytes, avatarFileExtension) {
                      profileManager.updateProfileCommand.run(
                        ProfileUpdateInput(
                          firstName: firstName,
                          lastName: lastName,
                          avatarBytes: avatarBytes,
                          avatarFileExtension: avatarFileExtension,
                        ),
                      );
                    },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final UserProfile? user;
  final ProfileViewState viewState;
  final bool isSaving;
  final VoidCallback onRetry;
  final void Function(
    String firstName,
    String lastName,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  )
  onSave;

  const _ProfileContent({
    required this.user,
    required this.viewState,
    required this.isSaving,
    required this.onRetry,
    required this.onSave,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _imagePicker = ImagePicker();

  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarExtension;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _ProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final profile = widget.viewState.profile;
    final oldProfile = oldWidget.viewState.profile;
    if (profile != null && profile != oldProfile && !widget.isSaving) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewState.loadState == ProfileLoadState.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (widget.viewState.loadState == ProfileLoadState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              widget.viewState.errorMessage ?? 'Unable to load profile.',
              textAlign: TextAlign.center,
            ),
            FilledButton(onPressed: widget.onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final profile = widget.viewState.profile;
    final avatarUri = profile?.avatarPath;
    return Column(
      spacing: 16,
      children: [
        _selectedAvatarBytes != null
            ? CircleAvatar(
                backgroundImage: MemoryImage(_selectedAvatarBytes!),
                radius: 64,
              )
            : ProfileAvatarView(
                avatarUrl: avatarUri,
                firstName: profile?.firstName,
                lastName: profile?.lastName,
              ),
        OutlinedButton.icon(
          onPressed: widget.isSaving
              ? null
              : () async {
                  final picked = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );

                  if (picked == null) {
                    return;
                  }

                  final bytes = await picked.readAsBytes();
                  final dotIndex = picked.name.lastIndexOf('.');
                  final extension = dotIndex >= 0
                      ? picked.name.substring(dotIndex + 1).toLowerCase()
                      : 'png';

                  setState(() {
                    _selectedAvatarBytes = bytes;
                    _selectedAvatarExtension = extension;
                  });
                },
          icon: const Icon(Icons.photo_library),
          label: const Text('Change Avatar'),
        ),
        TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(labelText: 'First Name'),
        ),
        TextField(
          controller: _lastNameController,
          decoration: const InputDecoration(labelText: 'Last Name'),
        ),
        FilledButton(
          onPressed: widget.isSaving
              ? null
              : () => widget.onSave(
                  _firstNameController.text,
                  _lastNameController.text,
                  _selectedAvatarBytes,
                  _selectedAvatarExtension,
                ),
          child: Text(widget.isSaving ? 'Saving...' : 'Save Profile'),
        ),
        if (widget.viewState.saveState == ProfileSaveState.saved)
          const Text('Profile saved successfully.'),
        if (widget.viewState.saveState == ProfileSaveState.error &&
            widget.viewState.errorMessage != null)
          Text(widget.viewState.errorMessage!),
      ],
    );
  }
}
