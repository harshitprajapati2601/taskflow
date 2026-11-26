import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  ///// "Harshit Prajapati" -> "HP", "Harshit" -> "H". Used for the avatar.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  //Convert UserModel into Firestore data
  Map<String,dynamic> toFirestore() => {
    "uid" : uid,
    "name" : name,
    "email" : email,
    "photoUrl" : photoUrl,
    "created At" : FieldValue.serverTimestamp(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
   return UserModel(
   uid: map["uid"] as String? ?? "",
   name: map["name"] as String? ?? "",
   email: map["email"] as String? ?? "",
   photoUrl: map['phtoUrl'] as String? ,
  );
}

  @override
  List<Object?> get props => [uid,name,email,photoUrl];
}
