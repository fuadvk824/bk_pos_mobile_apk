import 'package:bk_pos/features/product/services/thermal_product_service.dart';
import 'package:bk_pos/features/transaction/services/thermal_printer_service.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ThermalProductScreen extends StatefulWidget {
  final ProductModel product;

  const ThermalProductScreen({super.key, required this.product});

  @override
  State<ThermalProductScreen> createState() => _ThermalProductScreenState();
}

class _ThermalProductScreenState extends State<ThermalProductScreen> {
  final GlobalKey _printKey = GlobalKey();

  bool _printing = false;
  bool _checkingPrinter = true;
  bool _printerReady = false;

  String _printerMessage = 'Mengecek printer...';

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    _checkPrinter();
  }

  Future<void> _checkPrinter() async {
    if (!mounted) return;

    setState(() {
      _checkingPrinter = true;
      _printerMessage = 'Menghubungkan ke printer...';
    });

    final result = await ThermalPrinterService.connectPrinter();

    if (!mounted) return;

    setState(() {
      _checkingPrinter = false;
      _printerReady = result.success;
      _printerMessage = result.message;
    });
  }

  Future<void> _printProductPrice() async {
    if (_printing) return;

    if (!_printerReady) {
      await _checkPrinter();

      if (!_printerReady) {
        return;
      }
    }

    setState(() {
      _printing = true;
    });

    final result = await ThermalProductService.printProductPrice(
      product: widget.product,
      printKey: _printKey,
    );

    if (!mounted) return;

    setState(() {
      _printing = false;

      if (!result.success) {
        _printerReady = false;
        _printerMessage = result.message;
      }
    });

    if (result.success) {
      AppToast.success(title: 'Berhasil', description: result.message);
    } else {
      AppToast.error(title: 'Gagal', description: result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Barcode nullable, jadi gunakan productCode sebagai fallback
    final qrData = product.barcode?.isNotEmpty == true
        ? product.barcode!
        : product.productCode;

    // final now = DateTime.now();
    // final firstDay = DateTime(now.year, now.month, 1);
    // final lastDay = DateTime(now.year, now.month + 1, 0);
    // final dateFormat = DateFormat('dd-MM-yyyy');
    // final periodText =
    //     '${dateFormat.format(firstDay)} s/d ${dateFormat.format(lastDay)}';

    final now = DateTime.now();
    final dateFormat = DateFormat('MMM yyyy', 'en_US');
    final periodText = 'Periode - ${dateFormat.format(now)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text(
          'Preview Harga Produk',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),

              child: Center(
                child: RepaintBoundary(
                  key: _printKey,

                  child: Container(
                    width: 288,
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 0,
                      bottom: 50,
                    ),
                    color: AppColors.light,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // NAMA PRODUK
                        Text(
                          product.name,

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 2),
                        const Divider(color: AppColors.dark, height: 1),
                        const SizedBox(height: 2),

                        // HARGA + QR
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Harga Normal',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          currency.format(product.price),
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(
                                          color: AppColors.dark,
                                          height: 1,
                                        ),
                                      ],
                                    ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Harga Promo',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          currency.format(product.finalPrice),
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Divider(
                                          color: AppColors.dark,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 100,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                                ),
                                Text(
                                  periodText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // =========================
          // PANEL PRINTER DI BAWAH
          // =========================
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // STATUS PRINTER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _checkingPrinter
                          ? Colors.orange.shade50
                          : _printerReady
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _checkingPrinter
                            ? Colors.orange
                            : _printerReady
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _checkingPrinter
                              ? Icons.sync
                              : _printerReady
                              ? Icons.print
                              : Icons.print_disabled,
                          size: 20,
                          color: _checkingPrinter
                              ? Colors.orange
                              : _printerReady
                              ? Colors.green
                              : Colors.red,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            _printerMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _checkingPrinter
                                  ? Colors.orange.shade800
                                  : _printerReady
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),

                        if (!_checkingPrinter && !_printerReady)
                          IconButton(
                            onPressed: _checkPrinter,
                            icon: const Icon(Icons.refresh),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TOMBOL CETAK
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: (_printing || !_printerReady)
                          ? null
                          : _printProductPrice,
                      icon: _printing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print_outlined),
                      label: Text(
                        _printing
                            ? 'Mencetak...'
                            : _printerReady
                            ? 'Print Harga Produk'
                            : 'Printer Belum Siap',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
