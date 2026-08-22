import 'package:bk_pos/features/product/presentation/product_scan_result.dart';
import 'package:bk_pos/features/product/provider/product_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ProductScanScreen extends ConsumerStatefulWidget {
  final bool returnProductOnly;
  const ProductScanScreen({super.key, this.returnProductOnly = false});

  @override
  ConsumerState<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends ConsumerState<ProductScanScreen>
    with SingleTickerProviderStateMixin {
  bool scanned = false;
  final double scanSize = 280;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: scanSize,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final scanWindow = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 80),
      width: scanSize,
      height: scanSize,
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Product")),

      body: Stack(
        children: [
          MobileScanner(
            scanWindow: scanWindow,
            onDetect: (capture) async {
              if (scanned) return;

              final barcode = capture.barcodes.first.rawValue;
              if (barcode == null) return;

              scanned = true;
              await _scan(barcode);
            },
          ),

          ScannerOverlay(scanWindow: scanWindow),

          AnimatedBuilder(
            animation: _animation,
            builder: (_, _) {
              return Positioned(
                left: scanWindow.left,
                top: scanWindow.top + _animation.value,
                child: Container(
                  width: scanWindow.width,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .7),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: const [
                Icon(Icons.qr_code_scanner, color: AppColors.light, size: 50),
                SizedBox(height: 12),
                Text(
                  "Arahkan kamera ke Barcode / QR Produk",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Pastikan barcode berada di dalam kotak",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.faded, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scan(String qr) async {
    if (!qr.startsWith("BKPOS:PRD:")) {
      scanned = false;
      if (!mounted) return;

      AppToast.error(
        title: 'QR Tidak Valid',
        description: 'QR bukan milik BK POS',
      );

      return;
    }

    final product = await ref.read(productProvider.notifier).findByQr(qr);

    if (product == null) {
      scanned = false;
      if (!mounted) return;

      AppToast.error(title: 'Produk Tidak Ditemukan');
      return;
    }

    if (!mounted) return;

    if (widget.returnProductOnly) {
      Navigator.pop(context, product);
      return;
    }

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ProductScanResultScreen(product: product),
    //   ),
    // );
    final isBackorder =
        ref.read(productProvider).selectedFilter == ProductFilter.backorder;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductScanResultScreen(product: product, isBackorder: isBackorder),
      ),
    );

    scanned = false;
  }
}

class ScannerOverlay extends StatelessWidget {
  final Rect scanWindow;
  const ScannerOverlay({super.key, required this.scanWindow});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: ScannerOverlayPainter(scanWindow),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect rect;

  ScannerOverlayPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: .65);

    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)));

    canvas.drawPath(
      Path.combine(PathOperation.difference, background, hole),
      overlayPaint,
    );

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const corner = 35.0;

    // kiri atas
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(corner + 3, 0),
      borderPaint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(0, corner + 3),
      borderPaint,
    );

    // kanan atas
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-(corner + 3), 0),
      borderPaint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(0, corner + 3),
      borderPaint,
    );

    // kiri bawah
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(corner + 3, 0),
      borderPaint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -(corner + 3)),
      borderPaint,
    );

    // kanan bawah
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-(corner + 3), 0),
      borderPaint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -(corner + 3)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
