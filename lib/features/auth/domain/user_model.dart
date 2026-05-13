class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String role;
  final String shopId;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    required this.role,
    required this.shopId,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'role': role,
      'shopId': shopId,
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
      role: map['role'] ?? 'owner',
      shopId: map['shopId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch) as int,
      ),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : null,
    );
  }
}