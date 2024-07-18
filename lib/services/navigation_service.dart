import 'package:chat/models/user_profile.dart';
import 'package:chat/pages/settings_page.dart';
import 'package:chat/pages/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/login_page.dart';
import 'package:chat/pages/home_page.dart';
import 'package:chat/pages/register_page.dart';
import 'package:chat/pages/user_profile_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const LoginPage(),
    "/register": (context) => const RegisterPage(),
    "/home": (context) => const Homepage(),
    "/settings": (context) => const SettingsPage(),
    "/verification": (context) => const VerificationPage(),
    "/user-profile": (context) => UserProfilePage(user: ModalRoute.of(context)!.settings.arguments as UserProfile),
  };

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  GlobalKey<NavigatorState> get navigatorKey {
    return _navigatorKey;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}
