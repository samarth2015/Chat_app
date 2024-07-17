import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/navigation_service.dart';
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

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
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
        _changeNameButton(),
        _logoutButton(),
      ],
    );
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
        IconButton(onPressed: () async {
          final result = await _databaseService.changeUserName(_controller.text);
          if(result){
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
        }, icon: Icon(Icons.check)),
        IconButton(onPressed: () {
          _navigationService.goBack();
        }, icon: Icon(Icons.close)),
      ],
    );
  }
}
