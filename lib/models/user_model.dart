class UserModel {
  final String uid;
  final String username;
  final String fullName;
  final String nickname;
  final String employeeId;
  final String role;

  UserModel({
    required this.uid,
    required this.username,
    required this.fullName,
    required this.nickname,
    required this.employeeId,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'fullName': fullName,
      'nickname': nickname,
      'employeeId': employeeId,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      nickname: map['nickname'] ?? '',
      employeeId: map['employeeId'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}
