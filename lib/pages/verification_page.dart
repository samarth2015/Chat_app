import 'package:chat/models/user_profile.dart';
import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

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
          actions: [
            IconButton(
              onPressed: () {
                _authService.logout();
                _navigationService.pushReplacementNamed("/login");
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please verify your email to continue.",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  onTap: () async {
                    await _authService.emailVerification();
                    _alertService.showToast(text: "Verification email resent.");
                  },
                  title: const Text("Resend verification email"),
                  leading: const Icon(Icons.email),
                ),
                ListTile(
                  onTap: () async {
                    final result = await _authService.checkEmailVerification();
                    if (result == false) {
                      _alertService.showToast(text: "Email not verified yet.");
                    } else {
                      _alertService.showToast(text: "Email verified.");
                      UserProfile user = await _databaseService.getSelfUnverifiedProfile();
                      await _databaseService.createUserProfile(userProfile: user);
                      _navigationService.pushReplacementNamed("/home");
                    }
                  },
                  title: const Text("Email Verified - Continue"),
                  leading: const Icon(Icons.check_circle),
                ),
              ],
            ),
          ),
        ));
  }
}
