import 'package:bk_pos/features/transaction/services/thermal_printer_service.dart';
import 'package:bk_pos/features/transaction/services/pdf_receipt_service.dart';
import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class ThermalReceiptScreen extends StatefulWidget {
  final TransactionDetailModel transaction;
  const ThermalReceiptScreen({super.key, required this.transaction});

  @override
  State<ThermalReceiptScreen> createState() => _ThermalReceiptScreenState();
}

class _ThermalReceiptScreenState extends State<ThermalReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _printing = false;
  bool _showPrinterInfo = false;

  bool _checkingPrinter = false;
  bool _printerReady = false;
  bool _bluetoothEnabled = false;
  String _printerMessage = 'Silakan cari printer Bluetooth.';
  List<BluetoothInfo> _printers = [];
  BluetoothInfo? _selectedPrinter;

  bool _generatingPdf = false;

  late final TextEditingController _paddingLeftController;
  late final TextEditingController _paddingRightController;
  late final TextEditingController _paddingTopController;
  late final TextEditingController _paddingBottomController;
  bool _showPaddingSettings = false;

  double get _paddingLeft => double.tryParse(_paddingLeftController.text) ?? 0;

  double get _paddingRight =>
      double.tryParse(_paddingRightController.text) ?? 0;

  double get _paddingTop => double.tryParse(_paddingTopController.text) ?? 0;

  double get _paddingBottom =>
      double.tryParse(_paddingBottomController.text) ?? 0;

  Widget _buildPaddingInput({
    required String label,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'px',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildPaddingSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Padding Nota',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            'Atur jarak tepi nota sebelum dicetak.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildPaddingInput(
                label: 'Left',
                controller: _paddingLeftController,
              ),
              const SizedBox(width: 8),
              _buildPaddingInput(
                label: 'Right',
                controller: _paddingRightController,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _buildPaddingInput(
                label: 'Top',
                controller: _paddingTopController,
              ),
              const SizedBox(width: 8),
              _buildPaddingInput(
                label: 'Bottom',
                controller: _paddingBottomController,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _paddingLeftController.text = '8';
                  _paddingRightController.text = '8';
                  _paddingTopController.text = '8';
                  _paddingBottomController.text = '50';
                });
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Padding'),
            ),
          ),
        ],
      ),
    );
  }

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
      AppToast.error(
        title: 'Printer Belum Terhubung',
        description: 'Silakan hubungkan printer terlebih dahulu.',
      );

      return;
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

  Future<void> _checkBluetoothStatus() async {
    final enabled = await ThermalPrinterService.isBluetoothEnabled();

    if (!mounted) return;

    setState(() {
      _bluetoothEnabled = enabled;

      if (!enabled) {
        _printerMessage = 'Bluetooth HP belum aktif.';
      } else {
        _printerMessage = 'Bluetooth aktif. Silakan cari printer.';
      }
    });
  }

  Future<void> _findPrinters() async {
    if (_checkingPrinter) return;

    setState(() {
      _checkingPrinter = true;
      _printerReady = false;
      _printerMessage = 'Mencari printer Bluetooth...';
      _printers = [];
      _selectedPrinter = null;
    });

    try {
      final bluetoothEnabled = await ThermalPrinterService.isBluetoothEnabled();

      if (!bluetoothEnabled) {
        if (!mounted) return;

        setState(() {
          _checkingPrinter = false;
          _bluetoothEnabled = false;
          _printerMessage = 'Bluetooth HP belum aktif.';
        });

        return;
      }

      final printers = await ThermalPrinterService.getPairedPrinters();

      if (!mounted) return;

      setState(() {
        _checkingPrinter = false;
        _bluetoothEnabled = true;
        _printers = printers;

        if (printers.isEmpty) {
          _printerMessage = 'Tidak ada printer Bluetooth yang sudah paired.';
        } else {
          _printerMessage = '${printers.length} perangkat Bluetooth ditemukan.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _checkingPrinter = false;
        _printerMessage = 'Gagal mencari printer: $e';
      });
    }
  }

  Future<void> _connectSelectedPrinter() async {
    final printer = _selectedPrinter;

    if (printer == null) {
      AppToast.error(
        title: 'Pilih Printer',
        description: 'Silakan pilih printer Bluetooth terlebih dahulu.',
      );

      return;
    }

    if (_checkingPrinter) return;

    setState(() {
      _checkingPrinter = true;
      _printerReady = false;
      _printerMessage = 'Menghubungkan ke ${printer.name}...';
    });

    final result = await ThermalPrinterService.connectToPrinter(printer);

    if (!mounted) return;

    setState(() {
      _checkingPrinter = false;
      _printerReady = result.success;
      _printerMessage = result.message;
    });

    if (result.success) {
      AppToast.success(title: 'Printer Terhubung', description: result.message);
    } else {
      AppToast.error(title: 'Gagal Terhubung', description: result.message);
    }
  }

  @override
  void initState() {
    super.initState();

    _paddingLeftController = TextEditingController(text: '8');
    _paddingRightController = TextEditingController(text: '8');
    _paddingTopController = TextEditingController(text: '8');
    _paddingBottomController = TextEditingController(text: '50');

    _checkBluetoothStatus();
  }

  @override
  void dispose() {
    _paddingLeftController.dispose();
    _paddingRightController.dispose();
    _paddingTopController.dispose();
    _paddingBottomController.dispose();

    super.dispose();
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

    final totalPaid = transaction.payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final isPartial = transaction.paymentStatus.toLowerCase() == 'partial';
    final remainingAmount = transaction.remainingAmount;

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

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),

                  child: Center(
                    child: RepaintBoundary(
                      key: _receiptKey,

                      child: Container(
                        width: 288,
                        padding: EdgeInsets.only(
                          left: _paddingLeft,
                          right: _paddingRight,
                          top: _paddingTop,
                          bottom: _paddingBottom,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        transaction.storeView ??
                                            'Bisa Kulak Gresik',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          color: AppColors.dark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 2),

                                      Text(
                                        transaction.storeAddress ??
                                            'Jl. Raya kepatihan No.49, Kecamatan Menganti, Kabupaten Gresik, Jawa Timur',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          color: AppColors.dark,
                                          fontSize: 8,
                                          height: 1.2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'No. Telp: ${transaction.storePhone}',
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

                                const SizedBox(width: 5),

                                SizedBox(
                                  width: 100,
                                  height: 48,

                                  child: Image.asset(
                                    'assets/images/logo.jpeg',
                                    // fit: BoxFit.contain,
                                    fit: BoxFit.fill,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,

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
                              label: 'Point/Diskon',
                              value:
                                  '-${currency.format(transaction.nego + transaction.pointsUsed)}',
                            ),

                            const SizedBox(height: 6),

                            _InfoRow(
                              label: 'Total',
                              value: currency.format(transaction.total),
                            ),

                            if (isPartial) ...[
                              _InfoRow(
                                label: 'DP',
                                value: currency.format(totalPaid),
                              ),

                              _InfoRow(
                                label: 'Sisa',
                                value: currency.format(remainingAmount),
                              ),
                            ],

                            const SizedBox(height: 8),
                            const Divider(color: AppColors.dark, height: 1),
                            const SizedBox(height: 8),

                            const Text(
                              'Informasi & Layanan Pelanggan\nTerima kasih, selamat berbelanja kembali!',
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: AppColors.dark,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Barang yang sudah dibeli tidak dapat dikembalikan',
                              // 'Kebijakan produk: Barang yang sudah dibeli tidak bisa direturn',
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: AppColors.dark,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            const Text(
                              'Layanan Pelanggan Bisa Kulak',
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: AppColors.dark,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    transaction.storeEmail ??
                                        'bisakulakpusat@gmail.com',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: AppColors.dark,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Text(
                                  '  •  ',
                                  style: TextStyle(
                                    color: AppColors.dark,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Flexible(
                                  child: Text(
                                    '085173372019',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: AppColors.dark,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: _showPrinterInfo,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _showPrinterInfo = expanded;
                              });
                            },

                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),

                            childrenPadding: const EdgeInsets.fromLTRB(
                              12,
                              0,
                              12,
                              12,
                            ),

                            leading: Icon(
                              Icons.bluetooth,
                              color: _bluetoothEnabled
                                  ? Colors.blue
                                  : Colors.red,
                            ),

                            title: Text(
                              _printerReady
                                  ? 'Printer Terhubung'
                                  : 'Printer Bluetooth',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              _printerReady
                                  ? _selectedPrinter?.name ??
                                        'Printer siap digunakan'
                                  : _bluetoothEnabled
                                  ? 'Bluetooth aktif • Belum terhubung'
                                  : 'Bluetooth HP belum aktif',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: _printerReady
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_printerReady)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),

                                if (_checkingPrinter)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),

                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),

                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _printerReady
                                      ? Colors.green.shade50
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _printerReady
                                          ? Icons.print
                                          : Icons.print_disabled,
                                      size: 20,
                                      color: _printerReady
                                          ? Colors.green
                                          : Colors.grey,
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
                                          color: _printerReady
                                              ? Colors.green.shade800
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: _checkingPrinter
                                      ? null
                                      : _findPrinters,
                                  icon: _checkingPrinter
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.refresh),
                                  label: Text(
                                    _checkingPrinter
                                        ? 'Mencari Printer...'
                                        : 'Cari Printer Bluetooth',
                                  ),
                                ),
                              ),

                              if (_printers.isNotEmpty) ...[
                                const SizedBox(height: 10),

                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Printer Bluetooth',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 180,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _printers.length,
                                    itemBuilder: (context, index) {
                                      final printer = _printers[index];

                                      final selected =
                                          _selectedPrinter?.macAdress ==
                                          printer.macAdress;

                                      return InkWell(
                                        onTap: _checkingPrinter
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedPrinter = printer;
                                                  _printerReady = false;
                                                  _printerMessage =
                                                      '${printer.name} dipilih.';
                                                });
                                              },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? Colors.blue.shade50
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: selected
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.print_outlined,
                                                size: 20,
                                                color: selected
                                                    ? Colors.blue
                                                    : Colors.grey.shade700,
                                              ),

                                              const SizedBox(width: 8),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      printer.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 2),

                                                    Text(
                                                      printer.macAdress,
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              if (selected)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 4),

                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        (_selectedPrinter == null ||
                                            _checkingPrinter)
                                        ? null
                                        : _connectSelectedPrinter,
                                    icon: _checkingPrinter
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.bluetooth_connected),
                                    label: Text(
                                      _checkingPrinter
                                          ? 'Menghubungkan...'
                                          : 'Hubungkan Printer',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 48,

                        child: ElevatedButton.icon(
                          onPressed: _printing ? null : _printReceipt,

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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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

          // PANEL CUSTOM PADDING
          Positioned(
            right: 48,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: _showPaddingSettings ? 250 : 0,
                child: ClipRect(
                  child: _showPaddingSettings
                      ? Material(
                          elevation: 8,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 250,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: _buildPaddingSettings(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // TOMBOL DI SISI KANAN LAYAR
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.blue,
                elevation: 6,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  onTap: () {
                    setState(() {
                      _showPaddingSettings = !_showPaddingSettings;
                    });
                  },
                  child: SizedBox(
                    width: 44,
                    height: 100,
                    child: Icon(
                      _showPaddingSettings ? Icons.close : Icons.tune,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
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
