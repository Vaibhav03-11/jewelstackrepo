class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      displayName: map['displayName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : null,
    );
  }
}