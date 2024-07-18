import 'package:chat/models/user_profile.dart';
import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/media_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:chat/services/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 15,
        ),
        child: _settingsList(),
      ),
    );
  }

  Widget _settingsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showProfile(),
        _changeNameButton(),
        _changePassword(),
        _changePfp(),
        _logoutButton(),
      ],
    );
  }

  Widget _showProfile() {
    return StreamBuilder(
        stream: _databaseService.getSelfProfile(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          UserProfile user = snapshots.data!.docs.first.data();
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/user-profile", arguments: user);
            },
            child: ListTile(
              title: Text(user.name!),
              subtitle: Text(_authService.user!.email!,
                  style: const TextStyle(overflow: TextOverflow.ellipsis)),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.pfpURL!),
              ),
            ),
          );
        });
  }

  Widget _changeNameButton() {
    return ListTile(
      title: const Text("Change Display Name"),
      onTap: () {
        showDialog(context: context, builder: (context) => _changeNameAlert());
      },
      leading: const Icon(Icons.person),
    );
  }

  Widget _changePassword() {
    return ListTile(
      title: const Text("Change Password"),
      onTap: () {
        _authService.resetPassword(_authService.user!.email!);
        _alertService.showToast(
          text: "Password reset email sent",
          icon: Icons.check,
        );
      },
      leading: const Icon(Icons.lock),
    );
  }

  Widget _changePfp() {
    return ListTile(
      title: const Text("Change Profile Picture"),
      onTap: () async {
        final image = await _mediaService.getImageFromGallery();
        if (image != null) {
          final pfpURL = await _storageService.uploadUserPfp(
            file: image,
            uid: _authService.user!.uid,
          );
          if (pfpURL != null) {
            await _databaseService.uploadProfilePicture(pfpURL);
            _alertService.showToast(
              text: "Profile picture changed successfully",
              icon: Icons.check,
            );
          } else {
            _alertService.showToast(
              text: "Profile picture change failed",
              icon: Icons.error,
            );
          }
        }
      },
      leading: const Icon(Icons.image),
    );
  }

  Widget _logoutButton() {
    return ListTile(
      title: const Text("Logout"),
      onTap: () async {
        bool result = await _authService.logout();
        if (result) {
          _alertService.showToast(
            text: "Logged out successfully",
            icon: Icons.check,
          );
          _navigationService.goBack();
          _navigationService.pushReplacementNamed("/login");
        } else {
          _alertService.showToast(
            text: "Error logging out",
            icon: Icons.error,
          );
        }
      },
      leading: const Icon(Icons.logout),
    );
  }

  Widget _changeNameAlert() {
    return AlertDialog(
      title: Text("Change Display Name"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "New Display Name",
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () async {
              final result =
                  await _databaseService.changeUserName(_controller.text);
              if (result) {
                _alertService.showToast(
                  text: "Name changed successfully",
                  icon: Icons.check,
                );
              } else {
                _alertService.showToast(
                  text: "Name change failed",
                  icon: Icons.error,
                );
              }
              _navigationService.goBack();
            },
            icon: Icon(Icons.check)),
        IconButton(
            onPressed: () {
              _navigationService.goBack();
            },
            icon: Icon(Icons.close)),
      ],
    );
  }
}
