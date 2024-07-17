final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");
final RegExp NAME_VALIDATION_REGEX = RegExp(r'^[a-zA-Z\s]{3,}$');

final String PLACEHOLDER_PFP =
    'https://firebasestorage.googleapis.com/v0/b/fir-chat-app-7e9df.appspot.com/o/users%2Fpfps%2Fdownload.png?alt=media&token=7cc9f1db-0502-49c6-b240-49d4bd3216a5';

final bool VERIFIED = false;
