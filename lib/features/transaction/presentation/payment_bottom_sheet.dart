import 'package:flutter/material.dart';

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

  bool amountEdited = false;

  bool loading = false;
  String deliveryType = "pickup";
  String paymentMethod = "cash";

  double get paidAmount =>
      widget.transaction.payments.fold(0, (sum, e) => sum + e.amount);

  double get shippingCost {
    if (deliveryType == "delivery") {
      return double.tryParse(shippingController.text) ?? 0;
    }
    return 0;
  }

  double get currentTotal {
    if (widget.transaction.paymentStatus == "unpaid") {
      return widget.transaction.subtotal + shippingCost;
    }
    return widget.transaction.total;
  }

  double get remaining {
    return currentTotal - paidAmount;
  }

  void refreshAmountIfNeeded() {
    if (amountEdited) return;

    amountController.text = remaining.toInt().toString();
    amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: amountController.text.length),
    );
  }

  double getCurrentRemaining() {
    final shipping = deliveryType == "delivery"
        ? (double.tryParse(shippingController.text) ?? 0)
        : 0;

    final total = widget.transaction.subtotal + shipping;
    final paid = widget.transaction.payments.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    return total - paid;
  }

  @override
  void initState() {
    super.initState();

    driverController.text = widget.transaction.driverName ?? "";
    deliveryType = widget.transaction.deliveryType ?? "pickup";
    shippingController.text = widget.transaction.shippingCost
        .toInt()
        .toString();

    final paid = widget.transaction.payments.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final remaining = widget.transaction.total - paid;
    amountController.text = remaining.toInt().toString();
    amountEdited = false;

    shippingController.addListener(() {
      refreshAmountIfNeeded();

      setState(() {});
    });
  }

  @override
  void dispose() {
    driverController.dispose();
    shippingController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nominal tidak valid")));
      return;
    }

    if (deliveryType == "delivery" && driverController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Driver wajib diisi")));
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
        driverName: driverController.text.trim(),
        deliveryType: widget.transaction.paymentStatus == "unpaid"
            ? deliveryType
            : null,

        shippingCost:
            widget.transaction.paymentStatus == "unpaid" &&
                deliveryType == "delivery"
            ? double.tryParse(shippingController.text) ?? 0
            : null,
      );
      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tambah Pembayaran",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Card(
                color: Colors.blueGrey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Subtotal"),
                          const Spacer(),
                          Text("Rp ${widget.transaction.subtotal.toInt()}"),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Text("Ongkir"),
                          const Spacer(),
                          Text("Rp ${shippingCost.toInt()}"),
                        ],
                      ),

                      const Divider(),

                      Row(
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            "Rp ${currentTotal.toInt()}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text("Sudah Dibayar"),
                          const Spacer(),
                          Text("Rp ${paidAmount.toInt()}"),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text(
                            "Sisa",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            "Rp ${remaining.toInt()}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (widget.transaction.paymentStatus == "unpaid") ...[
                DropdownButtonFormField<String>(
                  value: deliveryType,
                  decoration: const InputDecoration(labelText: "Delivery Type"),
                  items: const [
                    DropdownMenuItem(value: "pickup", child: Text("Pickup")),

                    DropdownMenuItem(
                      value: "delivery",
                      child: Text("Delivery"),
                    ),
                  ],
                 
                  onChanged: (v) {
                    deliveryType = v!;

                    if (deliveryType == "pickup") {
                      shippingController.text = "0";
                    }

                    refreshAmountIfNeeded();
                    setState(() {});
                  },
                ),

                const SizedBox(height: 15),

                if (deliveryType == "delivery")
                  TextField(
                    controller: shippingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Ongkir"),
                  ),

                if (deliveryType == "delivery") const SizedBox(height: 15),
              ],

              TextField(
                controller: driverController,
                decoration: const InputDecoration(labelText: "Driver"),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: "Payment Method"),
                items: const [
                  DropdownMenuItem(value: "cash", child: Text("Cash")),
                  DropdownMenuItem(value: "transfer", child: Text("Transfer")),
                  DropdownMenuItem(value: "qris", child: Text("QRIS")),
                ],
                onChanged: (v) {
                  setState(() {
                    paymentMethod = v!;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nominal"),
               
                onChanged: (v) {
                  amountEdited = true;

                  double value = double.tryParse(v) ?? 0;

                  final maxAmount = getCurrentRemaining();

                  if (value > maxAmount) {
                    value = maxAmount;

                    amountController.text = value.toInt().toString();

                    amountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: amountController.text.length),
                    );
                  }
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Simpan Pembayaran"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
