class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String nickname;
  final String employeeId;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.nickname,
    required this.employeeId,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'nickname': nickname,
      'employeeId': employeeId,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      nickname: map['nickname'] ?? '',
      employeeId: map['employeeId'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}
