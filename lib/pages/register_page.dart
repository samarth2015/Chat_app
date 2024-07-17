import 'dart:async';

import 'package:chat/consts.dart';
import 'package:chat/models/user_profile.dart';
import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/media_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:chat/services/storage_service.dart';
import 'package:chat/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? name, email, password;
  final GetIt _getIt = GetIt.instance;
  File? selectedImage;
  bool isLoading = false;
  bool emailVerified = false;

  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  late Timer timer;

  @override
  initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      // _authService.user!.reload();
      final result = await _authService.checkEmailVerification();
      if (result == true) {
        timer.cancel();
        setState(() {
          emailVerified = true;
          isLoading = false;
        });
        _completeRegistration();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _loginAccountLink(),
            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's, get going!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Register an account using the form below",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            CustomFormField(
              hintText: "Name",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    name = value;
                  },
                );
              },
            ),
            CustomFormField(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    email = value;
                  },
                );
              },
            ),
            CustomFormField(
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    password = value;
                  },
                );
              },
              obscureText: true,
            ),
            if (!emailVerified) _verifyEmailButtion(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          File? file = await _mediaService.getImageFromGallery();
          if (file != null) {
            setState(() {
              selectedImage = file;
            });
          } else {
            _alertService.showToast(
              text: "No image selected",
              icon: Icons.error,
            );
          }
        },
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.15,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
        ),
      ),
    );
  }

  Widget _verifyEmailButtion() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false)) {
              _registerFormKey.currentState?.save();
              // bool result = false;
              bool result = await _authService.signup(email!, password!);
              _completeUnverifiedRegistration();
              if (result) {
                await _authService.emailVerification();
                _alertService.showToast(text: "Verification email sent.");
              }
            }
          } catch (e) {
            _alertService.showToast(
              text: "Failed to register. Please try again.",
              icon: Icons.error,
            );
          }
        },
        color: Colors.blue,
        child: const Text(
          "Verify Email and Register",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  _completeUnverifiedRegistration() async {
    try {
      if (!emailVerified) {
        await _databaseService.createUnverifiedUserProfile(
          userProfile: UserProfile(
            uid: _authService.user!.uid,
            name: name,
            pfpURL: PLACEHOLDER_PFP,
          ),
        );
      } else {
        throw Exception("Unable to register user");
      }
    } catch (e) {
      _alertService.showToast(
        text: "Failed to register. Please try again.",
        icon: Icons.error,
      );
    }
  }

  _completeRegistration() async {
    try {
      if (emailVerified) {
        String? pfpURL;
        if (selectedImage == null) {
          pfpURL = PLACEHOLDER_PFP;
        } else {
          pfpURL = await _storageService.uploadUserPfp(
            file: selectedImage!,
            uid: _authService.user!.uid,
          );
        }
        if (pfpURL != null) {
          await _databaseService.createUserProfile(
            userProfile: UserProfile(
                uid: _authService.user!.uid, name: name, pfpURL: pfpURL),
          );

          _alertService.showToast(
            text: "User registered successfully",
            icon: Icons.check,
          );
          _navigationService.goBack();
          _navigationService.pushReplacementNamed("/home");
        } else {
          throw Exception("Unable to upload profile picture");
        }
      } else {
        throw Exception("Unable to register user");
      }
    } catch (e) {
      _alertService.showToast(
        text: "Failed to register. Please try again.",
        icon: Icons.error,
      );
    }
  }

  Widget _loginAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Already have an account? "),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
