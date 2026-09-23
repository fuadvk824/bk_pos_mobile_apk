import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../model/transaction_detail_model.dart';
import '../data/transaction_repository.dart';

class PaymentBottomSheet extends StatefulWidget {
  final TransactionDetailModel transaction;

  const PaymentBottomSheet({super.key, required this.transaction});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final repo = TransactionRepository();

  final driverController = TextEditingController();
  final shippingController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  bool amountEdited = false;
  bool loading = false;
  String deliveryType = "pickup";
  String paymentMethod = "cash";

  bool get isPaid => widget.transaction.paymentStatus.toLowerCase() == "paid";
  bool get showDeliveryOption =>
      widget.transaction.paymentStatus == "unpaid" ||
      widget.transaction.paymentStatus == "partial";
  bool get showDriverField => deliveryType == "delivery";
  bool get showShippingField => deliveryType == "delivery";

  double get paidAmount =>
      widget.transaction.payments.fold(0, (sum, e) => sum + e.amount);

  double get shippingCost {
    if (deliveryType == "delivery") {
      return parseRupiah(shippingController.text);
    }
    return 0;
  }

  double get currentTotal {
    return widget.transaction.subtotal +
        shippingCost -
        widget.transaction.pointsUsed -
        widget.transaction.nego;
  }

  double get remaining {
    return currentTotal - paidAmount;
  }

