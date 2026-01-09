class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePhoto;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePhoto,
  });

      factory UserModel.fromJson(Map<String, dynamic> json) {
      String? photoUrl = json['profile_photo'];
  
      return UserModel(
        id: json['id'],      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profilePhoto: photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_photo': profilePhoto,
    };
  }
}
