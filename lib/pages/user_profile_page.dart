import 'package:chat/consts.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/user_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class UserProfilePage extends StatefulWidget {
  final UserProfile user;
  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthService _authService;
  late NavigationService _navigationService;

  final GlobalKey<FormState> _bioFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.user.pfpURL!),
                ),
                const SizedBox(
                  height: 10,
                  width: double.infinity,
                ),
                Text(
                  widget.user.name!,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                (widget.user.uid == _authService.user!.uid)
                    ? _gestureDetecterBio()
                    : Text(
                        widget.user.bio! == "" ? "No bio" : widget.user.bio!,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
              ],
            ),
            // Expanded(child: GridView.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder)),
            if (widget.user.uid != _authService.user!.uid)
              ListTile(
                leading: Icon(Icons.delete_forever_rounded),
                title: Text("Delete this chat"),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => _showDeleteAlert());
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _gestureDetecterBio() {
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (context) => _changeBioAlert());
      },
      child: Text(
        widget.user.bio! == "" ? "No bio" : widget.user.bio!,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _changeBioAlert() {
    return AlertDialog(
      title: const Text("Change Bio"),
      content: Form(
        key: _bioFormKey,
        child: TextFormField(
          controller: TextEditingController(text: widget.user.bio),
          onSaved: (value) {
            widget.user.bio = value;
          },
          validator: (value) {
            if (value == null ||
                BIO_VALIDATION_REGEX.hasMatch(value) == false) {
              return "Bio cannot be empty";
            }
            return null;
          },
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              if (_bioFormKey.currentState?.validate() ?? false) {
                _bioFormKey.currentState?.save();
                _databaseService.changeUserBio(widget.user.bio!);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check)),
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel)),
      ],
    );
  }

  Widget _showDeleteAlert() {
    return AlertDialog(
      icon: Icon(Icons.delete_forever_rounded),
      iconColor: Colors.red,
      title: Text("Confirm Delete this chat"),
      content: Text(
          "Are you sure you want to delete this chat? \nThis action cannot be undone."),
      actions: [
        MaterialButton(
          onPressed: () {
            _databaseService.deleteChat(
                widget.user.uid!, _authService.user!.uid);
            Navigator.popUntil(context, ModalRoute.withName("/home"));
          },
          child: Text(
            "Confirm delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
        MaterialButton(
          onPressed: () {
            _navigationService.goBack();
          },
          child: Text("Cancel"),
        )
      ],
    );
  }
}
