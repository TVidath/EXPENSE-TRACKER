import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  final String name;
  String? photoUrl;

  User({
    String? id,
    required this.email,
    required this.name,
    this.photoUrl,
  }) : id = id ?? const Uuid().v4();

  // Factory to create a copy with updated values
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Factory to create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
