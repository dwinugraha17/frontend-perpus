import 'dart:io';
import 'package:flutter/foundation.dart';

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

    // Fix untuk Android Emulator jika backend return localhost atau 127.0.0.1
    if (!kIsWeb && photoUrl != null) {
      if (Platform.isAndroid) {
        if (photoUrl.contains('localhost')) {
          photoUrl = photoUrl.replaceFirst('localhost', '10.0.2.2');
        } else if (photoUrl.contains('127.0.0.1')) {
          photoUrl = photoUrl.replaceFirst('127.0.0.1', '10.0.2.2');
        }
      }
    }

    return UserModel(
      id: json['id'],
      name: json['name'],
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
