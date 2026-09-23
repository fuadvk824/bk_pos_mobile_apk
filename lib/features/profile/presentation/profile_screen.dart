import 'package:bk_pos/features/customer/presentation/customer_screen.dart';
import 'package:bk_pos/features/profile/presentation/chart_painter.dart';
import 'package:bk_pos/features/profile/presentation/payment_chart_painter.dart';
import 'package:bk_pos/features/profile/provider/profile_provider.dart';
import 'package:bk_pos/model/user_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_pos/features/auth/provider/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    if (state.isLoading && state.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = state.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Data user tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Icon(LucideIcons.store, color: AppColors.light),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.userName, style: TextStyle(fontSize: 13)),
                          Text(
                            user.storeView,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Apakah yakin ingin logout?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text("Batal"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authProvider.notifier).logout();
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.light,
                        padding: const EdgeInsets.all(10),
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(LucideIcons.logOut, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.light,
                  surfaceTintColor: AppColors.light,
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.muted, width: 1),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Omzet Bulanan tahun ${DateTime.now().year}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          formatRupiah(user.monthSales),
                          style: const TextStyle(
                            color: AppColors.light,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.light.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            notifier.monthlyGrowthText(user),
                            style: const TextStyle(
                              color: AppColors.light,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 140,
                          child: CustomPaint(
                            painter: ChartPainter(data: user.monthlySales),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.25,
                  children: [
                    _statCard(
                      LucideIcons.flag,
                      "Target Bulan Ini",
                      formatRupiah(user.targetAmount),
                      Colors.orange,
                    ),

                    _statCard(
                      LucideIcons.chartColumn,
                      "Omzet Bulan Ini",
                      formatRupiah(user.monthSales),
                      Colors.blue,
                    ),

                    _statCard(
                      LucideIcons.circleDollarSign,
                      "Omzet Hari Ini",
                      formatRupiah(user.todaySales),
                      Colors.green,
                    ),

                    _statCard(
                      LucideIcons.receiptText,
                      "Transaksi Hari Ini",
                      "${user.todayTransaction}",
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _paymentSummaryCard(user),
                const SizedBox(height: 25),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerScreen()),
                    );
                  },
                  icon: const Icon(LucideIcons.contact),
                  label: const Text("Daftar Customer"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.light,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentSummaryCard(UserModel user) {
    final payment = user.todayPayment;

    final total = payment.total;

    double percentage(double value) {
      if (total <= 0) return 0;
      return (value / total) * 100;
    }

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.muted, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              'Berdasarkan pembayaran yang diterima hari ini',
              style: TextStyle(color: AppColors.faded, fontSize: 12),
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: PaymentChartPainter(
                      cash: payment.cash,
                      transfer: payment.transfer,
                      qris: payment.qris,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    children: [
                      _paymentItem(
                        title: 'Cash',
                        amount: payment.cash,
                        percentage: percentage(payment.cash),
                        color: Colors.orange,
                      ),

                      const SizedBox(height: 15),

                      _paymentItem(
                        title: 'Transfer',
                        amount: payment.transfer,
                        percentage: percentage(payment.transfer),
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 15),

                      _paymentItem(
                        title: 'QRIS',
                        amount: payment.qris,
                        percentage: percentage(payment.qris),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Terbayar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formatRupiah(total),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentItem({
    required String title,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                formatRupiah(amount),
                style: TextStyle(color: AppColors.faded, fontSize: 11),
              ),
            ],
          ),
        ),

        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  static Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.muted, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(icon, color: color, size: 25),
            ),
            const Spacer(),
            Text(title, style: TextStyle(color: AppColors.faded, fontSize: 13)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
