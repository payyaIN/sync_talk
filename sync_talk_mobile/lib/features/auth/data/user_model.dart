// class AppUser {
//   final String id;
//   final String email;
//   final String role;
//   final String name;

//   AppUser({
//     required this.id,
//     required this.email,
//     required this.role,
//     required this.name,
//   });

//   Map<String, dynamic> toMap() => {
//         'email': email,
//         'role': role,
//         'name': name,
//       };

//   factory AppUser.fromMap(String id, Map<String, dynamic> map) {
//     return AppUser(
//       id: id,
//       email: map['email'],
//       role: map['role'],
//       name: map['name'],
//     );
//   }
// }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? lastSeen;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      avatar: json["avatar"],
      lastSeen: json["lastSeen"],
    );
  }
}
