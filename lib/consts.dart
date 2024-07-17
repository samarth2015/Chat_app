final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");
final RegExp NAME_VALIDATION_REGEX = RegExp(r'^[a-zA-Z\s]{3,}$');

final String PLACEHOLDER_PFP = 'https://firebasestorage.googleapis.com/v0/b/fir-chat-app-7e9df.appspot.com/o/users%2Fpfps%2Fdownload.png?alt=media&token=bdd6e6f7-227d-4148-88b8-ca8073e33be5';

final bool VERIFIED = false;