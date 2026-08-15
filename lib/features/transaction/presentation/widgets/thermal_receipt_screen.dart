import 'package:bk_pos/features/transaction/services/thermal_printer_service.dart';
import 'package:bk_pos/features/transaction/services/pdf_receipt_service.dart';
import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ThermalReceiptScreen extends StatefulWidget {
  final TransactionDetailModel transaction;
  const ThermalReceiptScreen({super.key, required this.transaction});

  @override
  State<ThermalReceiptScreen> createState() => _ThermalReceiptScreenState();
}

class _ThermalReceiptScreenState extends State<ThermalReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _printing = false;

  bool _checkingPrinter = true;
  bool _printerReady = false;
  String _printerMessage = 'Mengecek printer...';

  bool _generatingPdf = false;

  Future<void> _downloadPdf() async {
    if (_generatingPdf) return;

    setState(() {
      _generatingPdf = true;
    });

    try {
      await PdfReceiptService.generateReceiptPdf(
        transaction: widget.transaction,
      );

      if (!mounted) return;

      AppToast.success(
        title: 'PDF Berhasil Dibuat',
        description: 'Nota berhasil disimpan sebagai PDF.',
      );

      await PdfReceiptService.shareReceiptPdf(transaction: widget.transaction);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(title: 'Gagal Membuat PDF', description: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _generatingPdf = false;
        });
      }
    }
  }

  Future<void> _printReceipt() async {
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

    final result = await ThermalPrinterService.printReceipt(
      transaction: widget.transaction,
      receiptKey: _receiptKey,
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
      AppToast.success(title: 'Print Berhasil', description: result.message);
    } else {
      AppToast.error(title: 'Print Gagal', description: result.message);
    }
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

  @override
  void initState() {
    super.initState();

    _checkPrinter();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final printedDate = DateFormat(
      'dd/MM/yyyy HH:mm',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text(
          'Preview Nota',
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
                  key: _receiptKey,

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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    transaction.storeName ?? 'Bisa Kulak Gresik',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: AppColors.dark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    transaction.storeAddress ?? 'Jl. Raya kepatihan No.49, Kecamatan Menganti, Kabupaten Gresik, Jawa Timur',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: AppColors.dark,
                                      fontSize: 8,
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            SizedBox(
                              width: 100,
                              height: 65,

                              child: Image.asset(
                                'assets/images/logo.jpeg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        const Divider(color: AppColors.dark, height: 1),
                        const SizedBox(height: 6),

                        _InfoRow(
                          label: 'Invoice',
                          value: transaction.invoiceNumber,
                        ),

                        _InfoRow(label: 'Tanggal', value: printedDate),

                        _InfoRow(
                          label: 'Kasir',
                          value: transaction.printedBy ?? '-',
                        ),

                        const SizedBox(height: 6),
                        const Divider(color: AppColors.dark, height: 1),
                        const SizedBox(height: 6),

                        ...transaction.items.map((item) {
                          final quantity = item.quantity;
                          final unitPrice = item.price;
                          final itemTotal = item.subtotal;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,

                              children: [
                                Text(
                                  item.productName,

                                  style: const TextStyle(
                                    color: AppColors.dark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      '${quantity}x @${currency.format(unitPrice)}',

                                      style: const TextStyle(
                                        color: AppColors.dark,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      currency.format(itemTotal),

                                      style: const TextStyle(
                                        color: AppColors.dark,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 6),
                        const Divider(color: AppColors.dark, height: 1),
                        const SizedBox(height: 6),

                        _InfoRow(
                          label: 'Subtotal',
                          value: currency.format(transaction.subtotal),
                        ),

                        _InfoRow(
                          label: 'Ongkir',
                          value: currency.format(transaction.shippingCost),
                        ),

                        _InfoRow(
                          label: 'Point',
                          value: '-${currency.format(transaction.pointsUsed)}',
                        ),

                        const SizedBox(height: 6),

                        _InfoRow(
                          label: 'TOTAL',
                          value: currency.format(transaction.total),
                        ),

                        const SizedBox(height: 8),
                        const Divider(color: AppColors.dark, height: 1),
                        const SizedBox(height: 8),

                        const Text(
                          'Terima kasih, selamat belanja kembali',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Batas waktu return max 7 hari. Syarat dan ketentuan berlaku',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Barang yang sudah dibeli tidak dapat dikembalikan',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        const Text(
                          'Layanan Pelanggan Bisakulak',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                         Text(
                          '${transaction.storeEmail ?? 'bisakulakpusat@gmail.com'} (${transaction.storePhone ?? '0851-7959-5011'})',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

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
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // INFO PRINTER
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

                          color: _checkingPrinter
                              ? Colors.orange
                              : _printerReady
                              ? Colors.green
                              : Colors.red,

                          size: 20,
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

                            icon: const Icon(Icons.refresh, size: 20),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TOMBOL PRINT
                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton.icon(
                      onPressed: (_printing || !_printerReady)
                          ? null
                          : _printReceipt,

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
                            ? 'Print Nota'
                            : 'Printer Belum Siap',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: OutlinedButton.icon(
                      onPressed: _generatingPdf ? null : _downloadPdf,

                      icon: _generatingPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),

                      label: Text(
                        _generatingPdf
                            ? 'Membuat PDF...'
                            : 'Download / Share PDF',
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
