import 'package:bk_pos/features/customer/presentation/customer_screen.dart';
import 'package:bk_pos/features/profile/presentation/chart_painter.dart';
import 'package:bk_pos/features/profile/provider/profile_provider.dart';
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
                /// HEADER
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Icon(LucideIcons.store, color: AppColors.light),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.userName ?? "-",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user?.storeName ?? "-",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.light,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dark.withValues(alpha: .15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.bell),
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
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(12),
                    //   gradient: const LinearGradient(
                    //     begin: Alignment.centerLeft,
                    //     end: Alignment.centerRight,
                    //     colors: [
                    //       AppColors.primary,
                    //       AppColors.light,
                    //       AppColors.secondary,
                    //     ],
                    //     stops: [0.0, 0.5, 1.0],
                    //   ),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Omzet Bulan Ini - Dummy chart",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          formatRupiah(user?.monthSales ?? 0),
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
                          child: const Text(
                            "+15% dari bulan lalu",
                            style: TextStyle(
                              color: AppColors.light,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 140,
                          child: CustomPaint(painter: ChartPainter()),
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
                      Icons.flag,
                      "Target Bulan Ini",
                      formatRupiah(user?.targetAmount ?? 0),
                      Colors.orange,
                    ),

                    _statCard(
                      Icons.bar_chart,
                      "Omzet Bulan Ini",
                      formatRupiah(user?.monthSales ?? 0),
                      Colors.blue,
                    ),

                    _statCard(
                      Icons.attach_money,
                      "Omzet Hari Ini",
                      formatRupiah(user?.todaySales ?? 0),
                      Colors.green,
                    ),

                    _statCard(
                      Icons.receipt_long,
                      "Transaksi Hari Ini",
                      "${user?.todayTransaction ?? 0}",
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerScreen()),
                    );
                  },
                  icon: const Icon(Icons.people),
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

                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Apakah yakin ingin logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Batal"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authProvider.notifier).logout();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: AppColors.primary,
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