  void refreshAmountIfNeeded() {
    if (amountEdited) return;

    final formatted = remaining <= 0 ? '' : formatRupiah(remaining);

    amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  double getCurrentRemaining() {
    return remaining;
  }
 
  @override
  void initState() {
    super.initState();

    driverController.text = widget.transaction.driverName ?? "";
    notesController.text = widget.transaction.notes ?? "";
    deliveryType = widget.transaction.deliveryType ?? "pickup";

    shippingController.text = widget.transaction.shippingCost == 0
        ? ''
        : formatRupiah(widget.transaction.shippingCost);

    amountController.text = remaining > 0 ? formatRupiah(remaining) : '';

    amountEdited = false;

    shippingController.addListener(() {
      refreshAmountIfNeeded();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    driverController.dispose();
    shippingController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final isPaid = widget.transaction.paymentStatus.toLowerCase() == "paid";

    if (isPaid) {
      if (deliveryType == "delivery" && driverController.text.trim().isEmpty) {
        AppToast.error(
          title: 'Driver Wajib Diisi',
          description: 'Silakan masukkan nama driver terlebih dahulu',
        );
        return;
      }

      if (deliveryType == "pickup") {
        Navigator.pop(context, true);
        return;
      }

      setState(() {
        loading = true;
      });

      try {
        if (deliveryType == "delivery") {
          await repo.updateDriver(
            transactionId: widget.transaction.id,
            driverName: driverController.text.trim(),
          );
        }

        await repo.updateNotes(
          transactionId: widget.transaction.id,
          notes: notesController.text.trim(),
        );

        if (!mounted) return;

        AppToast.success(
          title: 'Berhasil',
          description: 'Data transaksi berhasil diperbarui',
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        AppToast.error(
          title: 'Gagal Update Driver',
          description: e.toString().replaceFirst('Exception: ', ''),
        );
      } finally {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }

      return;
    }

    final amount = parseRupiah(amountController.text);
    if (amount <= 0) {
      AppToast.error(
        title: 'Nominal Tidak Valid',
        description: 'Masukkan nominal pembayaran yang valid',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await repo.addPayment(
        transactionId: widget.transaction.id,
        paymentMethod: paymentMethod,
        amount: amount > getCurrentRemaining() ? getCurrentRemaining() : amount,
        driverName: showDriverField ? driverController.text.trim() : null,
        deliveryType: showDeliveryOption ? deliveryType : null,
        
        shippingCost: showShippingField
            ? parseRupiah(shippingController.text)
            : null,
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(
        title: 'Pembayaran Gagal',
        description: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.walletCards,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Pembayaran',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Lengkapi detail pembayaran transaksi',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .12),
                  ),
                ),
                child: Column(
                  children: [
                    buildSummaryRow(
                      'Subtotal',
                      formatRupiah(widget.transaction.subtotal),
                    ),
                    const SizedBox(height: 5),

                    buildSummaryRow('Ongkir', formatRupiah(shippingCost)),
                    const SizedBox(height: 5),

                    buildSummaryRow(
                      'Point',
                      '-${formatRupiah(widget.transaction.pointsUsed)}',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 5),

                    buildSummaryRow(
                      'Diskon/Nego',
                      '-${formatRupiah(widget.transaction.nego)}',
                      color: AppColors.primary,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Divider(height: 1),
                    ),

                    buildSummaryRow(
                      'Total',
                      formatRupiah(currentTotal),
                      isBold: true,
                    ),

                    const SizedBox(height: 5),

                    buildSummaryRow('Sudah Dibayar', formatRupiah(paidAmount)),

                    const SizedBox(height: 5),

                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: buildSummaryRow(
                        'Sisa Pembayaran',
                        formatRupiah(remaining),
                        color: AppColors.primary,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (showDeliveryOption) ...[
                DropdownButtonFormField<String>(
                  key: ValueKey(deliveryType),
                  initialValue: deliveryType,
                  decoration: inputDecoration(
                    label: 'Jenis Pengiriman',
                    icon: LucideIcons.truck,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
                    DropdownMenuItem(
                      value: 'delivery',
                      child: Text('Delivery'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      deliveryType = value;

                      if (deliveryType == 'pickup') {
                        shippingController.text = '0';
                      }
                    });

                    refreshAmountIfNeeded();
                  },
                ),

                const SizedBox(height: 8),
 
                if (showShippingField) ...[
                  TextField(
                    controller: shippingController,
                    keyboardType: TextInputType.number,
                    onTap: () {
                      shippingController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: shippingController.text.length,
                      );
                    },
                    decoration: inputDecoration(
                      label: 'Ongkos Kirim',
                      icon: LucideIcons.receipt,
                    ),
                    onChanged: (value) {
                      final amount = parseRupiah(value);

                      final formatted = amount == 0 ? '' : formatRupiah(amount);

                      if (shippingController.text != formatted) {
                        shippingController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }

                      refreshAmountIfNeeded();
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ],

              if (showDriverField) ...[
                TextField(
                  controller: driverController,
                  decoration: inputDecoration(
                    label: 'Nama Driver',
                    icon: LucideIcons.userRound,
                  ),
                ),

                const SizedBox(height: 8),
              ],

              TextField(
                controller: notesController,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: inputDecoration(
                  label: 'Catatan',
                  icon: LucideIcons.notebookPen,
                ),
              ),

              const SizedBox(height: 8),

              if (!isPaid) ...[
                DropdownButtonFormField<String>(
                  key: ValueKey(paymentMethod),
                  initialValue: paymentMethod,
                  decoration: inputDecoration(
                    label: 'Metode Pembayaran',
                    icon: LucideIcons.creditCard,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfer'),
                    ),
                    DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      paymentMethod = value;
                    });
                  },
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onTap: () {
                    amountController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: amountController.text.length,
                    );
                  },
                  decoration: inputDecoration(
                    label: 'Nominal Pembayaran',
                    icon: LucideIcons.banknote,
                  ),
                  onChanged: (value) {
                    amountEdited = true;

                    double amount = parseRupiah(value);
                    final maxAmount = getCurrentRemaining();

                    if (amount > maxAmount) {
                      amount = maxAmount;
                    }

                    final formatted = amount <= 0 ? '' : formatRupiah(amount);

                    if (amountController.text != formatted) {
                      amountController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 8),
              ],

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: loading ? null : submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.checkCircle2, size: 20),
                  label: Text(
                    loading
                        ? 'Menyimpan Perubahan...'
                        : isPaid
                        ? 'Simpan Perubahan'
                        : 'Simpan Pembayaran',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryRow(
    String title,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
