import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/features/cashier/provider/customer_provider.dart';
import 'package:bk_pos/features/cashier/provider/delivery_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/payment_provider.dart';

class PaymentForm extends ConsumerStatefulWidget {
  const PaymentForm({super.key});

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  final TextEditingController negoController = TextEditingController();

  final Map<String, TextEditingController> paymentControllers = {};

  @override
  void initState() {
    super.initState();

    final payment = ref.read(paymentProvider).payment;

    negoController.text = payment.nego == 0 ? '' : formatRupiah(payment.nego);

    for (final item in payment.payments) {
      paymentControllers[item.paymentMethod] = TextEditingController(
        text: item.amount == 0 ? '' : formatRupiah(item.amount),
      );
    }
  }

  @override
  void dispose() {
    negoController.dispose();

    for (final controller in paymentControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double parseAmount(String value) {
    return parseRupiah(value);
  }

  void syncController(
    TextEditingController controller,
    double amount, {
    bool force = false,
  }) {
    final formatted = amount <= 0 ? '' : formatRupiah(amount);

    if (controller.text == formatted) return;

    if (!force && FocusManager.instance.primaryFocus?.hasFocus == true) {
      return;
    }

    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  TextEditingController getPaymentController(String method, double amount) {
    final controller = paymentControllers.putIfAbsent(
      method,
      () => TextEditingController(),
    );

    syncController(controller, amount);

    return controller;
  }

  String methodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'transfer':
        return 'Transfer';
      case 'qris':
        return 'QRIS';
      default:
        return method;
    }
  }

  IconData methodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_outlined;
      case 'transfer':
        return Icons.account_balance_outlined;
      case 'qris':
        return Icons.qr_code_2;
      default:
        return Icons.payment;
    }
  }

  Widget summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget warningMessage(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final customer = ref.watch(customerProvider);
    final delivery = ref.watch(deliveryProvider);
    final paymentState = ref.watch(paymentProvider);

    final payment = paymentState.payment;
    final notifier = ref.read(paymentProvider.notifier);

    final subtotal = cart.subtotal;
    final shipping = delivery.delivery.deliveryType == 'delivery'
        ? delivery.delivery.shippingCost
        : 0.0;

    final pointsUsed = customer.pointsUsed.toDouble();
    final nego = payment.nego;
    final totalBeforeNego = subtotal + shipping - pointsUsed;
    final total = totalBeforeNego - nego;

    final totalPayment = payment.totalPayment;
    final remainingPayment = total - totalPayment;

    final selectedMethods = payment.payments
        .map((item) => item.paymentMethod)
        .toSet();

    const availableMethods = ['cash', 'transfer', 'qris'];

    final remainingMethods = availableMethods
        .where((method) => !selectedMethods.contains(method))
        .toList();

    final removedMethods = paymentControllers.keys
        .where((method) => !selectedMethods.contains(method))
        .toList();

    for (final method in removedMethods) {
      paymentControllers.remove(method)?.dispose();
    }

    String? paymentWarning;

    if (total < 0) {
      paymentWarning = 'Total transaksi tidak boleh kurang dari Rp0.';
    } else if (payment.paymentStatus == 'paid') {
      if (total <= 0) {
        paymentWarning = 'Total transaksi tidak valid untuk pembayaran lunas.';
      } else if (totalPayment <= 0) {
        paymentWarning = 'Masukkan nominal pembayaran terlebih dahulu.';
      } else if (remainingPayment.abs() > 0.01) {
        paymentWarning = remainingPayment > 0
            ? 'Pembayaran belum mencukupi. '
                  'Masih kurang ${formatRupiah(remainingPayment)}.'
            : 'Pembayaran melebihi total transaksi sebesar '
                  '${formatRupiah(remainingPayment.abs())}.';
      }
    } else if (payment.paymentStatus == 'partial') {
      if (payment.payments.isEmpty) {
        paymentWarning = 'Tambahkan minimal satu metode pembayaran.';
      } else if (totalPayment <= 0) {
        paymentWarning = 'Masukkan nominal DP lebih dari Rp0.';
      } else if (total <= 0) {
        paymentWarning = 'Total transaksi tidak valid untuk pembayaran DP.';
      } else if (totalPayment >= total) {
        paymentWarning =
            'Untuk status DP, pembayaran harus kurang dari '
            'total transaksi. Jika sudah lunas, ubah status menjadi Lunas.';
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              key: ValueKey(payment.paymentStatus),
              initialValue: payment.paymentStatus,
              decoration: inputDecoration(
                label: 'Status Pembayaran',
                icon: Icons.receipt_long_outlined,
              ),
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: 'unpaid', child: Text('Belum Bayar')),
                DropdownMenuItem(
                  value: 'partial',
                  child: Text('DP / Sebagian'),
                ),
                DropdownMenuItem(value: 'paid', child: Text('Lunas')),
              ],
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                if (value != null) {
                  FocusScope.of(context).unfocus();
                  notifier.updateStatus(value);
                }
              },
            ),

            if (payment.paymentStatus != 'unpaid') ...[
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle( fontWeight: FontWeight.bold),
                  ),

                  if (remainingMethods.isNotEmpty)
                    PopupMenuButton<String>(
                      tooltip: 'Tambah metode pembayaran',
                      onSelected: (method) {
                        FocusScope.of(context).unfocus();
                        notifier.addPayment(method);
                      },
                      itemBuilder: (context) {
                        return remainingMethods.map((method) {
                          return PopupMenuItem<String>(
                            value: method,
                            child: Row(
                              children: [
                                Icon(methodIcon(method), size: 20),
                                const SizedBox(width: 10),
                                Text(methodLabel(method)),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          SizedBox(width: 5),
                          Text('Tambah'),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (payment.payments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Belum ada metode pembayaran. '
                    'Silakan tambahkan metode pembayaran.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              ...List.generate(payment.payments.length, (index) {
                final item = payment.payments[index];

                final controller = getPaymentController(
                  item.paymentMethod,
                  item.amount,
                );

                final availableForThisRow = availableMethods.where((method) {
                  return method == item.paymentMethod ||
                      !selectedMethods.contains(method);
                }).toList();

                return Container(
                  key: ValueKey(item.paymentMethod),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(methodIcon(item.paymentMethod), size: 20),
                          const SizedBox(width: 8),

                          Expanded(
                            child: DropdownButtonFormField<String>(
                              key: ValueKey('method_${item.paymentMethod}'),
                              initialValue: item.paymentMethod,
                              decoration: inputDecoration(
                                label: 'Metode Pembayaran',
                                icon: Icons.wallet_outlined,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              items: availableForThisRow.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(methodLabel(method)),
                                );
                              }).toList(),
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              onChanged: (value) {
                                if (value != null) {
                                  FocusScope.of(context).unfocus();
                                  notifier.updatePaymentMethod(index, value);
                                }
                              },
                            ),
                          ),

                          IconButton(
                            tooltip: 'Hapus metode',
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              notifier.removePayment(index);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        onTap: () {
                          controller.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: controller.text.length,
                          );
                        },
                        decoration: inputDecoration(
                          label: 'Nominal ${methodLabel(item.paymentMethod)}',
                          icon: Icons.payments_outlined,
                        ),
                        onChanged: (value) {
                          final amount = parseAmount(value);

                          notifier.updatePaymentAmount(
                            index,
                            amount,
                            total > 0 ? total : 0,
                          );

                          final currentPayments = ref
                              .read(paymentProvider)
                              .payment
                              .payments;

                          if (index < currentPayments.length) {
                            syncController(
                              controller,
                              currentPayments[index].amount,
                              force: true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],

            if (paymentWarning != null) warningMessage(paymentWarning),

            const SizedBox(height: 12),

            TextField(
              controller: negoController,
              keyboardType: TextInputType.number,
              onTap: () {
                negoController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: negoController.text.length,
                );
              },
              decoration: inputDecoration(
                label: 'Diskon / Nego',
                icon: Icons.discount_outlined,
              ),
              onChanged: (value) {
                var amount = parseAmount(value);

                final maximumNego = totalBeforeNego > 0 ? totalBeforeNego : 0.0;

                if (amount > maximumNego) {
                  amount = maximumNego;
                }

                notifier.updateNego(amount, maximumNego);

                syncController(negoController, amount, force: true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
 