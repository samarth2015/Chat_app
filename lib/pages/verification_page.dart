import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                _authService.logout();
                _navigationService.goBack();
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
                      Navigator.of(context).pop(true);
                    }
                  },
                  title: const Text("I verified my Email"),
                  leading: const Icon(Icons.check_circle),
                ),
              ],
            ),
          ),
        ));
  }
}
