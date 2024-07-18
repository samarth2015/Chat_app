class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? bio;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    this.bio,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    bio = json['bio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    data['bio'] = bio ?? '';
    return data;
  }
}
