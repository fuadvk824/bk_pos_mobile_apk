class UserModel {
  final int userId;
  final String userName;

  final int storeId;
  final String storeName;
  final String storeCode;

  final double targetAmount;

  UserModel({
    required this.userId,
    required this.userName,
    required this.storeId,
    required this.storeName,
    required this.storeCode,
    required this.targetAmount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      storeId: json['store_id'],
      storeName: json['store_name'],
      storeCode: json['store_code'],
      targetAmount: double.tryParse(json['target_amount'].toString()) ?? 0.0,
    );
  }
}
