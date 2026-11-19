import 'package:bk_pos/features/product/services/thermal_product_service.dart';
import 'package:bk_pos/features/transaction/services/thermal_printer_service.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class ThermalProductScreen extends StatefulWidget {
  final ProductModel product;

  const ThermalProductScreen({super.key, required this.product});

  @override
  State<ThermalProductScreen> createState() => _ThermalProductScreenState();
}

class _ThermalProductScreenState extends State<ThermalProductScreen> {
  final GlobalKey _printKey = GlobalKey();

  bool _printing = false;
  bool _showPrinterInfo = false;

  bool _checkingPrinter = false;
  bool _printerReady = false;
  bool _bluetoothEnabled = false;
  String _printerMessage = 'Bluetooth aktif. Silakan cari printer.';
  List<BluetoothInfo> _printers = [];
  BluetoothInfo? _selectedPrinter;

  late final TextEditingController _normalPriceController;
  late final TextEditingController _promoPriceController;

  late final TextEditingController _paddingLeftController;
  late final TextEditingController _paddingRightController;
  late final TextEditingController _paddingTopController;
  late final TextEditingController _paddingBottomController;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    _normalPriceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );

    _promoPriceController = TextEditingController(
      text: widget.product.finalPrice.toStringAsFixed(0),
    );

    _paddingLeftController = TextEditingController(text: '8');
    _paddingRightController = TextEditingController(text: '8');
    _paddingTopController = TextEditingController(text: '0');
    _paddingBottomController = TextEditingController(text: '50');

    _checkBluetoothStatus();
  }

  @override
  void dispose() {
    _normalPriceController.dispose();
    _promoPriceController.dispose();

    _paddingLeftController.dispose();
    _paddingRightController.dispose();
    _paddingTopController.dispose();
    _paddingBottomController.dispose();

    super.dispose();
  }

  double get _paddingLeft => double.tryParse(_paddingLeftController.text) ?? 0;

  double get _paddingRight =>
      double.tryParse(_paddingRightController.text) ?? 0;

  double get _paddingTop => double.tryParse(_paddingTopController.text) ?? 0;

  double get _paddingBottom =>
      double.tryParse(_paddingBottomController.text) ?? 0;

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

  Future<void> _printProductPrice() async {
    if (_printing) return;

    if (!_printerReady) {
      AppToast.error(
        title: 'Printer Belum Terhubung',
        description: 'Silakan pilih dan hubungkan printer terlebih dahulu.',
      );

      return;
    }

    // VALIDASI HARGA
    if (_normalPriceController.text.trim().isEmpty ||
        _promoPriceController.text.trim().isEmpty) {
      AppToast.error(
        title: 'Harga Kosong',
        description: 'Harga normal dan promo harus diisi.',
      );
      return;
    }

    // MULAI PRINT
    setState(() {
      _printing = true;
    });

    FocusManager.instance.primaryFocus?.unfocus();

    await WidgetsBinding.instance.endOfFrame;

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.padding, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Custom Padding Preview',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Atur jarak konten pada label harga.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildPaddingInput(
                label: 'Left',
                controller: _paddingLeftController,
              ),
              const SizedBox(width: 10),
              _buildPaddingInput(
                label: 'Right',
                controller: _paddingRightController,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildPaddingInput(
                label: 'Top',
                controller: _paddingTopController,
              ),
              const SizedBox(width: 10),
              _buildPaddingInput(
                label: 'Bottom',
                controller: _paddingBottomController,
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _paddingLeftController.text = '8';
                  _paddingRightController.text = '8';
                  _paddingTopController.text = '0';
                  _paddingBottomController.text = '50';
                });
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Padding'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final qrData = product.barcode?.isNotEmpty == true
        ? product.barcode!
        : product.productCode;

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

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: RepaintBoundary(
                      key: _printKey,

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
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 2),
                            const Divider(color: AppColors.dark, height: 1),
                            const SizedBox(height: 6),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // HARGA NORMAL
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Harga Normal',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          SizedBox(
                                            // height: 27,
                                            child: TextField(
                                              controller:
                                                  _normalPriceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              decoration: const InputDecoration(
                                                prefixText: 'Rp ',
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (_) {
                                                setState(() {});
                                              },
                                            ),
                                          ),

                                          const Divider(
                                            color: AppColors.dark,
                                            height: 1,
                                          ),
                                        ],
                                      ),

                                      // Space antar harga normal dan harga promo
                                      const SizedBox(height: 6),

                                      // HARGA PROMO
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Harga Promo',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          SizedBox(
                                            // height: 27,
                                            child: TextField(
                                              controller: _promoPriceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              decoration: const InputDecoration(
                                                prefixText: 'Rp ',
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (_) {
                                                setState(() {});
                                              },
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

                                const SizedBox(width: 12),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    QrImageView(
                                      data: qrData,
                                      version: QrVersions.auto,
                                      size: 60,
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.white,
                                      errorCorrectionLevel:
                                          QrErrorCorrectLevel.M,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      periodText,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 6,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
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
                  const SizedBox(height: 14),

                  _buildPaddingSettings(),
                ],
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
                    blurRadius: 10,
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
                          color: _bluetoothEnabled ? Colors.blue : Colors.red,
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

                            ..._printers.map((printer) {
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
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),

                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.blue.shade50
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
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
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            Text(
                                              printer.macAdress,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey.shade600,
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
                            }),

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
                      onPressed: _printing ? null : _printProductPrice,
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
                        _printing ? 'Mencetak...' : 'Print Harga Produk',
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
