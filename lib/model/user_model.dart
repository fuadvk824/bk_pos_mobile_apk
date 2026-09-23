class UserModel {
  final int userId;
  final String userName;

  final int storeId;
  final String storeView;

  final double targetAmount;
  final double todaySales;
  final double monthSales;
  final int todayTransaction;

  final PaymentSummary todayPayment;
  final List<MonthlySales> monthlySales;

  UserModel({
    required this.userId,
    required this.userName,
    required this.storeId,
    required this.storeView,
    required this.targetAmount,
    required this.todaySales,
    required this.monthSales,
    required this.todayTransaction,

    required this.todayPayment,
    required this.monthlySales,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      storeId: json['store_id'],
      storeView: json['store_view'],
      targetAmount: double.tryParse(json['target_amount'].toString()) ?? 0.0,
      todaySales: double.tryParse(json['today_sales'].toString()) ?? 0,
      monthSales: double.tryParse(json['month_sales'].toString()) ?? 0,
      todayTransaction: json['today_transaction'] ?? 0,

      todayPayment: PaymentSummary.fromJson(json['today_payment'] ?? {}),
      monthlySales: (json['monthly_sales'] as List? ?? [])
          .map((item) => MonthlySales.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaymentSummary {
  final double cash;
  final double transfer;
  final double qris;
  final double total;

  PaymentSummary({
    required this.cash,
    required this.transfer,
    required this.qris,
    required this.total,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      cash: double.tryParse(json['cash'].toString()) ?? 0,
      transfer: double.tryParse(json['transfer'].toString()) ?? 0,
      qris: double.tryParse(json['qris'].toString()) ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
    );
  }
}

class MonthlySales {
  final int month;
  final double total;

  MonthlySales({required this.month, required this.total});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      month: json['month'] ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
    );
  }
}
