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

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
 
  @override
  void initState() {
    super.initState();

    _checkBluetoothStatus();
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

  Future<void> _printProductPrice() async {
    if (_printing) return;

    if (!_printerReady) {
      AppToast.error(
        title: 'Printer Belum Terhubung',
        description: 'Silakan pilih dan hubungkan printer terlebih dahulu.',
      );

      return;
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
 