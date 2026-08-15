class UserModel {
  final int userId;
  final String userName;

  final int storeId;
  final String storeName;
  final String storeCode;

  final double targetAmount;
  final double todaySales;
  final double monthSales;
  final int todayTransaction;

  UserModel({
    required this.userId,
    required this.userName,
    required this.storeId,
    required this.storeName,
    required this.storeCode,
    required this.targetAmount,
    required this.todaySales,
    required this.monthSales,
    required this.todayTransaction,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      storeId: json['store_id'],
      storeName: json['store_name'],
      storeCode: json['store_code'],
      targetAmount: double.tryParse(json['target_amount'].toString()) ?? 0.0,
      todaySales: double.tryParse(json['today_sales'].toString()) ?? 0,
      monthSales: double.tryParse(json['month_sales'].toString()) ?? 0,
      todayTransaction: json['today_transaction'] ?? 0,
    );
  }
}
